package helpers;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import config.ConfigReader;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.ExecutionReportSummary;
import utils.ExecutionReportSummary.Result;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Posts a local execution summary (and the latest Extent HTML report) to Slack.
 *
 * <p>Enable with {@code slack_report_enabled=true} or {@code -Dslack.report.enabled=true}.
 * Bot token / webhook live in {@code secrets/crypto.properties} (never commit them).
 */
public final class SlackReporter {

    private static final Logger logger = LogManager.getLogger(SlackReporter.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();
    private static final AtomicBoolean PUBLISHED = new AtomicBoolean(false);
    private static final DateTimeFormatter CLOCK = DateTimeFormatter.ofPattern("dd-MMM-yyyy HH:mm:ss");
    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(20))
            .build();

    private SlackReporter() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static void main(String[] args) {
        boolean ok = publishLatest(new ConfigReader());
        if (!ok) {
            System.exit(1);
        }
    }

    /**
     * Called after reports are flushed. Safe to invoke more than once — only the first
     * successful/attempted publish in this JVM runs.
     */
    public static synchronized void publishLatestIfEnabled() {
        try {
            ConfigReader config = new ConfigReader();
            if (!config.isSlackReportEnabled()) {
                String jvm = System.getProperty("slack.report.enabled");
                if (jvm != null && !jvm.isBlank()) {
                    logger.info("Slack report sharing is disabled (-Dslack.report.enabled={}; this overrides global.properties)", jvm);
                } else {
                    logger.info("Slack report sharing is disabled (slack_report_enabled=false)");
                }
                return;
            }
            publishLatest(config);
        } catch (Exception e) {
            logger.warn("Slack report sharing skipped: {}", e.getMessage());
        }
    }

    public static synchronized boolean publishLatest(ConfigReader config) {
        if (!PUBLISHED.compareAndSet(false, true)) {
            logger.info("Slack report already published in this JVM — skipping");
            return true;
        }
        try {
            ExecutionReportSummary.waitForExtentReport(Duration.ofSeconds(25));
            Result summary = ExecutionReportSummary.collect();
            return publish(config, summary);
        } catch (Exception e) {
            logger.warn("Failed to share execution report to Slack: {}", e.getMessage(), e);
            PUBLISHED.set(false);
            return false;
        }
    }

    public static boolean publish(ConfigReader config, Result summary) throws Exception {
        String botToken = firstNonBlank(
                System.getProperty("slack.bot.token"),
                System.getenv("SLACK_BOT_TOKEN"),
                config.getCryptoPropertyOrNull("slack_bot_token")
        );
        String webhook = firstNonBlank(
                System.getProperty("slack.webhook.url"),
                System.getenv("SLACK_WEBHOOK_URL"),
                config.getCryptoPropertyOrNull("slack_webhook_url")
        );
        String channel = firstNonBlank(
                System.getProperty("slack.channel"),
                config.getSlackChannel(),
                config.getSlackChannelId()
        );
        if (isBlank(botToken) && isBlank(webhook)) {
            logger.warn(
                    "Slack is enabled but no token was found. Set slack_bot_token or slack_webhook_url "
                            + "in src/main/resources/secrets/crypto.properties"
            );
            return false;
        }
        if (!isBlank(botToken) && !looksLikeBotToken(botToken)) {
            logger.warn(
                    "slack_bot_token is not a real Bot User OAuth Token (length={}, prefix={}). "
                            + "Replace the placeholder in crypto.properties with the token from "
                            + "https://api.slack.com/apps → your app → OAuth & Permissions → "
                            + "Bot User OAuth Token (starts with xoxb- and is ~50+ characters).",
                    botToken.length(),
                    tokenPrefix(botToken)
            );
            botToken = null;
            if (isBlank(webhook)) {
                return false;
            }
        }
        if (isBlank(channel) && isBlank(webhook)) {
            logger.warn("Slack channel is blank. Set slack_channel (e.g. #qa-reports) or slack_channel_id");
            return false;
        }

        String text = buildMessage(config, summary);
        boolean posted = false;
        String filePermalink = null;

        if (!isBlank(botToken)) {
            posted = postChatMessage(botToken, channel, text, summary.hasFailures());
            if (config.isSlackUploadReportEnabled() && summary.extentReport() != null) {
                filePermalink = uploadFile(botToken, channel, summary.extentReport(), text);
            }
        }
        if (!posted && !isBlank(webhook)) {
            posted = postWebhook(webhook, text);
        }
        if (filePermalink != null && !filePermalink.isBlank()) {
            logger.info("Slack file permalink: {}", filePermalink);
        }
        if (posted) {
            logger.info("Shared execution report to Slack channel '{}'", channel);
        }
        return posted;
    }

