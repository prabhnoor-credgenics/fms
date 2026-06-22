package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


public class UserNavBarValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(UserNavBarValidator.class);


    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertNotNull(jp.get("data"), "data must be present");
        sa.assertNotNull(jp.get("message"), "message must be present");

        sa.assertAll();
        logger.info("user nav bar success envelope validated");
    }
}
