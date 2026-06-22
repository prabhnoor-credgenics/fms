package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanWithAllocatedUsersValidator;

public class ExportLoanWithAllocatedUsersStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanWithAllocatedUsersStepDefinitions.class);

    private final ExportLoanWithAllocatedUsersValidator validator;

    public ExportLoanWithAllocatedUsersStepDefinitions(TestContext testContext, ExportLoanWithAllocatedUsersValidator validator) {
        super(testContext);
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
}
