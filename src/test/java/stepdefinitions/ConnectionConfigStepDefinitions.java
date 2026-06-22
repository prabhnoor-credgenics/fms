package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ConnectionConfigValidator;


public class ConnectionConfigStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ConnectionConfigStepDefinitions.class);

    private final ConnectionConfigValidator validator;

    public ConnectionConfigStepDefinitions(TestContext testContext, ConnectionConfigValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the connection config success response should be valid")
    public void the_connection_config_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the connection config failure response should be valid")
    public void the_connection_config_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
