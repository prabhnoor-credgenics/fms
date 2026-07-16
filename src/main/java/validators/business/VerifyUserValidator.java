package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;


public class VerifyUserValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(VerifyUserValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        Map<String, Object> output = jp.getMap("output");
        sa.assertNotNull(output, "output must be present and be an object");
        if (output != null) {
            sa.assertTrue(output.containsKey("user_id") || output.containsKey("api_key_id"),
                    "output should carry a user_id (platform flow) or api_key_id (integration flow)");
        }
        sa.assertNotNull(jp.get("message"), "message must be present");

        sa.assertAll();
        logger.info("verify user success envelope validated (output keys: {})",
                output == null ? 0 : output.size());
    }
}