    static String buildMessage(ConfigReader config, Result summary) {
        String env = config.getEnvironment().getValue();
        String tags = System.getProperty("cucumber.filter.tags", "");
        String status = summary.hasFailures() ? "FAILED" : "PASSED";
        String emoji = summary.hasFailures() ? ":x:" : ":white_check_mark:";
        String extentPath = summary.extentReport() != null
                ? summary.extentReport().toAbsolutePath().toString()
                : "(ExtentReport.html not found yet)";

        StringBuilder sb = new StringBuilder();
        sb.append(emoji).append(" *API automation — ").append(status).append("*\n");
        sb.append("• Host: `").append(ExecutionReportSummary.hostName())
                .append("`  User: `").append(ExecutionReportSummary.userName()).append("`\n");
        sb.append("• Environment: `").append(env).append("`\n");
        sb.append("• When: ").append(LocalDateTime.now().format(CLOCK)).append("\n");
        if (!isBlank(tags)) {
            sb.append("• Tags: `").append(tags).append("`\n");
        }
        sb.append("• Scenarios: *").append(summary.total()).append("*  ")
                .append("passed: *").append(summary.passed()).append("*  ")
                .append("failed: *").append(summary.failed()).append("*  ")
                .append("skipped: *").append(summary.skipped()).append("*\n");
        sb.append("• Duration: ").append(ExecutionReportSummary.formatDuration(summary.durationNanos())).append("\n");
        sb.append("• Extent report: `").append(extentPath).append("`");
        String failedPreview = ExecutionReportSummary.failedPreview(summary.failedScenarios(), 8);
        if (!failedPreview.isBlank()) {
            sb.append("\n*Failed scenarios:*\n").append(failedPreview);
            if (summary.failedScenarios().size() > 8) {
                sb.append("\n_…and ").append(summary.failedScenarios().size() - 8).append(" more_");
            }
        }
        return sb.toString();
    }

    private static boolean postChatMessage(String botToken, String channel, String text, boolean failed)
            throws Exception {
        if (isBlank(channel)) {
            return false;
        }
        ObjectNode body = MAPPER.createObjectNode();
        body.put("channel", channel);
        body.put("text", text);
        body.put("unfurl_links", false);
        body.put("unfurl_media", false);
        HttpRequest request = HttpRequest.newBuilder(URI.create("https://slack.com/api/chat.postMessage"))
                .timeout(Duration.ofSeconds(30))
                .header("Authorization", "Bearer " + botToken)
                .header("Content-Type", "application/json; charset=utf-8")
                .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                .build();
        HttpResponse<String> response = HTTP.send(request, HttpResponse.BodyHandlers.ofString());
        JsonNode json = MAPPER.readTree(response.body());
        if (!json.path("ok").asBoolean(false)) {
            logger.warn("chat.postMessage failed: {}", json.path("error").asText(response.body()));
            return false;
        }
        logger.info("Posted Slack summary ({})", failed ? "FAILED" : "PASSED");
        return true;
    }

