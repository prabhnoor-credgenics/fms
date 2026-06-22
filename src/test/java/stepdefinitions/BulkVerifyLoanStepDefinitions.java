package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.BulkVerifyLoanValidator;


public class BulkVerifyLoanStepDefinitions {

    private static final Logger logger = LogManager.getLogger(BulkVerifyLoanStepDefinitions.class);

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final BulkVerifyLoanValidator validator;

    public BulkVerifyLoanStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver,
            BulkVerifyLoanValidator validator
    ) {
        this.testContext = testContext;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.validator = validator;
    }

    @Then("the bulk verify loan success response should be valid")
    public void the_bulk_verify_loan_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the bulk verify loan response should verify loan {string}")
    public void the_bulk_verify_loan_response_should_verify_loan(String loanId) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(loanId);
        validator.validateLoanVerified(activeResponse(), resolved);
        logger.info("bulk verify loan verified-presence validated for {}", resolved);
    }

    @Then("the bulk verify loan failure response should be valid")
    public void the_bulk_verify_loan_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
