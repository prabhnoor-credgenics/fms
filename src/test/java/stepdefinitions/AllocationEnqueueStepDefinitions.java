package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import validators.business.AllocationEnqueueValidator;


public class AllocationEnqueueStepDefinitions extends BaseStepDefinitions {

    private final AllocationEnqueueValidator validator;

    public AllocationEnqueueStepDefinitions(TestContext testContext, AllocationEnqueueValidator validator) {
        super(testContext);
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

    @Then("the allocation enqueue error code should be {string}")
    public void the_allocation_enqueue_error_code_should_be(String code) {
        validator.validateErrorCode(activeResponse(), code);
    }
}
