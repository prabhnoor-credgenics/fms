package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.LoanDetailsUpdateValidator;


public class LoanDetailsUpdateStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(LoanDetailsUpdateStepDefinitions.class);

    private final LoanDetailsUpdateValidator validator;

    public LoanDetailsUpdateStepDefinitions(TestContext testContext, LoanDetailsUpdateValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the loan details update success response should be valid")
    public void the_loan_details_update_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the loan details update failure response should be valid")
    public void the_loan_details_update_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
