package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import validators.business.UserNavBarValidator;


public class UserNavBarStepDefinitions extends BaseStepDefinitions {

    private final UserNavBarValidator validator;

    public UserNavBarStepDefinitions(TestContext testContext, UserNavBarValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the user nav bar success response should be valid")
    public void the_user_nav_bar_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }
}
