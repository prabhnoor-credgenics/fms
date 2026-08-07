package validators.business;

import context.ScenarioTestDataResolver;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;

public class RecoveryExportsValidator {

    private static final Logger logger = LogManager.getLogger(RecoveryExportsValidator.class);

    private static final List<String> MANDATORY_EXPORT_FIELDS = List.of(
            "allocation_month",
            "created",
            "duration",
            "export_category",
            "id",
            "record_count",
            "status"
    );

    private static final List<String> MANDATORY_REQUESTER_FIELDS = List.of(
            "full_name",
            "user_id",
            "username"
    );

    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public RecoveryExportsValidator(ScenarioTestDataResolver scenarioTestDataResolver) {
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    public void validateMandatoryFields(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertNotNull(jsonPath.get("data"), "data object must be present");
        softAssert.assertNotNull(jsonPath.get("data.exports"), "data.exports array must be present");
        softAssert.assertNotNull(jsonPath.get("data.total_count"), "data.total_count must be present");
        softAssert.assertTrue(jsonPath.getBoolean("success"), "success flag should be true");
        softAssert.assertNotNull(jsonPath.get("message"), "message must be present");

        String message = jsonPath.getString("message");
        softAssert.assertTrue(message != null && !message.isBlank(), "message must not be blank");

        List<Map<String, Object>> exports = jsonPath.getList("data.exports");
        softAssert.assertNotNull(exports, "data.exports must be a non-null array");

        if (exports != null) {
            for (int index = 0; index < exports.size(); index++) {
                Map<String, Object> item = exports.get(index);
                String prefix = "data.exports[" + index + "]";
                for (String field : MANDATORY_EXPORT_FIELDS) {
                    softAssert.assertTrue(
                            item.containsKey(field) && item.get(field) != null,
                            prefix + " missing mandatory field: " + field
                    );
                }
                Object requester = item.get("requester");
                softAssert.assertTrue(
                        requester instanceof Map<?, ?>,
                        prefix + ".requester must be an object"
                );
                if (requester instanceof Map<?, ?> requesterMap) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> requesterFields = (Map<String, Object>) requesterMap;
                    for (String field : MANDATORY_REQUESTER_FIELDS) {
                        softAssert.assertTrue(
                                requesterFields.containsKey(field) && requesterFields.get(field) != null,
                                prefix + ".requester missing mandatory field: " + field
                        );
                    }
                }
            }
        }

        softAssert.assertAll();
        logger.info(
                "Recovery exports mandatory field validation passed for {} export(s)",
                exports == null ? 0 : exports.size()
        );
    }

    public void validateCompanyScope(Response response) {
        String expectedCompanyId = scenarioTestDataResolver.resolveCompanyId();
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        List<Map<String, Object>> exports = jsonPath.getList("data.exports");
        Integer totalCount = jsonPath.getInt("data.total_count");

        softAssert.assertNotNull(exports, "data.exports must not be null for company_id=" + expectedCompanyId);
        softAssert.assertTrue(exports != null && !exports.isEmpty(), "data.exports must not be empty");
        softAssert.assertNotNull(totalCount, "data.total_count must be present");
        softAssert.assertTrue(totalCount >= exports.size(), "total_count should be >= current page export count");
        softAssert.assertTrue(jsonPath.getBoolean("success"), "success should be true");

        softAssert.assertAll();
        logger.info(
                "Recovery exports company scope validated for company_id={} (page exports={}, total_count={})",
                expectedCompanyId,
                exports == null ? 0 : exports.size(),
                totalCount
        );
    }

    public void validatePagination(Response response, int pageSize) {
        List<Map<String, Object>> exports = response.jsonPath().getList("data.exports");
        Integer totalCount = response.jsonPath().getInt("data.total_count");

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertNotNull(exports, "data.exports must not be null");
        softAssert.assertTrue(
                exports == null || exports.size() <= pageSize,
                "data.exports size must not exceed page_size=" + pageSize + " (actual="
                        + (exports == null ? 0 : exports.size()) + ")"
        );
        if (totalCount != null && totalCount > pageSize) {
            softAssert.assertEquals(
                    exports == null ? 0 : exports.size(),
                    pageSize,
                    "When total_count exceeds page_size, first page should return page_size items"
            );
        }
        softAssert.assertAll();
        logger.info(
                "Recovery exports pagination validated: page_size={}, returned={}, total_count={}",
                pageSize,
                exports == null ? 0 : exports.size(),
                totalCount
        );
    }
}
