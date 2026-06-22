package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyPermissionsValidator;


public class CompanyPermissionsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyPermissionsStepDefinitions.class);

    private final TestContext testContext;
    private final CompanyPermissionsValidator validator;

    public CompanyPermissionsStepDefinitions(TestContext testContext, CompanyPermissionsValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the company permissions success response should be valid")
    public void the_company_permissions_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company permissions failure response should be valid")
    public void the_company_permissions_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
