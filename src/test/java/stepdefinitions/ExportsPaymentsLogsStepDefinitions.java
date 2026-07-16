package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportsPaymentsLogsValidator;


public class ExportsPaymentsLogsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportsPaymentsLogsStepDefinitions.class);

    private final ExportsPaymentsLogsValidator validator;

    public ExportsPaymentsLogsStepDefinitions(TestContext testContext, ExportsPaymentsLogsValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the export payments logs success response should be valid")
    public void the_export_payments_logs_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the export payments logs failure response should be valid")
    public void the_export_payments_logs_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
