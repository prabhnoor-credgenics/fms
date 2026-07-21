package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.InternalBulkLoansValidator;


public class InternalBulkLoansStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(InternalBulkLoansStepDefinitions.class);

    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final InternalBulkLoansValidator validator;

    public InternalBulkLoansStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver,
            InternalBulkLoansValidator validator
    ) {
        super(testContext);
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.validator = validator;
    }


    @Then("the internal bulk loans validation error should be valid")
    public void the_internal_bulk_loans_validation_error_should_be_valid() {
        validator.validateValidationError(activeResponse());
    }
    // "response should contain loan {string}" -> generic: the response body should contain text "<id>"
    // "error code should be {string}" -> generic: the response body should contain field "error.code" with value "<code>"
}
