package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.QuickAllocationValidator;


/**
 * Domain-specific assertions for POST /recovery/allocation (quick_allocation).
 * Generic assertions (status code, field presence/value, schema match, not-empty) are reused from ApiStepDefinitions.
 */
public class QuickAllocationStepDefinitions {

    private static final Logger logger = LogManager.getLogger(QuickAllocationStepDefinitions.class);

    private final TestContext testContext;
    private final QuickAllocationValidator quickAllocationValidator;

    public QuickAllocationStepDefinitions(TestContext testContext, QuickAllocationValidator quickAllocationValidator) {
        this.testContext = testContext;
        this.quickAllocationValidator = quickAllocationValidator;
    }

    @Then("the quick allocation success response should be valid")
    public void the_quick_allocation_success_response_should_be_valid() {
        quickAllocationValidator.validateSuccessEnvelope(activeResponse());
        logger.info("quick allocation success validation completed");
    }

    @Then("the quick allocation failure response should be valid")
    public void the_quick_allocation_failure_response_should_be_valid() {
        quickAllocationValidator.validateFailureEnvelope(activeResponse());
        logger.info("quick allocation failure validation completed");
    }

    @Then("the quick allocation multi-loan rejection response should be valid")
    public void the_quick_allocation_multi_loan_rejection_response_should_be_valid() {
        quickAllocationValidator.validateMultiLoanRejection(activeResponse());
        logger.info("quick allocation multi-loan rejection validation completed");
    }

    @Then("the quick allocation field one-to-many rejection response should be valid")
    public void the_quick_allocation_field_one_to_many_rejection_response_should_be_valid() {
        quickAllocationValidator.validateFieldOneToManyRejection(activeResponse());
        logger.info("quick allocation field+one_to_many rejection validation completed");
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
