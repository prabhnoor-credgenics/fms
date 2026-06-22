package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.InternalBulkLoansValidator;


public class InternalBulkLoansStepDefinitions {

    private static final Logger logger = LogManager.getLogger(InternalBulkLoansStepDefinitions.class);

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final InternalBulkLoansValidator validator;

    public InternalBulkLoansStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver,
            InternalBulkLoansValidator validator
    ) {
        this.testContext = testContext;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.validator = validator;
    }

    @Then("the internal bulk loans success response should be valid")
    public void the_internal_bulk_loans_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the internal bulk loans response should contain loan {string}")
    public void the_internal_bulk_loans_response_should_contain_loan(String loanId) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(loanId);
        validator.validateLoanPresent(activeResponse(), resolved);
        logger.info("internal bulk loans data-presence validated for {}", resolved);
    }

    @Then("the internal bulk loans validation error should be valid")
    public void the_internal_bulk_loans_validation_error_should_be_valid() {
        validator.validateValidationError(activeResponse());
    }

    @Then("the internal bulk loans failure response should be valid")
    public void the_internal_bulk_loans_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    @Then("the internal bulk loans error code should be {string}")
    public void the_internal_bulk_loans_error_code_should_be(String code) {
        validator.validateErrorCode(activeResponse(), code);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
