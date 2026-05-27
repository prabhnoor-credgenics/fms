package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.RecoveryVariablesValidator;

import java.util.List;
import java.util.Map;


public class RecoveryVariablesStepDefinitions {

    private static final Logger logger = LogManager.getLogger(RecoveryVariablesStepDefinitions.class);

    private final TestContext testContext;
    private final RecoveryVariablesValidator recoveryVariablesValidator;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public RecoveryVariablesStepDefinitions(
            TestContext testContext,
            RecoveryVariablesValidator recoveryVariablesValidator,
            ScenarioTestDataResolver scenarioTestDataResolver
    ) {
        this.testContext = testContext;
        this.recoveryVariablesValidator = recoveryVariablesValidator;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    @Then("recovery variables response mandatory fields should be valid")
    public void recovery_variables_response_mandatory_fields_should_be_valid() {
        recoveryVariablesValidator.validateMandatoryFields(activeResponse());
        logger.info("Recovery variables mandatory fields validation completed");
    }

    @Then("recovery variables should match requested company")
    public void recovery_variables_should_match_requested_company() {
        recoveryVariablesValidator.validateCompanyIdMapping(activeResponse());
        logger.info("Recovery variables company mapping validation completed");
    }

    @Then("recovery variables computed variables should be included")
    public void recovery_variables_computed_variables_should_be_included() {
        recoveryVariablesValidator.validateComputedVariablesIncluded(activeResponse());
        logger.info("Recovery variables computed-variables inclusion validation completed");
    }

    @Then("recovery variables computed variables should be excluded")
    public void recovery_variables_computed_variables_should_be_excluded() {
        recoveryVariablesValidator.validateComputedVariablesExcluded(activeResponse());
        logger.info("Recovery variables computed-variables exclusion validation completed");
    }

    @Then("recovery variables response is saved for computed variables comparison")
    public void recovery_variables_response_is_saved_for_computed_variables_comparison() {
        testContext.setSavedComparisonResponse(activeResponse());
        logger.info("Recovery variables response saved for computed-variables comparison");
    }

    @Then("recovery variables response should differ from saved when computed variables are disabled")
    public void recovery_variables_response_should_differ_from_saved_when_computed_variables_are_disabled() {
        Response baselineWithComputed = testContext.getSavedComparisonResponse();
        if (baselineWithComputed == null) {
            throw new IllegalStateException(
                    "No saved comparison response. Run step to save response with include_computed_variables=true first."
            );
        }
        recoveryVariablesValidator.validateResponseDiffersWhenComputedDisabled(
                baselineWithComputed,
                activeResponse()
        );
        logger.info("Recovery variables response diff validation completed");
    }

    @Then("recovery variables meta data should be included")
    public void recovery_variables_meta_data_should_be_included() {
        recoveryVariablesValidator.validateMetaDataIncluded(activeResponse());
        logger.info("Recovery variables meta-data inclusion validation completed");
    }

    @Then("recovery variables meta data should be excluded")
    public void recovery_variables_meta_data_should_be_excluded() {
        recoveryVariablesValidator.validateMetaDataExcluded(activeResponse());
        logger.info("Recovery variables meta-data exclusion validation completed");
    }

    @Then("recovery variables response is saved for meta data comparison")
    public void recovery_variables_response_is_saved_for_meta_data_comparison() {
        testContext.setSavedComparisonResponse(activeResponse());
        logger.info("Recovery variables response saved for meta-data comparison");
    }

    @Then("recovery variables response should differ from saved when meta data is disabled")
    public void recovery_variables_response_should_differ_from_saved_when_meta_data_is_disabled() {
        Response baselineWithMeta = testContext.getSavedComparisonResponse();
        if (baselineWithMeta == null) {
            throw new IllegalStateException(
                    "No saved comparison response. Run step to save response with include_meta_data=true first."
            );
        }
        recoveryVariablesValidator.validateResponseDiffersWhenMetaDisabled(
                baselineWithMeta,
                activeResponse()
        );
        logger.info("Recovery variables meta-data diff validation completed");
    }

    @Then("recovery variables response is saved for full payload comparison")
    public void recovery_variables_response_is_saved_for_full_payload_comparison() {
        testContext.setSavedComparisonResponse(activeResponse());
        logger.info("Recovery variables response saved for full-payload comparison");
    }

    @Then("recovery variables response should differ from saved when computed variables and meta data are disabled")
    public void recovery_variables_response_should_differ_from_saved_when_computed_variables_and_meta_data_are_disabled() {
        Response baselineFull = testContext.getSavedComparisonResponse();
        if (baselineFull == null) {
            throw new IllegalStateException(
                    "No saved comparison response. Run step to save response with both flags true first."
            );
        }
        recoveryVariablesValidator.validateResponseDiffersWhenBothFlagsDisabled(
                baselineFull,
                activeResponse()
        );
        logger.info("Recovery variables full-payload diff validation completed");
    }

    @Then("I store the first variable id from the response list")
    public void i_store_the_first_variable_id_from_the_response_list() {
        Response response = activeResponse();
        List<Map<String, Object>> output = response.jsonPath().getList("output");
        if (output == null || output.isEmpty()) {
            throw new IllegalStateException(
                    "No variables found in response output. Ensure GET /recovery/variables returned a non-empty list."
            );
        }
        Object idObj = output.get(0).get("variable_id");
        if (idObj == null) {
            throw new IllegalStateException("First variable in output has no variable_id field.");
        }
        String variableId = idObj.toString();
        testContext.setScenarioVariableId(variableId);
        logger.info("Stored first variable id from list: {}", variableId);
    }

    @Then("I find and store variable id for name {string} from variables response")
    public void i_find_and_store_variable_id_for_name(String namePattern) {
        String resolvedName = scenarioTestDataResolver.replaceScenarioPlaceholders(namePattern);
        Response response = activeResponse();
        List<Map<String, Object>> output = response.jsonPath().getList("output");
        String variableId = findVariableIdByName(output, resolvedName);
        if (variableId == null || variableId.isBlank()) {
            throw new IllegalStateException(
                    "Variable with name '" + resolvedName + "' not found in GET /recovery/variables response"
            );
        }
        testContext.setScenarioVariableId(variableId);
        logger.info("Found and stored variable id {} for name '{}'", variableId, resolvedName);
    }

    private String findVariableIdByName(List<Map<String, Object>> variables, String name) {
        if (variables == null) return null;
        for (Map<String, Object> item : variables) {
            if (name.equals(item.get("variable_name"))) {
                Object idObj = item.get("variable_id");
                if (idObj != null) return idObj.toString();
            }
            Object subVars = item.get("sub_variables");
            if (subVars instanceof List<?>) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> nested = (List<Map<String, Object>>) subVars;
                String found = findVariableIdByName(nested, name);
                if (found != null) return found;
            }
        }
        return null;
    }

