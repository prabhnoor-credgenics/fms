package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.AllocationEnqueueValidator;


public class AllocationEnqueueStepDefinitions {

    private static final Logger logger = LogManager.getLogger(AllocationEnqueueStepDefinitions.class);

    private final TestContext testContext;
    private final AllocationEnqueueValidator validator;

    public AllocationEnqueueStepDefinitions(TestContext testContext, AllocationEnqueueValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the allocation enqueue success response should be valid")
    public void the_allocation_enqueue_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the allocation enqueue validation error should be valid")
    public void the_allocation_enqueue_validation_error_should_be_valid() {
        validator.validateValidationError(activeResponse());
    }

    @Then("the allocation enqueue failure response should be valid")
    public void the_allocation_enqueue_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    @Then("the allocation enqueue error code should be {string}")
    public void the_allocation_enqueue_error_code_should_be(String code) {
        validator.validateErrorCode(activeResponse(), code);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
