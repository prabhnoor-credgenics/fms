package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;



public class QuickAllocationValidator {

    private static final Logger logger = LogManager.getLogger(QuickAllocationValidator.class);

    private static final String SUCCESS_MESSAGE = "sucess";
    private static final String FAILURE_MESSAGE = "failed";
    private static final String MULTI_LOAN_MESSAGE = "Cannot send more than 1 loan id for quick allocation";
    private static final String FIELD_ONE_TO_MANY_MESSAGE = "One to many cannot be selected for field allocation type";

    public void validateSuccessEnvelope(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), SUCCESS_MESSAGE,
                "quick allocation success message mismatch (expected literal 'sucess')");
        softAssert.assertTrue(jsonPath.get("output") != null,
                "output must be present in the success envelope");
        softAssert.assertTrue(response.getBody().asString().contains("message_template"),
                "message_template key must be present in the success envelope");

        softAssert.assertAll();
        logger.info("quick allocation success envelope validated");
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), FAILURE_MESSAGE,
                "quick allocation failure message mismatch (expected literal 'failed')");
        softAssert.assertNotNull(jsonPath.get("output"), "output must be present in the failure envelope");

        softAssert.assertAll();
        logger.info("quick allocation failure envelope validated");
    }

    public void validateMultiLoanRejection(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), FAILURE_MESSAGE,
                "multi-loan rejection should carry message 'failed'");
        softAssert.assertEquals(jsonPath.getString("output"), MULTI_LOAN_MESSAGE,
                "multi-loan rejection output text mismatch");

        softAssert.assertAll();
        logger.info("quick allocation multi-loan rejection envelope validated");
    }

    public void validateFieldOneToManyRejection(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), FAILURE_MESSAGE,
                "field+one_to_many rejection should carry message 'failed'");
        softAssert.assertEquals(jsonPath.getString("output"), FIELD_ONE_TO_MANY_MESSAGE,
                "field+one_to_many rejection output text mismatch");

        softAssert.assertAll();
        logger.info("quick allocation field+one_to_many rejection envelope validated");
    }
}
