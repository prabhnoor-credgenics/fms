package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.AllocationDetailsValidator;


public class AllocationDetailsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(AllocationDetailsStepDefinitions.class);

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final AllocationDetailsValidator validator;

    public AllocationDetailsStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver,
            AllocationDetailsValidator validator
    ) {
        this.testContext = testContext;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.validator = validator;
    }

    @Then("the allocation details success response should be valid")
    public void the_allocation_details_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the allocation details output should contain loan {string}")
    public void the_allocation_details_output_should_contain_loan(String loanId) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(loanId);
        validator.validateOutputContainsLoan(activeResponse(), resolved);
        logger.info("allocation details output contains {}", resolved);
    }

    @Then("the allocation details failure response should be valid")
    public void the_allocation_details_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
