package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.RecoveryExportsValidator;

public class RecoveryExportsStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(RecoveryExportsStepDefinitions.class);

    private final RecoveryExportsValidator recoveryExportsValidator;

    public RecoveryExportsStepDefinitions(
            TestContext testContext,
            RecoveryExportsValidator recoveryExportsValidator
    ) {
        super(testContext);
        this.recoveryExportsValidator = recoveryExportsValidator;
    }

    @Then("recovery exports response mandatory fields should be valid")
    public void recovery_exports_response_mandatory_fields_should_be_valid() {
        recoveryExportsValidator.validateMandatoryFields(activeResponse());
        logger.info("Recovery exports mandatory fields validation completed");
    }

    @Then("recovery exports should match requested company")
    public void recovery_exports_should_match_requested_company() {
        recoveryExportsValidator.validateCompanyScope(activeResponse());
        logger.info("Recovery exports company scope validation completed");
    }

    @Then("recovery exports page should respect page size {int}")
    public void recovery_exports_page_should_respect_page_size(int pageSize) {
        recoveryExportsValidator.validatePagination(activeResponse(), pageSize);
        logger.info("Recovery exports pagination validation completed for page_size={}", pageSize);
    }
}
