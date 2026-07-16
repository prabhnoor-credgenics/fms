package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


public class GlobalUserCreateValidator {

    private static final Logger logger = LogManager.getLogger(GlobalUserCreateValidator.class);

    public void validateSuccessShape(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertEquals(response.getStatusCode(), 201, "Create should be HTTP 201");
        sa.assertNotNull(jp.get("data"), "data must be present");
        sa.assertNotNull(jp.get("data.user_id"), "data.user_id must be present");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("global user create success shape validated");
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("global user create failure envelope validated");
    }
}
