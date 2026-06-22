package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import validators.business.TerritoryDetailsValidator;


public class TerritoryDetailsStepDefinitions extends BaseStepDefinitions {

    private final TerritoryDetailsValidator validator;

    public TerritoryDetailsStepDefinitions(TestContext testContext, TerritoryDetailsValidator validator) {
        super(testContext);
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
}
