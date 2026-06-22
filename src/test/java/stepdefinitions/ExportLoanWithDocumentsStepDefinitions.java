package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanWithDocumentsValidator;

public class ExportLoanWithDocumentsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanWithDocumentsStepDefinitions.class);

    private final TestContext testContext;
    private final ExportLoanWithDocumentsValidator validator;

    public ExportLoanWithDocumentsStepDefinitions(TestContext testContext, ExportLoanWithDocumentsValidator validator) {
        this.testContext = testContext;
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

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
