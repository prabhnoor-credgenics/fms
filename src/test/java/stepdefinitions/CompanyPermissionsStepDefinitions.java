package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyPermissionsValidator;


public class CompanyPermissionsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyPermissionsStepDefinitions.class);

    private final CompanyPermissionsValidator validator;

    public CompanyPermissionsStepDefinitions(TestContext testContext, CompanyPermissionsValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the company permissions success response should be valid")
    public void the_company_permissions_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company permissions failure response should be valid")
    public void the_company_permissions_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
