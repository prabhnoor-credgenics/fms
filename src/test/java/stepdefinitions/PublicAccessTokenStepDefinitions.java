package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.PublicAccessTokenValidator;


public class PublicAccessTokenStepDefinitions {

    private static final Logger logger = LogManager.getLogger(PublicAccessTokenStepDefinitions.class);

    private final TestContext testContext;
    private final PublicAccessTokenValidator validator;

    public PublicAccessTokenStepDefinitions(TestContext testContext, PublicAccessTokenValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the public access token success response should be valid")
    public void the_public_access_token_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the public access token failure response should be valid")
    public void the_public_access_token_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
