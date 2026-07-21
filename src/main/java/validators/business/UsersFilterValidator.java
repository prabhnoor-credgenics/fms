package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;


public class UsersFilterValidator implements EnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(UsersFilterValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("data"), "data must be present");
        Map<String, Object> filters = jp.getMap("data.filters");
        sa.assertNotNull(filters, "data.filters must be present and be an object");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("users filter success envelope validated (filter keys: {})",
                filters == null ? 0 : filters.size());
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("users filter failure envelope validated");
    }
}
