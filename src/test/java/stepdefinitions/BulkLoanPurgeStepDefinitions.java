package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.BulkLoanPurgeValidator;


/**
 * Domain-specific assertions for DELETE /recovery/bulk/loan (data purging).
 * Generic assertions (status code, field presence/value, schema match) are reused from ApiStepDefinitions.
 */
public class BulkLoanPurgeStepDefinitions {

    private static final Logger logger = LogManager.getLogger(BulkLoanPurgeStepDefinitions.class);

    private final TestContext testContext;
    private final BulkLoanPurgeValidator bulkLoanPurgeValidator;

    public BulkLoanPurgeStepDefinitions(TestContext testContext, BulkLoanPurgeValidator bulkLoanPurgeValidator) {
        this.testContext = testContext;
        this.bulkLoanPurgeValidator = bulkLoanPurgeValidator;
    }

    @Then("the bulk loan purge success response should be valid")
    public void the_bulk_loan_purge_success_response_should_be_valid() {
        bulkLoanPurgeValidator.validatePurgeSuccess(activeResponse());
        logger.info("bulk loan purge success validation completed");
    }

    @Then("the bulk loan purge forbidden response should be valid")
    public void the_bulk_loan_purge_forbidden_response_should_be_valid() {
        bulkLoanPurgeValidator.validateForbiddenEnvelope(activeResponse());
        logger.info("bulk loan purge forbidden validation completed");
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
