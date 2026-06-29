package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.InternalRegisterRouteValidator;


public class InternalRegisterRouteStepDefinitions {

    private static final Logger logger = LogManager.getLogger(InternalRegisterRouteStepDefinitions.class);

    private final TestContext testContext;
    private final InternalRegisterRouteValidator validator;

    public InternalRegisterRouteStepDefinitions(TestContext testContext, InternalRegisterRouteValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the internal register route success response should be valid")
    public void the_internal_register_route_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the internal register route failure response should be valid")
    public void the_internal_register_route_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
