package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.RecoveryVariablesValidator;


public class RecoveryVariablesStepDefinitions {

    private static final Logger logger = LogManager.getLogger(RecoveryVariablesStepDefinitions.class);

    private final TestContext testContext;
    private final RecoveryVariablesValidator recoveryVariablesValidator;

    public RecoveryVariablesStepDefinitions(
            TestContext testContext,
            RecoveryVariablesValidator recoveryVariablesValidator
    ) {
        this.testContext = testContext;
        this.recoveryVariablesValidator = recoveryVariablesValidator;
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

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
