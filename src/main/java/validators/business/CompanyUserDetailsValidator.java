package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;


public class CompanyUserDetailsValidator {

    private static final Logger logger = LogManager.getLogger(CompanyUserDetailsValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        Map<String, Object> userDetails = jp.getMap("data.user_details");
        sa.assertNotNull(userDetails, "data.user_details must be present and be an object");
        if (userDetails != null) {
            sa.assertTrue(userDetails.containsKey("user_id"), "user_details should carry a 'user_id'");
        }
        sa.assertNotNull(jp.get("message"), "message must be present");

        sa.assertAll();
        logger.info("company user details success envelope validated");
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("company user details failure envelope validated");
    }
}
