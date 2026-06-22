package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.V3LoansValidator;



public class V3LoansStepDefinitions {

    private static final Logger logger = LogManager.getLogger(V3LoansStepDefinitions.class);

    private final TestContext testContext;
    private final V3LoansValidator v3LoansValidator;

    public V3LoansStepDefinitions(TestContext testContext, V3LoansValidator v3LoansValidator) {
        this.testContext = testContext;
        this.v3LoansValidator = v3LoansValidator;
    }

    @Then("the v3 loan success envelope should be valid")
    public void the_v3_loan_success_envelope_should_be_valid() {
        v3LoansValidator.validateSuccessEnvelope(activeResponse());
        logger.info("v3 loan success envelope validation completed");
    }

    @Then("the v3 loan response should contain data for loan {string}")
    public void the_v3_loan_response_should_contain_data_for_loan(String loanId) {
        v3LoansValidator.validateLoanPresent(activeResponse(), loanId);
        logger.info("v3 loan data-presence validation completed for {}", loanId);
    }

    @Then("the v3 loan error code should be {string}")
    public void the_v3_loan_error_code_should_be(String expectedCode) {
        v3LoansValidator.validateErrorEnvelope(activeResponse(), expectedCode);
        logger.info("v3 loan error code validation completed for {}", expectedCode);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
