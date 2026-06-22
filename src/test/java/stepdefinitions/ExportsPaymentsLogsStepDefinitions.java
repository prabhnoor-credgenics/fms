package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportsPaymentsLogsValidator;


public class ExportsPaymentsLogsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportsPaymentsLogsStepDefinitions.class);

    private final TestContext testContext;
    private final ExportsPaymentsLogsValidator validator;

    public ExportsPaymentsLogsStepDefinitions(TestContext testContext, ExportsPaymentsLogsValidator validator) {
        this.testContext = testContext;
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

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
