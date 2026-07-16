package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanAllocatedUserValidator;

public class ExportLoanAllocatedUserStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanAllocatedUserStepDefinitions.class);

    private final ExportLoanAllocatedUserValidator validator;

    public ExportLoanAllocatedUserStepDefinitions(TestContext testContext, ExportLoanAllocatedUserValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the export loan allocated user success response should be valid")
    public void the_export_loan_allocated_user_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the export loan allocated user failure response should be valid")
    public void the_export_loan_allocated_user_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
