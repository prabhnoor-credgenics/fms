package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;


public class CompanyTypeValidator {

    private static final Logger logger = LogManager.getLogger(CompanyTypeValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertTrue(jp.getBoolean("success"), "success flag should be true");
        Map<String, Object> data = jp.getMap("data");
        sa.assertNotNull(data, "data must be present and be an object");
        if (data != null) {
            sa.assertTrue(data.containsKey("company_type"), "data should carry a company_type list");
        }
        sa.assertNotNull(jp.get("message"), "message must be present");

        sa.assertAll();
        logger.info("company type success envelope validated");
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present on failure");
        sa.assertAll();
        logger.info("company type failure envelope validated");
    }
}