    private static boolean postWebhook(String webhookUrl, String text) throws Exception {
        ObjectNode body = MAPPER.createObjectNode();
        body.put("text", text);
        HttpRequest request = HttpRequest.newBuilder(URI.create(webhookUrl.trim()))
                .timeout(Duration.ofSeconds(30))
                .header("Content-Type", "application/json; charset=utf-8")
                .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                .build();
        HttpResponse<String> response = HTTP.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() >= 300) {
            logger.warn("Slack webhook failed HTTP {}: {}", response.statusCode(), response.body());
            return false;
        }
        logger.info("Posted Slack summary via incoming webhook");
        return true;
    }

    private static String uploadFile(String botToken, String channel, Path file, String comment) throws Exception {
        if (file == null || !Files.isRegularFile(file)) {
            logger.warn("Extent report file is missing — skipping Slack upload");
            return null;
        }
        byte[] bytes = Files.readAllBytes(file);
        String filename = file.getFileName().toString();
        String form = "filename=" + url(filename)
                + "&length=" + bytes.length
                + "&alt=json";
        HttpRequest getUrl = HttpRequest.newBuilder(URI.create("https://slack.com/api/files.getUploadURLExternal"))
                .timeout(Duration.ofSeconds(30))
                .header("Authorization", "Bearer " + botToken)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(form))
                .build();
        HttpResponse<String> urlResponse = HTTP.send(getUrl, HttpResponse.BodyHandlers.ofString());
        JsonNode urlJson = MAPPER.readTree(urlResponse.body());
        if (!urlJson.path("ok").asBoolean(false)) {
            logger.warn("files.getUploadURLExternal failed: {}", urlJson.path("error").asText(urlResponse.body()));
            return null;
        }
        String uploadUrl = urlJson.path("upload_url").asText();
        String fileId = urlJson.path("file_id").asText();

        HttpRequest putFile = HttpRequest.newBuilder(URI.create(uploadUrl))
                .timeout(Duration.ofMinutes(2))
                .header("Content-Type", "application/octet-stream")
                .POST(HttpRequest.BodyPublishers.ofByteArray(bytes))
                .build();
        HttpResponse<String> putResponse = HTTP.send(putFile, HttpResponse.BodyHandlers.ofString());
        if (putResponse.statusCode() >= 300) {
            logger.warn("Slack file binary upload failed HTTP {}: {}", putResponse.statusCode(), putResponse.body());
            return null;
        }

        ObjectNode complete = MAPPER.createObjectNode();
        ArrayNode files = complete.putArray("files");
        ObjectNode fileNode = files.addObject();
        fileNode.put("id", fileId);
        fileNode.put("title", filename);
        String channelId = normalizeChannelId(channel);
        if (channelId != null) {
            complete.put("channel_id", channelId);
        }
        if (!isBlank(comment)) {
            complete.put("initial_comment", "Extent HTML report attached");
        }
        HttpRequest completeReq = HttpRequest.newBuilder(URI.create("https://slack.com/api/files.completeUploadExternal"))
                .timeout(Duration.ofSeconds(30))
                .header("Authorization", "Bearer " + botToken)
                .header("Content-Type", "application/json; charset=utf-8")
                .POST(HttpRequest.BodyPublishers.ofString(complete.toString()))
                .build();
        HttpResponse<String> completeResponse = HTTP.send(completeReq, HttpResponse.BodyHandlers.ofString());
        JsonNode completeJson = MAPPER.readTree(completeResponse.body());
        if (!completeJson.path("ok").asBoolean(false)) {
            logger.warn("files.completeUploadExternal failed: {}",
                    completeJson.path("error").asText(completeResponse.body()));
            return null;
        }
        String permalink = completeJson.path("files").path(0).path("permalink").asText(null);
        logger.info("Uploaded '{}' to Slack ({})", filename, permalink == null ? fileId : permalink);

        if (channelId == null && !isBlank(channel) && permalink != null) {
            postChatMessage(botToken, channel, "Extent report: " + permalink, false);
        }
        return permalink;
    }

    private static String normalizeChannelId(String channel) {
        if (isBlank(channel)) {
            return null;
        }
        String trimmed = channel.trim();
        if (trimmed.startsWith("C") || trimmed.startsWith("G") || trimmed.startsWith("D")) {
            return trimmed;
        }
        return null;
    }

    private static String url(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (!isBlank(value)) {
                return value.trim();
            }
        }
        return null;
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    /** Real Slack bot tokens are {@code xoxb-<digits>-<digits>-<secret>} and much longer than the docs placeholder. */
    private static boolean looksLikeBotToken(String token) {
        String t = token.trim();
        return t.startsWith("xoxb-") && t.length() >= 40 && t.chars().filter(ch -> ch == '-').count() >= 3;
    }

    private static String tokenPrefix(String token) {
        String t = token.trim();
        int dash = t.indexOf('-');
        return dash >= 0 ? t.substring(0, dash + 1) : t.substring(0, Math.min(4, t.length()));
    }
}
