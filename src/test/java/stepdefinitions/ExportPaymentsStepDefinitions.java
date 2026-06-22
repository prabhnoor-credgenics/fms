package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportPaymentsValidator;


public class ExportPaymentsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportPaymentsStepDefinitions.class);

    private final ExportPaymentsValidator validator;

    public ExportPaymentsStepDefinitions(TestContext testContext, ExportPaymentsValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the export payments success response should be valid")
    public void the_export_payments_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the export payments failure response should be valid")
    public void the_export_payments_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
