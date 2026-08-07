package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

public class PublicAccessTokenValidator implements EnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(PublicAccessTokenValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("data"), "data must be present");
        sa.assertNotNull(jp.get("data.api_key"), "data.api_key must be present");
        sa.assertNotNull(jp.get("data.client_id"), "data.client_id must be present");
        sa.assertNotNull(jp.get("data.expiry"), "data.expiry must be present");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("public access token success envelope validated");
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("public access token failure envelope validated");
    }
}
