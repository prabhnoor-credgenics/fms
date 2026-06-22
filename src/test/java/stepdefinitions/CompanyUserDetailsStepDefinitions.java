package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyUserDetailsValidator;


public class CompanyUserDetailsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyUserDetailsStepDefinitions.class);

    private final TestContext testContext;
    private final CompanyUserDetailsValidator validator;

    public CompanyUserDetailsStepDefinitions(TestContext testContext, CompanyUserDetailsValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the company user details success response should be valid")
    public void the_company_user_details_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company user details failure response should be valid")
    public void the_company_user_details_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
