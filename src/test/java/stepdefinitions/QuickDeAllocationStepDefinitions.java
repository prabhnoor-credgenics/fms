package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.QuickDeAllocationValidator;


/**
 * Domain-specific assertions for POST /recovery/deallocation (quick_deallocation).
 * Generic assertions (status code, field presence/value, schema match, not-empty) are reused from ApiStepDefinitions.
 */
public class QuickDeAllocationStepDefinitions {

    private static final Logger logger = LogManager.getLogger(QuickDeAllocationStepDefinitions.class);

    private final TestContext testContext;
    private final QuickDeAllocationValidator quickDeAllocationValidator;

    public QuickDeAllocationStepDefinitions(TestContext testContext, QuickDeAllocationValidator quickDeAllocationValidator) {
        this.testContext = testContext;
        this.quickDeAllocationValidator = quickDeAllocationValidator;
    }

    @Then("the quick deallocation success response should be valid")
    public void the_quick_deallocation_success_response_should_be_valid() {
        quickDeAllocationValidator.validateSuccessEnvelope(activeResponse());
        logger.info("quick deallocation success validation completed");
    }

    @Then("the quick deallocation workflow short-circuit response should be valid")
    public void the_quick_deallocation_workflow_short_circuit_response_should_be_valid() {
        quickDeAllocationValidator.validateWorkflowShortCircuit(activeResponse());
        logger.info("quick deallocation workflow short-circuit validation completed");
    }

    @Then("the quick deallocation failure response should be valid")
    public void the_quick_deallocation_failure_response_should_be_valid() {
        quickDeAllocationValidator.validateFailureEnvelope(activeResponse());
        logger.info("quick deallocation failure validation completed");
    }

    @Then("the quick deallocation multi-loan rejection response should be valid")
    public void the_quick_deallocation_multi_loan_rejection_response_should_be_valid() {
        quickDeAllocationValidator.validateMultiLoanRejection(activeResponse());
        logger.info("quick deallocation multi-loan rejection validation completed");
    }

    @Then("the quick deallocation no-input rejection response should be valid")
    public void the_quick_deallocation_no_input_rejection_response_should_be_valid() {
        quickDeAllocationValidator.validateNoInputRejection(activeResponse());
        logger.info("quick deallocation no-input rejection validation completed");
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
