package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.FinalStatusValidator;


public class FinalStatusStepDefinitions {

    private static final Logger logger = LogManager.getLogger(FinalStatusStepDefinitions.class);

    private final TestContext testContext;
    private final FinalStatusValidator validator;

    public FinalStatusStepDefinitions(TestContext testContext, FinalStatusValidator validator) {
        this.testContext = testContext;
        this.validator = validator;
    }

    @Then("the final status success response should be valid")
    public void the_final_status_success_response_should_be_valid() {
        validator.validateSuccessShape(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}
