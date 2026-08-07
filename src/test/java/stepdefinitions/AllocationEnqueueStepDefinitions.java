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

    @Then("the allocation enqueue validation error should be valid")
    public void the_allocation_enqueue_validation_error_should_be_valid() {
        validator.validateValidationError(activeResponse());
    }
    
}
