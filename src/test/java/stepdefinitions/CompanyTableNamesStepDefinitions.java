package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyTableNamesValidator;


public class CompanyTableNamesStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyTableNamesStepDefinitions.class);

    private final CompanyTableNamesValidator validator;

    public CompanyTableNamesStepDefinitions(TestContext testContext, CompanyTableNamesValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the company table names success response should be valid")
    public void the_company_table_names_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company table names failure response should be valid")
    public void the_company_table_names_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
