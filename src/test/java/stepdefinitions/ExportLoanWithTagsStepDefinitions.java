package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.ExportLoanWithTagsValidator;

public class ExportLoanWithTagsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExportLoanWithTagsStepDefinitions.class);

    private final ExportLoanWithTagsValidator validator;

    public ExportLoanWithTagsStepDefinitions(TestContext testContext, ExportLoanWithTagsValidator validator) {
        super(testContext);
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
}
