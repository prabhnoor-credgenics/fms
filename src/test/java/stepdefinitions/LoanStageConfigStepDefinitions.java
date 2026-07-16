package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.LoanStageConfigValidator;


public class LoanStageConfigStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(LoanStageConfigStepDefinitions.class);

    private final LoanStageConfigValidator loanStageConfigValidator;

    public LoanStageConfigStepDefinitions(
            TestContext testContext,
            LoanStageConfigValidator loanStageConfigValidator
    ) {
        super(testContext);
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
}
