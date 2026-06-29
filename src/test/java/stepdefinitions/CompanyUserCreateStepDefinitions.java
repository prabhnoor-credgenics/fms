package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyUserCreateValidator;


public class CompanyUserCreateStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyUserCreateStepDefinitions.class);

    private final TestContext testContext;
    private final CompanyUserCreateValidator validator;

    public CompanyUserCreateStepDefinitions(TestContext testContext, CompanyUserCreateValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the company user create success response should be valid")
    public void the_company_user_create_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company user create failure response should be valid")
    public void the_company_user_create_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
