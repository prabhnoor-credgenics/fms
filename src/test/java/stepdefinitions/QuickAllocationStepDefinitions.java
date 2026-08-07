package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.QuickAllocationValidator;

public class QuickAllocationStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(QuickAllocationStepDefinitions.class);

    private final QuickAllocationValidator quickAllocationValidator;

    public QuickAllocationStepDefinitions(TestContext testContext, QuickAllocationValidator quickAllocationValidator) {
        super(testContext);
        this.quickAllocationValidator = quickAllocationValidator;
    }

    @Then("the quick allocation multi-loan rejection response should be valid")
    public void the_quick_allocation_multi_loan_rejection_response_should_be_valid() {
        quickAllocationValidator.validateMultiLoanRejection(activeResponse());
        logger.info("quick allocation multi-loan rejection validation completed");
    }

    @Then("the quick allocation field one-to-many rejection response should be valid")
    public void the_quick_allocation_field_one_to_many_rejection_response_should_be_valid() {
        quickAllocationValidator.validateFieldOneToManyRejection(activeResponse());
        logger.info("quick allocation field+one_to_many rejection validation completed");
    }
}
