package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyTypeValidator;


public class CompanyTypeStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyTypeStepDefinitions.class);

    private final CompanyTypeValidator validator;

    public CompanyTypeStepDefinitions(TestContext testContext, CompanyTypeValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the company type success response should be valid")
    public void the_company_type_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company type failure response should be valid")
    public void the_company_type_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
