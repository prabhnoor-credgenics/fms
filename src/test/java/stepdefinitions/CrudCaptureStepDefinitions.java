package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Generic, reusable steps to capture an id from the last response into one of the existing
 * scenario id slots so it can be referenced later in the same scenario:
 *   - "... as variable id"  -> {VARIABLE_ID}  (TestContext.scenarioVariableId)
 *   - "... as mapping id"   -> {MAPPING_ID}   (TestContext.scenarioMappingId)
 *
 * Used to chain create -> read-back -> update -> delete for user-service CRUD resources
 * (roles, profiles, users) without adding resource-specific capture steps. The JSON path is
 * resolved against the active response body (e.g. "data.role_id", "data.roles[0].role_id").
 */
public class CrudCaptureStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CrudCaptureStepDefinitions.class);

    private final TestContext testContext;

    public CrudCaptureStepDefinitions(TestContext testContext) {
        this.testContext = testContext;
    }

    @Then("I store response field {string} as variable id")
    public void i_store_response_field_as_variable_id(String jsonPath) {
        String value = activeResponse().jsonPath().getString(jsonPath);
        if (value == null || value.isBlank()) {
            throw new AssertionError("Response field '" + jsonPath + "' is missing/blank; cannot store as variable id. Body: "
                    + activeResponse().getBody().asString());
        }
        testContext.setScenarioVariableId(value);
        logger.info("Stored response field '{}' = '{}' as {{VARIABLE_ID}}", jsonPath, value);
    }

    @Then("I store response field {string} as mapping id")
    public void i_store_response_field_as_mapping_id(String jsonPath) {
        String value = activeResponse().jsonPath().getString(jsonPath);
        if (value == null || value.isBlank()) {
            throw new AssertionError("Response field '" + jsonPath + "' is missing/blank; cannot store as mapping id. Body: "
                    + activeResponse().getBody().asString());
        }
        testContext.setScenarioMappingId(value);
        logger.info("Stored response field '{}' = '{}' as {{MAPPING_ID}}", jsonPath, value);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
