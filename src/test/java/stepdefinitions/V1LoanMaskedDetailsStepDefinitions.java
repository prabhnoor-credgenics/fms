package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.V1LoanMaskedDetailsValidator;


public class V1LoanMaskedDetailsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(V1LoanMaskedDetailsStepDefinitions.class);

    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final V1LoanMaskedDetailsValidator validator;

    public V1LoanMaskedDetailsStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver,
            V1LoanMaskedDetailsValidator validator
    ) {
        super(testContext);
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.validator = validator;
    }

    @Then("the v1 loan details success response should be valid")
    public void the_v1_loan_details_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the v1 loan details response should contain loan {string}")
    public void the_v1_loan_details_response_should_contain_loan(String loanId) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(loanId);
        validator.validateLoanPresent(activeResponse(), resolved);
        logger.info("v1 loan details contains {}", resolved);
    }

    @Then("the v1 loan details validation error should be valid")
    public void the_v1_loan_details_validation_error_should_be_valid() {
        validator.validateValidationError(activeResponse());
    }

    @Then("the v1 loan details error code should be {string}")
    public void the_v1_loan_details_error_code_should_be(String code) {
        validator.validateErrorCode(activeResponse(), code);
    }
}
