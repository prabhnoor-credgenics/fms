package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;


public class CompanyPermissionsValidator {

    private static final Logger logger = LogManager.getLogger(CompanyPermissionsValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("data.profile_id"), "data.profile_id must be present");
        Map<String, Object> permissions = jp.getMap("data.permissions");
        sa.assertNotNull(permissions, "data.permissions must be present and be an object");

        sa.assertAll();
        logger.info("company permissions success envelope validated");
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("company permissions failure envelope validated");
    }
}
