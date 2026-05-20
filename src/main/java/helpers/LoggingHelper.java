package helpers;

import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.JsonUtils;
import utils.LoggingContext;

import java.util.Map;


public final class LoggingHelper {

    private static final Logger FILE_LOGGER = LogManager.getLogger(LoggingHelper.class);

    private LoggingHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static void logRequestDetails(
            String method,
            String endpoint,
            Map<String, String> headers,
            Map<String, String> queryParams,
            String body
    ) {
        console("");
        console("STEP: " + stepLabel());
        console("--- REQUEST ---");
        console("  " + method + " " + endpoint);
        if (queryParams != null && !queryParams.isEmpty()) {
            queryParams.forEach((name, value) -> console("  Query: " + name + " = " + value));
        }
        console("  Body:");
        consoleBody(body);
        fileLog("REQUEST {} {} | step={}", method, endpoint, stepLabel());
    }

    public static void logResponseDetails(Response response) {
        console("--- RESPONSE ---");
        if (response == null) {
            console("  (null response)");
            console("");
            return;
        }
        console("  Status: " + response.getStatusCode() + " " + response.getStatusLine());
        console("  Body:");
        consoleBody(response.getBody().asString());
        console("");
        fileLog("RESPONSE status={} | step={}", response.getStatusCode(), stepLabel());
    }

    public static void logApiExchange(
            String method,
            String endpoint,
            Map<String, String> headers,
            Map<String, String> queryParams,
            String requestBody,
            Response response
    ) {
        logRequestDetails(method, endpoint, headers, queryParams, requestBody);
        logResponseDetails(response);
    }

    public static void logScenarioFailure(String scenarioName) {
        console("");
        console("========================================");
        console("TEST FAILED");
        console("  Scenario : " + (scenarioName == null ? "unknown" : scenarioName));
        console("  Failed at: " + nullToUnknown(LoggingContext.getFailedStep()));
        Throwable error = LoggingContext.getLastFailure();
        if (error != null) {
            console("  Error    : " + error.getClass().getSimpleName() + ": " + error.getMessage());
        }
        console("========================================");
        console("");
        FILE_LOGGER.warn("Scenario failed: {} | step: {}", scenarioName, LoggingContext.getFailedStep(), error);
    }

    public static String maskToken(String token) {
        if (token == null || token.isBlank()) {
            return "***";
        }
        int len = token.length();
        if (len <= 8) {
            return "***";
        }
        return token.substring(0, 4) + "***" + token.substring(len - 4);
    }

    private static void consoleBody(String body) {
        if (body == null || body.isBlank()) {
            console("    (empty)");
            return;
        }
        String trimmed = body.trim();
        if (looksLikeJson(trimmed)) {
            try {
                for (String line : JsonUtils.prettyPrint(trimmed).split("\n", -1)) {
                    console("    " + line);
                }
                return;
            } catch (Exception ignored) {
            }
        }
        if (trimmed.length() > 4000) {
            console("    " + trimmed.substring(0, 4000) + "... [truncated, total " + trimmed.length() + " chars]");
            return;
        }
        for (String line : trimmed.split("\n", -1)) {
            console("    " + line);
        }
    }

    private static boolean looksLikeJson(String value) {
        return value.startsWith("{") || value.startsWith("[");
    }

    private static String stepLabel() {
        String step = LoggingContext.getCurrentStep();
        return step == null || step.isBlank() ? "(no step context)" : step;
    }

    private static String nullToUnknown(String value) {
        return value == null || value.isBlank() ? "(unknown step)" : value;
    }

    private static void console(String line) {
        System.out.println(line);
    }

    private static void fileLog(String pattern, Object... args) {
        FILE_LOGGER.info(pattern, args);
    }
}
