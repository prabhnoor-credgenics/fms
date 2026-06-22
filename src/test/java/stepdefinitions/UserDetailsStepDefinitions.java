package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.UserDetailsValidator;


public class UserDetailsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(UserDetailsStepDefinitions.class);

    private final TestContext testContext;
    private final UserDetailsValidator validator;

    public UserDetailsStepDefinitions(TestContext testContext, UserDetailsValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the user details success response should be valid")
    public void the_user_details_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the user details failure response should be valid")
    public void the_user_details_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
