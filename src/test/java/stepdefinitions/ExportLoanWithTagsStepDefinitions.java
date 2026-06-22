package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanWithTagsValidator;

public class ExportLoanWithTagsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanWithTagsStepDefinitions.class);

    private final TestContext testContext;
    private final ExportLoanWithTagsValidator validator;

    public ExportLoanWithTagsStepDefinitions(TestContext testContext, ExportLoanWithTagsValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the export loan with tags success response should be valid")
    public void the_export_loan_with_tags_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the export loan with tags failure response should be valid")
    public void the_export_loan_with_tags_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
