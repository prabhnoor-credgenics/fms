package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


public class LoanUpdateValidator {

    private static final Logger logger = LogManager.getLogger(LoanUpdateValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("loan update success envelope validated (message: {}, output: {})",
                jp.getString("message"), jp.getString("output"));
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present on a failure response");
        sa.assertAll();
        logger.info("loan update failure envelope validated (message: {})", jp.getString("message"));
    }

    public void validateMessageContains(Response response, String expectedSubstring) {
        String message = response.jsonPath().getString("message");
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(message != null && message.toLowerCase().contains(expectedSubstring.toLowerCase()),
                "message should contain '" + expectedSubstring + "' but was: " + message);
        sa.assertAll();
        logger.info("loan update message-contains validated: '{}'", expectedSubstring);
    }
}
