package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

public class AssignDefaultValidator {

    private static final Logger logger = LogManager.getLogger(AssignDefaultValidator.class);

    private static final String EXPECTED_SUCCESS_MESSAGE = "Default Dispositions Created";
    private static final String EXPECTED_FAILURE_MESSAGE = "failure";

    public void validateSuccessShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertNotNull(json.get("data"), "data key must be present");
        softAssert.assertNotNull(json.get("message"), "message key must be present");
        softAssert.assertNotNull(json.get("success"), "success key must be present");

        softAssert.assertEquals(
                json.getString("message"),
                EXPECTED_SUCCESS_MESSAGE,
                "message should be '" + EXPECTED_SUCCESS_MESSAGE + "'"
        );
        softAssert.assertTrue(
                json.getBoolean("success"),
                "success flag should be true"
        );

        Object data = json.get("data");
        softAssert.assertNotNull(data, "data must not be null");
        if (data instanceof java.util.Map) {
            softAssert.assertTrue(
                    ((java.util.Map<?, ?>) data).isEmpty(),
                    "data should be an empty object {}"
            );
        }

        softAssert.assertAll();
        logger.info("AssignDefault success response shape validated");
    }

    public void validateFailureShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertNotNull(json.get("message"), "message key must be present in failure response");
        softAssert.assertNotNull(json.get("output"), "output key must be present in failure response");

        softAssert.assertEquals(
                json.getString("message"),
                EXPECTED_FAILURE_MESSAGE,
                "message should be '" + EXPECTED_FAILURE_MESSAGE + "'"
        );

        softAssert.assertAll();
        logger.info("AssignDefault failure response shape validated");
    }

    public void validateStatusCode(Response response, int expectedStatusCode) {
        int actual = response.getStatusCode();
        SoftAssert softAssert = new SoftAssert();
        softAssert.assertEquals(actual, expectedStatusCode, "HTTP status code mismatch");
        softAssert.assertAll();
        logger.info("Status code validated: expected={} actual={}", expectedStatusCode, actual);
    }
}
