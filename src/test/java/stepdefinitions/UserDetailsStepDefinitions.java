package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import validators.business.UserDetailsValidator;


public class UserDetailsStepDefinitions extends BaseStepDefinitions {

    private final UserDetailsValidator validator;

    public UserDetailsStepDefinitions(TestContext testContext, UserDetailsValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the user details success response should be valid")
    public void the_user_details_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }
}
