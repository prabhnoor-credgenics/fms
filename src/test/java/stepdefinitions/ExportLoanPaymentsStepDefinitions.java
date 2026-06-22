package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanPaymentsValidator;


public class ExportLoanPaymentsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanPaymentsStepDefinitions.class);

    private final ExportLoanPaymentsValidator validator;

    public ExportLoanPaymentsStepDefinitions(TestContext testContext, ExportLoanPaymentsValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the export loan payments success response should be valid")
    public void the_export_loan_payments_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the export loan payments failure response should be valid")
    public void the_export_loan_payments_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
