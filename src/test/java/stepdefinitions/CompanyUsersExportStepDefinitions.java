package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyUsersExportValidator;


public class CompanyUsersExportStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyUsersExportStepDefinitions.class);

    private final TestContext testContext;
    private final CompanyUsersExportValidator validator;

    public CompanyUsersExportStepDefinitions(TestContext testContext, CompanyUsersExportValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the company users export success response should be valid")
    public void the_company_users_export_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company users export failure response should be valid")
    public void the_company_users_export_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
