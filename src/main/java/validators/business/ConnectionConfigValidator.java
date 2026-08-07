package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;

public class ConnectionConfigValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(ConnectionConfigValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("data"), "data must be present");
        sa.assertNotNull(jp.get("data.connection_type"), "data.connection_type must be present");
        List<Map<String, Object>> rows = jp.getList("data.data");
        sa.assertNotNull(rows, "data.data must be present and be an array");

        sa.assertAll();
        logger.info("connection config success envelope validated (rows: {})", rows == null ? 0 : rows.size());
    }
}
