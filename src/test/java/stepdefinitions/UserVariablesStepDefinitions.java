package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.UserVariablesValidator;


public class UserVariablesStepDefinitions {

    private static final Logger logger = LogManager.getLogger(UserVariablesStepDefinitions.class);

    private final TestContext testContext;
    private final UserVariablesValidator validator;

    public UserVariablesStepDefinitions(TestContext testContext, UserVariablesValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the user variables success response should be valid")
    public void the_user_variables_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the user variables failure response should be valid")
    public void the_user_variables_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
