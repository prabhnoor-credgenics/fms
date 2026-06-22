package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.CompanyUsersListValidator;

public class CompanyUsersListStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyUsersListStepDefinitions.class);

    private final CompanyUsersListValidator validator;

    public CompanyUsersListStepDefinitions(TestContext testContext, CompanyUsersListValidator validator) {
        super(testContext);
        this.validator = validator;
    }

    @Then("the company users list success response should be valid")
    public void the_company_users_list_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the company users list failure response should be valid")
    public void the_company_users_list_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }
}
