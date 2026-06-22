package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;



public class QuickDeAllocationValidator {

    private static final Logger logger = LogManager.getLogger(QuickDeAllocationValidator.class);

    private static final String SUCCESS_MESSAGE = "success";
    private static final String FAILURE_MESSAGE = "failed";
    private static final String MULTI_LOAN_MESSAGE = "Length of loan_ids cannot be greater than 1";
    private static final String NO_INPUT_MESSAGE = "Either loan_ids or entities are required";
    private static final String WORKFLOW_SHORT_CIRCUIT_MESSAGE = "DeAllocation completed successfully";

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

    public void validateFailureEnvelope(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getString("message"), FAILURE_MESSAGE,
                "quick deallocation failure message mismatch (expected 'failed')");
        softAssert.assertNotNull(jsonPath.get("output"), "output must be present in the failure envelope");

        softAssert.assertAll();
        logger.info("quick deallocation failure envelope validated");
    }

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
