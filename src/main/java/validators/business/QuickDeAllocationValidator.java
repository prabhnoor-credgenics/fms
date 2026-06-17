package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


/**
 * Response-body assertions for the synchronous POST {BASE_ROUTE}/deallocation (quick_deallocation) endpoint.
 *
 * Success envelope (make_response_handler):
 *   { "output": "OK", "message": "success", "message_template": "OK", "message_placeholder": null }
 *   NOTE: on success `message` is "success" (correctly spelled, unlike /allocation's literal "sucess").
 *
 * Workflow short-circuit (loan has no allocation, source == "workflow"):
 *   { "output": "DeAllocation completed successfully", "message": "success", ... }
 *
 * Failure envelope (service / handler level):
 *   { "output": "Length of loan_ids cannot be greater than 1", "message": "failed",
 *     "message_template": "...", "message_placeholder": null }
 */
public class QuickDeAllocationValidator {

    private static final Logger logger = LogManager.getLogger(QuickDeAllocationValidator.class);

    /** Literal success message produced by ResponseHandler.success. */
    private static final String SUCCESS_MESSAGE = "success";
    /** Literal failure message produced by the handler when response["success"] is falsy. */
    private static final String FAILURE_MESSAGE = "failed";
    private static final String MULTI_LOAN_MESSAGE = "Length of loan_ids cannot be greater than 1";
    private static final String NO_INPUT_MESSAGE = "Either loan_ids or entities are required";
    private static final String WORKFLOW_SHORT_CIRCUIT_MESSAGE = "DeAllocation completed successfully";

    /** Asserts the success envelope: message == "success" plus the standard envelope keys. */
    public void validateSuccessEnvelope(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), SUCCESS_MESSAGE,
                "quick deallocation success message mismatch (expected 'success')");
        softAssert.assertTrue(jsonPath.get("output") != null,
                "output must be present in the success envelope");
        softAssert.assertTrue(response.getBody().asString().contains("message_template"),
                "message_template key must be present in the success envelope");

        softAssert.assertAll();
        logger.info("quick deallocation success envelope validated");
    }

    /** Asserts the workflow short-circuit envelope (loan had no allocation): success + documented output text. */
    public void validateWorkflowShortCircuit(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), SUCCESS_MESSAGE,
                "workflow short-circuit should carry message 'success'");
        softAssert.assertEquals(jsonPath.getString("output"), WORKFLOW_SHORT_CIRCUIT_MESSAGE,
                "workflow short-circuit output text mismatch");

        softAssert.assertAll();
        logger.info("quick deallocation workflow short-circuit envelope validated");
    }

    /** Asserts a generic service/handler failure envelope: message == "failed" with a non-null output. */
    public void validateFailureEnvelope(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), FAILURE_MESSAGE,
                "quick deallocation failure message mismatch (expected 'failed')");
        softAssert.assertNotNull(jsonPath.get("output"), "output must be present in the failure envelope");

        softAssert.assertAll();
        logger.info("quick deallocation failure envelope validated");
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
        logger.info("quick deallocation multi-loan rejection envelope validated");
    }

    /** Asserts the intended "neither loan_ids nor entities" rejection (400, INVALID_REQUEST). */
    public void validateNoInputRejection(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), FAILURE_MESSAGE,
                "no-input rejection should carry message 'failed'");
        softAssert.assertEquals(jsonPath.getString("output"), NO_INPUT_MESSAGE,
                "no-input rejection output text mismatch");

        softAssert.assertAll();
        logger.info("quick deallocation no-input rejection envelope validated");
    }
}
