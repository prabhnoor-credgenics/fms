package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CoordinatesDistanceValidator;


public class CoordinatesDistanceStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CoordinatesDistanceStepDefinitions.class);

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final CoordinatesDistanceValidator validator;

    public CoordinatesDistanceStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver,
            CoordinatesDistanceValidator validator
    ) {
        this.testContext = testContext;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.validator = validator;
    }

    @Then("the coordinates distance success response should be valid")
    public void the_coordinates_distance_success_response_should_be_valid() {
        validator.validateSuccessShape(activeResponse());
    }

    @Then("the coordinates distance output should contain loan {string}")
    public void the_coordinates_distance_output_should_contain_loan(String loanId) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(loanId);
        validator.validateLoanPresent(activeResponse(), resolved);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
