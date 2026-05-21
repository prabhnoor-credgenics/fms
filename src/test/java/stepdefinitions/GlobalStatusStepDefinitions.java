package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.GlobalStatusValidator;


public class GlobalStatusStepDefinitions {

    private static final Logger logger = LogManager.getLogger(GlobalStatusStepDefinitions.class);

    private final TestContext testContext;
    private final GlobalStatusValidator globalStatusValidator;

    public GlobalStatusStepDefinitions(
            TestContext testContext,
            GlobalStatusValidator globalStatusValidator
    ) {
        this.testContext = testContext;
        this.globalStatusValidator = globalStatusValidator;
    }

    @Then("global status response mandatory fields should be valid")
    public void global_status_response_mandatory_fields_should_be_valid() {
        globalStatusValidator.validateMandatoryFields(activeResponse());
        logger.info("Global status mandatory fields validation completed");
    }

    @Then("global status company_id should match requested company")
    public void global_status_company_id_should_match_requested_company() {
        globalStatusValidator.validateCompanyIdMapping(activeResponse());
        logger.info("Global status company_id mapping validation completed");
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
