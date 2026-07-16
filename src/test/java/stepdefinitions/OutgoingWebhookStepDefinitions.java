package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.OutgoingWebhookValidator;


public class OutgoingWebhookStepDefinitions {

    private static final Logger logger = LogManager.getLogger(OutgoingWebhookStepDefinitions.class);

    private final TestContext testContext;
    private final OutgoingWebhookValidator validator;

    public OutgoingWebhookStepDefinitions(TestContext testContext, OutgoingWebhookValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the outgoing webhook success response should be valid")
    public void the_outgoing_webhook_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the outgoing webhook failure response should be valid")
    public void the_outgoing_webhook_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
