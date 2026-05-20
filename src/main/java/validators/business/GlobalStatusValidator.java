package validators.business;

import context.ScenarioTestDataResolver;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;


public class GlobalStatusValidator {

    private static final Logger logger = LogManager.getLogger(GlobalStatusValidator.class);

    private static final List<String> MANDATORY_ITEM_FIELDS = List.of(
            "global_status_id",
            "company_id",
            "global_status_name",
            "global_status_key",
            "active",
            "is_default",
            "is_deleted",
            "priority"
    );

    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public GlobalStatusValidator(ScenarioTestDataResolver scenarioTestDataResolver) {
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    public void validateMandatoryFields(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertNotNull(jsonPath.get("data"), "data array must be present");
        softAssert.assertTrue(jsonPath.getBoolean("success"), "success flag should be true");
        softAssert.assertNotNull(jsonPath.get("message"), "message must be present");
        softAssert.assertNotNull(jsonPath.get("message_template"), "message_template must be present");
        softAssert.assertNotNull(jsonPath.get("message_placeholder"), "message_placeholder must be present");

        List<Map<String, Object>> items = jsonPath.getList("data");
        softAssert.assertNotNull(items, "data must be a non-null array");
        softAssert.assertTrue(items != null && !items.isEmpty(), "data array must not be empty");

        if (items != null) {
            for (int index = 0; index < items.size(); index++) {
                Map<String, Object> item = items.get(index);
                String prefix = "data[" + index + "]";
                for (String field : MANDATORY_ITEM_FIELDS) {
                    softAssert.assertTrue(
                            item.containsKey(field) && item.get(field) != null,
                            prefix + " missing mandatory field: " + field
                    );
                }
                if (item.containsKey("global_status_name")) {
                    Object name = item.get("global_status_name");
                    softAssert.assertTrue(
                            name instanceof String && !((String) name).isBlank(),
                            prefix + ".global_status_name must be a non-blank string"
                    );
                }
                if (item.containsKey("global_status_key")) {
                    Object key = item.get("global_status_key");
                    softAssert.assertTrue(
                            key instanceof String && !((String) key).isBlank(),
                            prefix + ".global_status_key must be a non-blank string"
                    );
                }
            }
        }

        softAssert.assertAll();
        logger.info("Global status mandatory field validation passed for {} item(s)", items == null ? 0 : items.size());
    }

    public void validateCompanyIdMapping(Response response) {
        String expectedCompanyId = scenarioTestDataResolver.resolveCompanyId();
        List<String> companyIds = response.jsonPath().getList("data.company_id");
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertNotNull(companyIds, "data.company_id list must not be null");
        softAssert.assertTrue(companyIds != null && !companyIds.isEmpty(), "data must contain at least one status");

        if (companyIds != null) {
            for (int index = 0; index < companyIds.size(); index++) {
                softAssert.assertEquals(
                        companyIds.get(index),
                        expectedCompanyId,
                        "data[" + index + "].company_id should match requested company_id"
                );
            }
        }

        softAssert.assertAll();
        logger.info("Global status company_id mapping validated for company_id={}", expectedCompanyId);
    }
}
