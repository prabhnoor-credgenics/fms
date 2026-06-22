package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import validators.business.LoanUpdateValidator;


public class LoanUpdateStepDefinitions extends BaseStepDefinitions {

    private final LoanUpdateValidator validator;

    public LoanUpdateStepDefinitions(TestContext testContext, LoanUpdateValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the loan update success response should be valid")
    public void the_loan_update_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the loan update failure response should be valid")
    public void the_loan_update_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
