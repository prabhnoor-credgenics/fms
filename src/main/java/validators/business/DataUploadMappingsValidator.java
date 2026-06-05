package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;

public class DataUploadMappingsValidator {

    private static final Logger logger = LogManager.getLogger(DataUploadMappingsValidator.class);

    public void validateListShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "GET list should return 200");
        softAssert.assertEquals(json.getString("message"), "Mappings fetched successfully",
                "message should be 'Mappings fetched successfully'");
        softAssert.assertNotNull(json.get("output"), "output must be present");

        List<Map<String, Object>> output = json.getList("output");
        softAssert.assertNotNull(output, "output must be a list");

        if (output != null) {
            for (int i = 0; i < output.size(); i++) {
                Map<String, Object> item = output.get(i);
                String prefix = "output[" + i + "]";
                softAssert.assertTrue(item.containsKey("mapping_id"),   prefix + " must have mapping_id");
                softAssert.assertTrue(item.containsKey("mapping_name"), prefix + " must have mapping_name");
                softAssert.assertTrue(item.containsKey("mapping_description"), prefix + " must have mapping_description");
                if (item.get("mapping_id") != null) {
                    softAssert.assertTrue(item.get("mapping_id") instanceof Integer,
                            prefix + ".mapping_id should be an integer");
                }
            }
        }

        softAssert.assertAll();
        logger.info("DataUploadMappings list shape validated: {} items", output == null ? 0 : output.size());
    }

    public void validateCreateShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 201, "POST create should return 201");
        softAssert.assertEquals(json.getString("output"),  "mapping created", "output should be 'mapping created'");
        softAssert.assertEquals(json.getString("message"), "success",         "message should be 'success'");
        softAssert.assertNotNull(json.get("mapping_id"), "mapping_id must be present");
        softAssert.assertTrue(json.get("mapping_id") instanceof Integer, "mapping_id should be an integer");

        softAssert.assertAll();
        logger.info("DataUploadMappings create shape validated: mapping_id={}", json.getInt("mapping_id"));
    }

    public void validateUpdateShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "PATCH update should return 200");
        softAssert.assertTrue(json.getBoolean("success"), "success should be true");
        softAssert.assertEquals(json.getString("message"), "Data upload mapping updated",
                "message should be 'Data upload mapping updated'");
        softAssert.assertNotNull(json.get("message_template"), "message_template must be present");

        softAssert.assertAll();
        logger.info("DataUploadMappings update shape validated");
    }

    public void validatePatchValidationErrorShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 400, "PATCH validation error should return 400");
        softAssert.assertFalse(json.getBoolean("success"), "success should be false");
        softAssert.assertNotNull(json.get("error"), "error must be present");

        Object error = json.get("error");
        if (error instanceof Map) {
            @SuppressWarnings("unchecked")
            Map<String, Object> errorMap = (Map<String, Object>) error;
            softAssert.assertEquals(errorMap.get("code"), "REC_0080",
                    "error.code should be 'REC_0080' for DataUploadMapping ValidationError");
        }

        softAssert.assertAll();
        logger.info("DataUploadMappings PATCH validation error shape validated");
    }

    public void validateDetailShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "GET detail should return 200");
        softAssert.assertNotNull(json.get("message"), "message must be present");
        softAssert.assertNotNull(json.get("output"),  "output must be present");

        softAssert.assertAll();
        logger.info("DataUploadMappings detail shape validated");
    }
}
