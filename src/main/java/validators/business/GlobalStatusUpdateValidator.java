package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

public class GlobalStatusUpdateValidator {

    private static final Logger logger = LogManager.getLogger(GlobalStatusUpdateValidator.class);

    private static final String SUCCESS_MESSAGE = "success";
    private static final String SUCCESS_OUTPUT  = "Status updated successfully";
    private static final String FAILURE_MESSAGE = "failed";

    public void validateSuccessShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Status code should be 200");
        softAssert.assertNotNull(json.get("message"), "message key must be present");
        softAssert.assertNotNull(json.get("output"),  "output key must be present");
        softAssert.assertEquals(json.getString("message"), SUCCESS_MESSAGE,
                "message should be '" + SUCCESS_MESSAGE + "'");
        softAssert.assertEquals(json.getString("output"), SUCCESS_OUTPUT,
                "output should be '" + SUCCESS_OUTPUT + "'");

        softAssert.assertAll();
        logger.info("GlobalStatusUpdate success shape validated");
    }

    public void validateFailureShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertNotNull(json.get("message"), "message key must be present in failure response");
        softAssert.assertNotNull(json.get("output"),  "output key must be present in failure response");
        softAssert.assertEquals(json.getString("message"), FAILURE_MESSAGE,
                "message should be '" + FAILURE_MESSAGE + "'");

        softAssert.assertAll();
        logger.info("GlobalStatusUpdate failure shape validated: output={}",
                json.getString("output"));
    }

    public void validateValidityCheckError(Response response, String expectedMessage) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 400, "Status code should be 400");
        softAssert.assertNotNull(json.get("message"), "message key must be present");
        softAssert.assertEquals(json.getString("message"), expectedMessage,
                "message should be '" + expectedMessage + "'");

        softAssert.assertAll();
        logger.info("GlobalStatusUpdate validity-check error validated: message={}",
                json.getString("message"));
    }
}
