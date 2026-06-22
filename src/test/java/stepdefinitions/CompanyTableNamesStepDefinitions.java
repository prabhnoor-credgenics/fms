package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyTableNamesValidator;


public class CompanyTableNamesStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyTableNamesStepDefinitions.class);

    private final TestContext testContext;
    private final CompanyTableNamesValidator validator;

    public CompanyTableNamesStepDefinitions(TestContext testContext, CompanyTableNamesValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the company table names success response should be valid")
    public void the_company_table_names_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company table names failure response should be valid")
    public void the_company_table_names_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
