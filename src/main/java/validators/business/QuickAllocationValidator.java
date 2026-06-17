package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


/**
 * Response-body assertions for the synchronous POST {BASE_ROUTE}/allocation (quick_allocation) endpoint.
 *
 * Success envelope (make_response_handler):
 *   { "output": "OK", "message": "sucess", "message_template": "OK", "message_placeholder": null }
 *   NOTE: on success `message` is the literal misspelled string "sucess" (spelling as in the service source).
 *
 * Failure envelope (service / handler level):
 *   { "output": "Cannot send more than 1 loan id for quick allocation", "message": "failed",
 *     "message_template": "...", "message_placeholder": null }
 *
 * 500 unhandled envelope:
 *   { "output": {}, "message": "Something went wrong", "message_template": "Something went wrong", "message_placeholder": {} }
 */
public class QuickAllocationValidator {

    private static final Logger logger = LogManager.getLogger(QuickAllocationValidator.class);

    /** Literal success message produced by ResponseHandler.success (spelling as in source). */
    private static final String SUCCESS_MESSAGE = "sucess";
    /** Literal failure message produced by the handler when response["success"] is falsy. */
    private static final String FAILURE_MESSAGE = "failed";
    private static final String MULTI_LOAN_MESSAGE = "Cannot send more than 1 loan id for quick allocation";
    private static final String FIELD_ONE_TO_MANY_MESSAGE = "One to many cannot be selected for field allocation type";

    /** Asserts the success envelope: message == "sucess" plus the standard envelope keys. */
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

    /** Asserts a generic service/handler failure envelope: message == "failed" with a non-null output. */
    public void validateFailureEnvelope(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), FAILURE_MESSAGE,
                "quick allocation failure message mismatch (expected literal 'failed')");
        softAssert.assertNotNull(jsonPath.get("output"), "output must be present in the failure envelope");

        softAssert.assertAll();
        logger.info("quick allocation failure envelope validated");
    }

    /** Asserts the service-level rejection for more than one loan id (400, INVALID_REQUEST). */
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

    /** Asserts the service-level rejection of field + one_to_many without the company flag (400, INVALID_REQUEST). */
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
