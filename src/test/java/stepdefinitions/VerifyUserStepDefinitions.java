package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.VerifyUserValidator;


public class VerifyUserStepDefinitions {

    private static final Logger logger = LogManager.getLogger(VerifyUserStepDefinitions.class);

    private final TestContext testContext;
    private final VerifyUserValidator validator;

    public VerifyUserStepDefinitions(TestContext testContext, VerifyUserValidator validator) {
        this.testContext = testContext;
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

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
