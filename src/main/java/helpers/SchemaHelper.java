package helpers;

import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.LinkedHashMap;
import java.util.Map;

import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;

/**
 * Endpoint → success-response JSON schema mapping for automatic contract checks on 2xx responses.
 *
 * <p>Add new endpoints by inserting a {@link #register(String, String)} call (or modifying
 * {@link #DEFAULT_MAPPINGS}) — keeps the schema registry in one place instead of scattered
 * {@code if}/{@code else} chains in step definitions.
 */
public final class SchemaHelper {

    private static final Logger LOGGER = LogManager.getLogger(SchemaHelper.class);

    private static final Map<String, String> DEFAULT_MAPPINGS = new LinkedHashMap<>();
    private static final Map<String, String> REQUEST_BODY_MAPPINGS = new LinkedHashMap<>();

    static {
        DEFAULT_MAPPINGS.put("/recovery/v1/loan", "schemas/loan_recovery_success_schema.json");
        DEFAULT_MAPPINGS.put("/recovery/company", "schemas/recovery_company_success_schema.json");

        // Request-body contract checks: validate the canonical payload template loaded from
        // {@code test-data/...} files before the API call. Mutations performed via
        // {@code I update JSON field ...} happen AFTER this step, so negative scenarios
        // that intentionally corrupt fields are unaffected.
        REQUEST_BODY_MAPPINGS.put("test-data/loan_recovery_request.json",
                "schemas/loan_upload_request_schema.json");
    }

    private SchemaHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    /**
     * Adds or overrides an endpoint substring → schema mapping at runtime (useful for tests).
     */
    public static void register(String endpointSubstring, String schemaClasspath) {
        DEFAULT_MAPPINGS.put(endpointSubstring, schemaClasspath);
    }

    /**
     * Adds or overrides a request-body source path → schema mapping at runtime.
     */
    public static void registerRequestSchema(String testDataPathSubstring, String schemaClasspath) {
        REQUEST_BODY_MAPPINGS.put(testDataPathSubstring, schemaClasspath);
    }

    /**
     * Validates the response against its registered success schema when the status is 2xx and the
     * endpoint matches a known mapping. No-op when status is non-2xx or no mapping exists.
     *
     * @param endpoint   request endpoint (may contain path placeholders)
     * @param statusCode response status code
     * @param response   Rest Assured response (must not be null)
     */
    public static void autoValidateSuccessSchema(String endpoint, int statusCode, Response response) {
        if (response == null) {
            return;
        }
        if (statusCode < 200 || statusCode >= 300) {
            LOGGER.debug("Skipping auto schema validation for non-2xx status {}", statusCode);
            return;
        }
        if (endpoint == null) {
            return;
        }
        for (Map.Entry<String, String> entry : DEFAULT_MAPPINGS.entrySet()) {
            if (endpoint.contains(entry.getKey())) {
                response.then().assertThat().body(matchesJsonSchemaInClasspath(entry.getValue()));
                LOGGER.info("Auto schema validation passed for endpoint '{}' using '{}'",
                        endpoint, entry.getValue());
                return;
            }
        }
        LOGGER.info("No auto schema mapping configured for endpoint '{}'", endpoint);
    }

    /**
     * Validates the JSON request body against the schema registered for the given test-data source
     * path. No-op when no mapping is configured. Throws a Hamcrest assertion error when the body
     * does not satisfy the schema, surfacing the offending field paths in the failure message.
     *
     * @param testDataPath path used to load the request body (e.g. {@code "test-data/loan_recovery_request.json"})
     * @param requestBody  resolved request body (placeholders already substituted)
     */
    public static void autoValidateRequestSchema(String testDataPath, String requestBody) {
        if (testDataPath == null || requestBody == null || requestBody.isEmpty()) {
            return;
        }
        for (Map.Entry<String, String> entry : REQUEST_BODY_MAPPINGS.entrySet()) {
            if (testDataPath.contains(entry.getKey())) {
                org.hamcrest.MatcherAssert.assertThat(
                        "Request body loaded from '" + testDataPath + "' failed schema validation",
                        requestBody,
                        matchesJsonSchemaInClasspath(entry.getValue())
                );
                LOGGER.info("Auto request schema validation passed for '{}' using '{}'",
                        testDataPath, entry.getValue());
                return;
            }
        }
        LOGGER.debug("No request-body schema mapping configured for '{}'", testDataPath);
    }
}
