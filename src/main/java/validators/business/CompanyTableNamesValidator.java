package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;


public class CompanyTableNamesValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(CompanyTableNamesValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertTrue(jp.getBoolean("success"), "success flag should be true");
        List<Map<String, Object>> data = jp.getList("data");
        sa.assertNotNull(data, "data must be present and be an array");

        if (data != null && !data.isEmpty()) {
            Map<String, Object> first = data.get(0);
            sa.assertTrue(first.containsKey("id"), "each row should carry an 'id'");
            sa.assertTrue(first.containsKey("table_name"), "each row should carry a 'table_name'");
        }

        sa.assertAll();
        logger.info("company table names success envelope validated (rows: {})", data == null ? 0 : data.size());
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertEquals(jp.getBoolean("success"), false, "success flag should be false");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("company table names failure envelope validated");
    }
}
