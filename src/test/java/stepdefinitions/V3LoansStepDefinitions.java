package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.V3LoansValidator;



public class V3LoansStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(V3LoansStepDefinitions.class);

    private final V3LoansValidator v3LoansValidator;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public V3LoansStepDefinitions(
            TestContext testContext,
            V3LoansValidator v3LoansValidator,
            ScenarioTestDataResolver scenarioTestDataResolver) {
        super(testContext);
        this.v3LoansValidator = v3LoansValidator;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    @Then("the v3 loan success envelope should be valid")
    public void the_v3_loan_success_envelope_should_be_valid() {
        v3LoansValidator.validateSuccessEnvelope(activeResponse());
        logger.info("v3 loan success envelope validation completed");
    }

    // "response should contain data for loan {string}" -> generic: the response body should contain text "<id>"
    // "error code should be {string}" -> generic: the response body should contain field "error.code" with value "<code>"
}
