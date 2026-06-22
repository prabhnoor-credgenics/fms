package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanWithDocumentsValidator;

public class ExportLoanWithDocumentsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanWithDocumentsStepDefinitions.class);

    private final ExportLoanWithDocumentsValidator validator;

    public ExportLoanWithDocumentsStepDefinitions(TestContext testContext, ExportLoanWithDocumentsValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the export loan with documents success response should be valid")
    public void the_export_loan_with_documents_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the export loan with documents failure response should be valid")
    public void the_export_loan_with_documents_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
