package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanWithAllocatedUsersValidator;

public class ExportLoanWithAllocatedUsersStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanWithAllocatedUsersStepDefinitions.class);

    private final TestContext testContext;
    private final ExportLoanWithAllocatedUsersValidator validator;

    public ExportLoanWithAllocatedUsersStepDefinitions(TestContext testContext, ExportLoanWithAllocatedUsersValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the export loan with allocated users success response should be valid")
    public void the_export_loan_with_allocated_users_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the export loan with allocated users failure response should be valid")
    public void the_export_loan_with_allocated_users_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
