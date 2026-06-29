package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.AssignedCompaniesValidator;


public class AssignedCompaniesStepDefinitions {

    private static final Logger logger = LogManager.getLogger(AssignedCompaniesStepDefinitions.class);

    private final TestContext testContext;
    private final AssignedCompaniesValidator validator;

    public AssignedCompaniesStepDefinitions(TestContext testContext, AssignedCompaniesValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the assigned companies success response should be valid")
    public void the_assigned_companies_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the assigned companies failure response should be valid")
    public void the_assigned_companies_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
