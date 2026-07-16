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

    @Then("the generate receipt error code should be {string}")
    public void the_generate_receipt_error_code_should_be(String code) {
        validator.validateErrorCode(activeResponse(), code);
    }
}
