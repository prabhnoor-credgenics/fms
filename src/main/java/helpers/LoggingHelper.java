package helpers;

import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.JsonUtils;

/**
 * Centralised request/response log formatting. Use instead of inline logger calls in step defs.
 *
 * <p>Parallel-safe: all methods are static and operate on the supplied response without shared state.
 */
public final class LoggingHelper {

    private static final Logger LOGGER = LogManager.getLogger(LoggingHelper.class);

    private static final String SECTION_OPEN = "=== API Response Details ===";
    private static final String SECTION_CLOSE = "=== End Response Details ===";

    private LoggingHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    /**
     * Logs status, headers, and pretty-printed JSON body for the given response.
     *
     * @param response Rest Assured response (must not be null)
     */
    public static void logResponseDetails(Response response) {
        if (response == null) {
            LOGGER.warn("logResponseDetails called with null response");
            return;
        }
        LOGGER.info(SECTION_OPEN);
        LOGGER.info("Status Code: {}", response.getStatusCode());
        LOGGER.info("Status Line: {}", response.getStatusLine());

        LOGGER.info("Response Headers:");
        response.getHeaders().forEach(header ->
                LOGGER.info("  {}: {}", header.getName(), header.getValue()));

        logResponseBody(response);
        LOGGER.info(SECTION_CLOSE);
    }

    /**
     * Logs only the body, attempting to pretty-print JSON. Safe for non-JSON content.
     */
    public static void logResponseBody(Response response) {
        if (response == null) {
            return;
        }
        String body = response.getBody().asString();
        if (body == null || body.isEmpty()) {
            LOGGER.info("Response Body: (empty)");
            return;
        }
        String contentType = response.getContentType();
        if (contentType != null && contentType.contains("json")) {
            try {
                LOGGER.info("Response Body:\n{}", JsonUtils.prettyPrint(body));
                return;
            } catch (Exception ignored) {
                // fall through to raw body
            }
        }
        LOGGER.info("Response Body: {}", body);
    }
}
