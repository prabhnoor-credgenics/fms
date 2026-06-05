package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;

public class ExportsValidator {

    private static final Logger logger = LogManager.getLogger(ExportsValidator.class);

    public void validateSuccessShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        softAssert.assertEquals(json.getString("message"), "success", "message should be 'success'");
        softAssert.assertTrue(json.getBoolean("success"), "success flag should be true");
        softAssert.assertNotNull(json.get("data"), "data must be present");
        softAssert.assertNotNull(json.get("data.exports"), "data.exports must be present");
        softAssert.assertNotNull(json.get("data.total_count"), "data.total_count must be present");

        Object totalCount = json.get("data.total_count");
        softAssert.assertTrue(
                totalCount instanceof Integer && (Integer) totalCount >= 0,
                "data.total_count should be a non-negative integer"
        );

        softAssert.assertAll();
        logger.info("Exports success shape validated");
    }

    public void validateEmptyResult(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        softAssert.assertEquals(json.getString("message"), "success", "message should be 'success'");
        softAssert.assertTrue(json.getBoolean("success"), "success flag should be true");

        List<?> exports = json.getList("data.exports");
        softAssert.assertNotNull(exports, "data.exports must be present");
        softAssert.assertTrue(exports != null && exports.isEmpty(), "data.exports should be empty");
        softAssert.assertEquals(json.getInt("data.total_count"), 0, "data.total_count should be 0");

        softAssert.assertAll();
        logger.info("Exports empty result shape validated");
    }

    public void validateExportItemFields(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        List<Map<String, Object>> exports = json.getList("data.exports");
        softAssert.assertNotNull(exports, "data.exports must not be null");

        if (exports != null && !exports.isEmpty()) {
            for (int i = 0; i < exports.size(); i++) {
                Map<String, Object> item = exports.get(i);
                String prefix = "data.exports[" + i + "]";
                softAssert.assertTrue(item.containsKey("id"),              prefix + " must have id");
                softAssert.assertTrue(item.containsKey("export_category"), prefix + " must have export_category");
                softAssert.assertTrue(item.containsKey("status"),          prefix + " must have status");
                softAssert.assertTrue(item.containsKey("created"),         prefix + " must have created");
                softAssert.assertNotNull(item.get("id"),              prefix + ".id should not be null");
                softAssert.assertNotNull(item.get("export_category"), prefix + ".export_category should not be null");
                softAssert.assertNotNull(item.get("status"),          prefix + ".status should not be null");
            }
        }

        softAssert.assertAll();
        logger.info("Exports item fields validated for {} items", exports == null ? 0 : exports.size());
    }

    public void validatePaginationBounds(Response response, int expectedPageSize) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        List<?> exports = json.getList("data.exports");
        softAssert.assertNotNull(exports, "data.exports must not be null");
        if (exports != null) {
            softAssert.assertTrue(exports.size() <= expectedPageSize,
                    "exports count " + exports.size() + " should not exceed page_size " + expectedPageSize);
        }

        softAssert.assertAll();
        logger.info("Exports pagination bounds validated: page_size={} actual={}", expectedPageSize,
                exports == null ? 0 : exports.size());
    }

    public void validateErrorMessage(Response response, int expectedStatus, String expectedMessage) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), expectedStatus,
                "Status code mismatch for: " + expectedMessage);
        softAssert.assertEquals(json.getString("message"), expectedMessage, "Error message mismatch");

        softAssert.assertAll();
        logger.info("Exports error validated: status={} message={}", expectedStatus, expectedMessage);
    }
}
