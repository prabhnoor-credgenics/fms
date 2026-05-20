package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.LoanStageConfigValidator;


public class LoanStageConfigStepDefinitions {

    private static final Logger logger = LogManager.getLogger(LoanStageConfigStepDefinitions.class);

    private final TestContext testContext;
    private final LoanStageConfigValidator loanStageConfigValidator;

    public LoanStageConfigStepDefinitions(
            TestContext testContext,
            LoanStageConfigValidator loanStageConfigValidator
    ) {
        this.testContext = testContext;
        this.loanStageConfigValidator = loanStageConfigValidator;
    }

    @Then("loan stage config response mandatory fields should be valid")
    public void loan_stage_config_response_mandatory_fields_should_be_valid() {
        loanStageConfigValidator.validateMandatoryFields(activeResponse());
        logger.info("Loan stage config mandatory fields validation completed");
    }

    @Then("loan stage config company_id should match requested company")
    public void loan_stage_config_company_id_should_match_requested_company() {
        loanStageConfigValidator.validateCompanyIdMapping(activeResponse());
        logger.info("Loan stage config company_id mapping validation completed");
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
