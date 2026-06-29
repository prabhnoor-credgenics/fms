package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.UsersFilterValidator;


public class UsersFilterStepDefinitions {

    private static final Logger logger = LogManager.getLogger(UsersFilterStepDefinitions.class);

    private final TestContext testContext;
    private final UsersFilterValidator validator;

    public UsersFilterStepDefinitions(TestContext testContext, UsersFilterValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the users filter success response should be valid")
    public void the_users_filter_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the users filter failure response should be valid")
    public void the_users_filter_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
