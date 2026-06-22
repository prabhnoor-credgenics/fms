package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.InternalCompanyUsersValidator;


public class InternalCompanyUsersStepDefinitions {

    private static final Logger logger = LogManager.getLogger(InternalCompanyUsersStepDefinitions.class);

    private final TestContext testContext;
    private final InternalCompanyUsersValidator validator;

    public InternalCompanyUsersStepDefinitions(TestContext testContext, InternalCompanyUsersValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the internal company users success response should be valid")
    public void the_internal_company_users_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the internal company users failure response should be valid")
    public void the_internal_company_users_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
