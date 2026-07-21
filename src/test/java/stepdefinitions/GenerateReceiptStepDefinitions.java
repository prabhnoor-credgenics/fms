package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import validators.business.GenerateReceiptValidator;


public class GenerateReceiptStepDefinitions extends BaseStepDefinitions {

    private final GenerateReceiptValidator validator;

    public GenerateReceiptStepDefinitions(TestContext testContext, GenerateReceiptValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the generate receipt validation error should be valid")
    public void the_generate_receipt_validation_error_should_be_valid() {
        validator.validateValidationError(activeResponse());
    }
    // "error code should be {string}" removed — use generic:
    // Then the response body should contain field "error.code" with value "<code>"
}
