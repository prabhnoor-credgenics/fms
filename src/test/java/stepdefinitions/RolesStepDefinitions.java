package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.RolesValidator;

public class RolesStepDefinitions {

    private static final Logger logger = LogManager.getLogger(RolesStepDefinitions.class);

    private final TestContext testContext;
    private final RolesValidator validator;

    public RolesStepDefinitions(TestContext testContext, RolesValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }


    @Then("the role mutation response should be valid")
    public void the_role_mutation_response_should_be_valid() {
        validator.validateMutationResponse(activeResponse());
    }

    @Then("the roles list response should be valid")
    public void the_roles_list_response_should_be_valid() {
        validator.validateListResponse(activeResponse());
    }

    @Then("the role details response should be valid")
    public void the_role_details_response_should_be_valid() {
        validator.validateDetailsResponse(activeResponse());
    }


    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
