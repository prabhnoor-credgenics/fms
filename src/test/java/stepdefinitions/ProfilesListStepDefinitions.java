package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ProfilesListValidator;


public class ProfilesListStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ProfilesListStepDefinitions.class);

    private final TestContext testContext;
    private final ProfilesListValidator validator;

    public ProfilesListStepDefinitions(TestContext testContext, ProfilesListValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the profiles list success response should be valid")
    public void the_profiles_list_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the profiles list failure response should be valid")
    public void the_profiles_list_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
