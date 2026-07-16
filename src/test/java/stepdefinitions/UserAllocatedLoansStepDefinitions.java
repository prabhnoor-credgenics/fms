package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.UserAllocatedLoansValidator;


public class UserAllocatedLoansStepDefinitions {

    private static final Logger logger = LogManager.getLogger(UserAllocatedLoansStepDefinitions.class);

    private final TestContext testContext;
    private final UserAllocatedLoansValidator validator;

    public UserAllocatedLoansStepDefinitions(TestContext testContext, UserAllocatedLoansValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the user allocated loans success response should be valid")
    public void the_user_allocated_loans_success_response_should_be_valid() {
        validator.validateSuccessShape(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
