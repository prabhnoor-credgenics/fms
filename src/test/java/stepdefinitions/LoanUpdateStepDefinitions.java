package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.LoanUpdateValidator;


public class LoanUpdateStepDefinitions {

    private static final Logger logger = LogManager.getLogger(LoanUpdateStepDefinitions.class);

    private final TestContext testContext;
    private final LoanUpdateValidator validator;

    public LoanUpdateStepDefinitions(TestContext testContext, LoanUpdateValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the loan update success response should be valid")
    public void the_loan_update_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the loan update failure response should be valid")
    public void the_loan_update_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    @Then("the loan update response message should contain {string}")
    public void the_loan_update_response_message_should_contain(String expected) {
        validator.validateMessageContains(activeResponse(), expected);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
