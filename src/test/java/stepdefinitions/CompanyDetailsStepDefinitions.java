package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyDetailsValidator;


public class CompanyDetailsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyDetailsStepDefinitions.class);

    private final CompanyDetailsValidator validator;

    public CompanyDetailsStepDefinitions(TestContext testContext, CompanyDetailsValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the company details success response should be valid")
    public void the_company_details_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company details failure response should be valid")
    public void the_company_details_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
