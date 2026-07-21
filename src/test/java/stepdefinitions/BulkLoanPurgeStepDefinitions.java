package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.BulkLoanPurgeValidator;



public class BulkLoanPurgeStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(BulkLoanPurgeStepDefinitions.class);

    private final BulkLoanPurgeValidator bulkLoanPurgeValidator;

    public BulkLoanPurgeStepDefinitions(TestContext testContext, BulkLoanPurgeValidator bulkLoanPurgeValidator) {
        super(testContext);
        this.bulkLoanPurgeValidator = bulkLoanPurgeValidator;
    }


    @Then("the bulk loan purge forbidden response should be valid")
    public void the_bulk_loan_purge_forbidden_response_should_be_valid() {
        bulkLoanPurgeValidator.validateForbiddenEnvelope(activeResponse());
        logger.info("bulk loan purge forbidden validation completed");
    }
}
