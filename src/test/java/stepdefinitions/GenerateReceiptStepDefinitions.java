package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.GenerateReceiptValidator;


public class GenerateReceiptStepDefinitions {

    private static final Logger logger = LogManager.getLogger(GenerateReceiptStepDefinitions.class);

    private final TestContext testContext;
    private final GenerateReceiptValidator validator;

    public GenerateReceiptStepDefinitions(TestContext testContext, GenerateReceiptValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the generate receipt success response should be valid")
    public void the_generate_receipt_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the generate receipt validation error should be valid")
    public void the_generate_receipt_validation_error_should_be_valid() {
        validator.validateValidationError(activeResponse());
    }

    @Then("the generate receipt failure response should be valid")
    public void the_generate_receipt_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    @Then("the generate receipt error code should be {string}")
    public void the_generate_receipt_error_code_should_be(String code) {
        validator.validateErrorCode(activeResponse(), code);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
