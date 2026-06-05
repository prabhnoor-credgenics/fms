package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;

public class DataOperationsValidator {

    private static final Logger logger = LogManager.getLogger(DataOperationsValidator.class);

    public void validateV1SuccessShape(Response response, String expectedCategory, String expectedOperationType) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "v1 success should be HTTP 200");
        softAssert.assertTrue(json.getBoolean("success"), "success should be true");
        softAssert.assertNotNull(json.get("message"), "message must be present");
        softAssert.assertNotNull(json.get("output"), "output must be present");

        String expectedMessage = expectedCategory + " " + expectedOperationType + " successfully performed";
        softAssert.assertEquals(json.getString("message"), expectedMessage,
                "message should be '" + expectedMessage + "'");

        Object output = json.get("output");
        softAssert.assertNotNull(output, "output must not be null");
        if (output instanceof Map) {
            @SuppressWarnings("unchecked")
            Map<String, Object> outputMap = (Map<String, Object>) output;
            softAssert.assertEquals(outputMap.get("action_type"), expectedOperationType,
                    "output.action_type should be '" + expectedOperationType + "'");
            softAssert.assertEquals(outputMap.get("category"), expectedCategory,
                    "output.category should be '" + expectedCategory + "'");
        }

        softAssert.assertAll();
        logger.info("DataOperations v1 success shape validated: category={} operation={}",
                expectedCategory, expectedOperationType);
    }

    public void validateV2SuccessShape(Response response, String expectedOperationType) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 202, "v2 success should be HTTP 202");
        softAssert.assertTrue(json.getBoolean("success"), "success should be true");
        softAssert.assertEquals(json.getString("message"), "success", "message should be 'success'");
        softAssert.assertNotNull(json.get("output"), "output must be present");
        softAssert.assertTrue(
                json.getString("output") instanceof String && !json.getString("output").isBlank(),
                "output should be a non-blank string describing the queued task"
        );

        String operationLabel = "archive".equalsIgnoreCase(expectedOperationType) ? "Archive" : "Unarchive";
        softAssert.assertTrue(
                json.getString("output").contains(operationLabel + " Operations task has been initiated"),
                "output should contain '" + operationLabel + " Operations task has been initiated'"
        );

        softAssert.assertAll();
        logger.info("DataOperations v2 success shape validated for operation={}", expectedOperationType);
    }

    public void validateFailureShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertFalse(json.getBoolean("success"), "success should be false on failure");
        softAssert.assertNotNull(json.get("message"), "message must be present");
        softAssert.assertNotNull(json.get("error"), "error must be present");

        Object error = json.get("error");
        if (error instanceof Map) {
            @SuppressWarnings("unchecked")
            Map<String, Object> errorMap = (Map<String, Object>) error;
            softAssert.assertNotNull(errorMap.get("code"), "error.code must be present");
        }

        softAssert.assertAll();
        logger.info("DataOperations failure shape validated");
    }

    public void validateAllocationMonthRejected(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 400, "Status should be 400");
        softAssert.assertFalse(json.getBoolean("success"), "success should be false");
        softAssert.assertEquals(json.getString("message"), "Invalid allocation month",
                "message should be 'Invalid allocation month'");

        softAssert.assertAll();
        logger.info("DataOperations allocation_month=Overall rejection validated");
    }
}
