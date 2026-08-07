package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

public class FinalStatusValidator implements EnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(FinalStatusValidator.class);

    public void validateSuccessShape(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertEquals(response.getStatusCode(), 200, "Success should be HTTP 200");
        sa.assertEquals(jp.getString("message"), "success", "message should be 'success'");
        
        sa.assertNotNull(jp.get("output"), "output must be present (list of statuses, or {} when none)");

        sa.assertAll();
        logger.info("final status success shape validated");
    }
}
