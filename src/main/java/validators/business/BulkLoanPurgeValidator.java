package validators.business;

import context.ScenarioTestDataResolver;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;



public class BulkLoanPurgeValidator {

    private static final Logger logger = LogManager.getLogger(BulkLoanPurgeValidator.class);

    private static final String PURGE_SUCCESS_MESSAGE = "Loan data purged successfully";

    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public BulkLoanPurgeValidator(ScenarioTestDataResolver scenarioTestDataResolver) {
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    public void validatePurgeSuccess(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), PURGE_SUCCESS_MESSAGE, "purge success message mismatch");
        softAssert.assertNotNull(jsonPath.get("message_template"), "message_template must be present");
        softAssert.assertNotNull(jsonPath.get("message_placeholder"), "message_placeholder must be present");

        softAssert.assertAll();
        logger.info("bulk loan purge success envelope validated");
    }

    public void validateForbiddenEnvelope(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertNotNull(jsonPath.get("message"), "message must be present");
        softAssert.assertFalse(jsonPath.getBoolean("success"), "success flag should be false");

        softAssert.assertAll();
        logger.info("bulk loan purge forbidden envelope validated");
    }
}
