package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.TerritoryDetailsValidator;


public class TerritoryDetailsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(TerritoryDetailsStepDefinitions.class);

    private final TestContext testContext;
    private final TerritoryDetailsValidator validator;

    public TerritoryDetailsStepDefinitions(TestContext testContext, TerritoryDetailsValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the territory details success response should be valid")
    public void the_territory_details_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the territory details failure response should be valid")
    public void the_territory_details_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
