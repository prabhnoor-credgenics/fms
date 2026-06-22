package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanAllocatedUserValidator;

public class ExportLoanAllocatedUserStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanAllocatedUserStepDefinitions.class);

    private final TestContext testContext;
    private final ExportLoanAllocatedUserValidator validator;

    public ExportLoanAllocatedUserStepDefinitions(TestContext testContext, ExportLoanAllocatedUserValidator validator) {
        this.testContext = testContext;
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

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
