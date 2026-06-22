package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyTypeValidator;


public class CompanyTypeStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyTypeStepDefinitions.class);

    private final TestContext testContext;
    private final CompanyTypeValidator validator;

    public CompanyTypeStepDefinitions(TestContext testContext, CompanyTypeValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the company type success response should be valid")
    public void the_company_type_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company type failure response should be valid")
    public void the_company_type_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
