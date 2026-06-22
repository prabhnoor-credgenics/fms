package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import validators.business.ProfilesListValidator;


public class ProfilesListStepDefinitions extends BaseStepDefinitions {

    private final ProfilesListValidator validator;

    public ProfilesListStepDefinitions(TestContext testContext, ProfilesListValidator validator) {
        super(testContext);
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
}
