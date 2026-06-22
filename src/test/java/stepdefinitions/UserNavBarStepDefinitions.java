package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.UserNavBarValidator;


public class UserNavBarStepDefinitions {

    private static final Logger logger = LogManager.getLogger(UserNavBarStepDefinitions.class);

    private final TestContext testContext;
    private final UserNavBarValidator validator;

    public UserNavBarStepDefinitions(TestContext testContext, UserNavBarValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the user nav bar success response should be valid")
    public void the_user_nav_bar_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the user nav bar failure response should be valid")
    public void the_user_nav_bar_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
