package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.GlobalUserCreateValidator;
import validators.business.GlobalUsersListValidator;

public class GlobalUsersStepDefinitions {

    private static final Logger logger = LogManager.getLogger(GlobalUsersStepDefinitions.class);

    private final TestContext testContext;
    private final GlobalUsersListValidator listValidator;
    private final GlobalUserCreateValidator createValidator;

    public GlobalUsersStepDefinitions(TestContext testContext,
                                      GlobalUsersListValidator listValidator,
                                      GlobalUserCreateValidator createValidator) {
        this.testContext = testContext;
        this.listValidator = listValidator;
        this.createValidator = createValidator;
    }

    @Then("the global users list response should be valid")
    public void the_global_users_list_response_should_be_valid() {
        listValidator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the global user create response should be valid")
    public void the_global_user_create_response_should_be_valid() {
        createValidator.validateSuccessShape(activeResponse());
    }


    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
