package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;


public class ExportsPaymentsLogsValidator {

    private static final Logger logger = LogManager.getLogger(ExportsPaymentsLogsValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(jp.getBoolean("success"), "success flag should be true");
        sa.assertNotNull(jp.get("message"), "message must be present");
        List<Object> exports = jp.getList("data.exports");
        sa.assertNotNull(exports, "data.exports must be a list");
        sa.assertNotNull(jp.get("data.total_count"), "data.total_count must be present");
        sa.assertAll();
        logger.info("exports payments logs success envelope validated (rows: {}, total_count: {})",
                exports == null ? 0 : exports.size(), jp.get("data.total_count"));
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present on a failure response");
        sa.assertAll();
        logger.info("exports payments logs failure envelope validated (message: {})", jp.getString("message"));
    }
}
