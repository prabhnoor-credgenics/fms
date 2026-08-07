package helpers;

import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.JsonUtils;
import utils.LoggingContext;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.stream.Collectors;

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
        logRequestDetails(method, null, endpoint, headers, queryParams, body);
    }

    public static void logRequestDetails(
            String method,
            String baseUrl,
            String endpoint,
            Map<String, String> headers,
            Map<String, String> queryParams,
            String body
    ) {
        logRequestDetails(method, baseUrl, endpoint, headers, queryParams, body, null);
    }

    public static void logRequestDetails(
            String method,
            String baseUrl,
            String endpoint,
            Map<String, String> headers,
            Map<String, String> queryParams,
            String body,
            String curlBodyOverride
    ) {
        String curlBody = curlBodyOverride != null ? curlBodyOverride : body;
        String curl = buildCurlCommand(method, baseUrl, endpoint, headers, queryParams, curlBody);

        console("");
        console("STEP: " + stepLabel());
        console("--- REQUEST ---");
        console("  " + method + " " + joinUrl(baseUrl, endpoint));
        if (queryParams != null && !queryParams.isEmpty()) {
            queryParams.forEach((name, value) -> console("  Query: " + name + " = " + value));
        }
        if (headers != null && !headers.isEmpty()) {
            headers.forEach((name, value) -> console("  Header: " + name + " = " + value));
        }
        console("  Body:");
        consoleBody(body);
        console("  cURL:");
        for (String line : curl.split("\n", -1)) {
            console("    " + line);
        }
        fileLog("REQUEST {} {} | step={}", method, joinUrl(baseUrl, endpoint), stepLabel());
        fileLog("REQUEST cURL: {}", curl.replace('\n', ' '));
    }

    public static String buildCurlCommand(
            String method,
            String baseUrl,
            String endpoint,
            Map<String, String> headers,
            Map<String, String> queryParams,
            String body
    ) {
        String httpMethod = method == null ? "GET" : method.toUpperCase();
        String url = joinUrl(baseUrl, endpoint);
        if (queryParams != null && !queryParams.isEmpty() && !endpointContainsQuery(url)) {
            url = url + "?" + encodeQueryParams(queryParams);
        }

        StringBuilder curl = new StringBuilder("curl --location '")
                .append(escapeSingleQuotes(url))
                .append("'");

        if (headers != null) {
            for (Map.Entry<String, String> header : headers.entrySet()) {
                if (header.getKey() == null || header.getKey().isBlank()) {
                    continue;
                }
                curl.append(" \\\n  --header '")
                        .append(escapeSingleQuotes(header.getKey() + ": " + nullToEmpty(header.getValue())))
                        .append("'");
            }
        }

        if (body != null && !body.isBlank() && sendsBody(httpMethod)) {
            curl.append(" \\\n  --data '").append(escapeSingleQuotes(body)).append("'");
        }

        if (!"GET".equals(httpMethod)) {
            curl.append(" \\\n  --request ").append(httpMethod);
        }

        return curl.toString();
    }

    public static String resolveEndpointWithPathParams(String endpoint, Map<String, String> pathParams) {
        if (endpoint == null || pathParams == null || pathParams.isEmpty()) {
            return endpoint;
        }
        String resolved = endpoint;
        for (Map.Entry<String, String> param : pathParams.entrySet()) {
            resolved = resolved.replace("{" + param.getKey() + "}", param.getValue());
        }
        return resolved;
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

    private static String joinUrl(String baseUrl, String endpoint) {
        if (endpoint == null) {
            return "";
        }
        if (baseUrl == null || baseUrl.isBlank()) {
            return endpoint;
        }
        String base = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        String path = endpoint.startsWith("/") ? endpoint : "/" + endpoint;
        return base + path;
    }

    private static boolean endpointContainsQuery(String url) {
        return url != null && url.contains("?");
    }

    private static String encodeQueryParams(Map<String, String> queryParams) {
        return queryParams.entrySet().stream()
                .map(entry -> URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8)
                        + "="
                        + URLEncoder.encode(nullToEmpty(entry.getValue()), StandardCharsets.UTF_8))
                .collect(Collectors.joining("&"));
    }

    private static boolean sendsBody(String httpMethod) {
        return "POST".equals(httpMethod)
                || "PUT".equals(httpMethod)
                || "PATCH".equals(httpMethod);
    }

    private static String escapeSingleQuotes(String value) {
        return nullToEmpty(value).replace("'", "'\\''");
    }

    private static String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