    @Then("I store the created variable id from response")
    public void i_store_the_created_variable_id_from_response() {
        Response response = activeResponse();
        JsonPath jp = response.jsonPath();

        String variableId = jp.getString("output.variable_id");

        if (variableId == null || variableId.isBlank()) {
            List<String> ids = jp.getList("output.variable_id");
            if (ids != null && !ids.isEmpty()) {
                variableId = ids.get(0);
            }
        }

        if (variableId == null || variableId.isBlank()) {
            throw new IllegalStateException(
                    "Cannot extract variable_id from response. Ensure the POST succeeded and returns output.variable_id."
            );
        }

        testContext.setScenarioVariableId(variableId);
        logger.info("Stored created variable id: {}", variableId);
    }

    @Then("recovery variables create response should be valid")
    public void recovery_variables_create_response_should_be_valid() {
        recoveryVariablesValidator.validateCreateVariableResponse(activeResponse());
        logger.info("Recovery variables create response validation completed");
    }

    @Then("recovery variables update response should be valid")
    public void recovery_variables_update_response_should_be_valid() {
        recoveryVariablesValidator.validateUpdateVariableResponse(activeResponse());
        logger.info("Recovery variables update response validation completed");
    }

    @Then("recovery variables delete response should be valid")
    public void recovery_variables_delete_response_should_be_valid() {
        recoveryVariablesValidator.validateDeleteVariableResponse(activeResponse());
        logger.info("Recovery variables delete response validation completed");
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
