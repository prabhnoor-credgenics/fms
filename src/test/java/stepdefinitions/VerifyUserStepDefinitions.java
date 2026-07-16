package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import validators.business.VerifyUserValidator;


public class VerifyUserStepDefinitions extends BaseStepDefinitions {

    private final VerifyUserValidator validator;

    public VerifyUserStepDefinitions(TestContext testContext, VerifyUserValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the verify user success response should be valid")
    public void the_verify_user_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the verify user failure response should be valid")
    public void the_verify_user_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
