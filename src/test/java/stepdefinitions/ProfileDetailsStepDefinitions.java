package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ProfileDetailsValidator;


public class ProfileDetailsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ProfileDetailsStepDefinitions.class);

    private final TestContext testContext;
    private final ProfileDetailsValidator validator;

    public ProfileDetailsStepDefinitions(TestContext testContext, ProfileDetailsValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the profile details success response should be valid")
    public void the_profile_details_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the profile details failure response should be valid")
    public void the_profile_details_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
