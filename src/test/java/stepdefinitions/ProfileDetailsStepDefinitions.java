package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ProfileDetailsValidator;


public class ProfileDetailsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ProfileDetailsStepDefinitions.class);

    private final ProfileDetailsValidator validator;

    public ProfileDetailsStepDefinitions(TestContext testContext, ProfileDetailsValidator validator) {
        super(testContext);
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
}
