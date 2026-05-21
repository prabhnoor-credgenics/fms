package helpers;

import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.LinkedHashMap;
import java.util.Map;

import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;


public final class SchemaHelper {

    private static final Logger LOGGER = LogManager.getLogger(SchemaHelper.class);

    private static final Map<String, String> DEFAULT_MAPPINGS = new LinkedHashMap<>();
    private static final Map<String, String> REQUEST_BODY_MAPPINGS = new LinkedHashMap<>();

    static {
        DEFAULT_MAPPINGS.put("/recovery/v1/loan", "schemas/loan_recovery_success_schema.json");
        DEFAULT_MAPPINGS.put("/recovery/company", "schemas/recovery_company_success_schema.json");
        DEFAULT_MAPPINGS.put("/recovery/global-status", "schemas/global_status_success_schema.json");
        DEFAULT_MAPPINGS.put("/recovery/variables", "schemas/recovery_variables_success_schema.json");
        DEFAULT_MAPPINGS.put("/recovery/loan-stage/config", "schemas/loan_stage_config_success_schema.json");
        DEFAULT_MAPPINGS.put("/recovery/exports", "schemas/recovery_exports_success_schema.json");

        
        
        
        
        REQUEST_BODY_MAPPINGS.put("test-data/loan_recovery_request.json",
                "schemas/loan_upload_request_schema.json");
        REQUEST_BODY_MAPPINGS.put("test-data/company_creation_step1.json",
                "schemas/company_creation_step1_request_schema.json");
        REQUEST_BODY_MAPPINGS.put("test-data/company_creation_step2.json",
                "schemas/company_creation_step2_request_schema.json");
        REQUEST_BODY_MAPPINGS.put("test-data/company_creation_step3.json",
                "schemas/company_creation_step3_request_schema.json");
        DEFAULT_MAPPINGS.put("/recovery/loan/", "schemas/loan_recovery_success_schema.json");
    }

    private SchemaHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    
    public static void register(String endpointSubstring, String schemaClasspath) {
        DEFAULT_MAPPINGS.put(endpointSubstring, schemaClasspath);
    }

    
    public static void registerRequestSchema(String testDataPathSubstring, String schemaClasspath) {
        REQUEST_BODY_MAPPINGS.put(testDataPathSubstring, schemaClasspath);
    }

    
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

    public static void validateRequestBody(String requestBody, String schemaClasspath) {
        if (requestBody == null || requestBody.isBlank()) {
            throw new IllegalArgumentException("Request body must not be blank for schema validation");
        }
        org.hamcrest.MatcherAssert.assertThat(
                "Request body failed schema validation against " + schemaClasspath,
                requestBody,
                matchesJsonSchemaInClasspath(schemaClasspath)
        );
        LOGGER.info("Request body schema validation passed for: {}", schemaClasspath);
    }
}
