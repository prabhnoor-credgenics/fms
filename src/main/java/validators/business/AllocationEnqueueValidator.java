package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;


public class AllocationEnqueueValidator {

    private static final Logger logger = LogManager.getLogger(AllocationEnqueueValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(jp.getBoolean("success"), "success flag should be true");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("allocation enqueue success envelope validated (message: {})", jp.getString("message"));
    }

    public void validateValidationError(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertEquals(jp.getBoolean("success"), false, "success flag should be false");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("error.code"), "error.code must be present");
        List<Object> errorData = jp.getList("error.data");
        sa.assertTrue(errorData != null && !errorData.isEmpty(),
                "error.data should be a non-empty array of field errors");
        sa.assertAll();
        logger.info("allocation enqueue validation-error envelope validated (error.data items: {})",
                errorData == null ? 0 : errorData.size());
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertEquals(jp.getBoolean("success"), false, "success flag should be false");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("error.code"), "error.code must be present");
        sa.assertAll();
        logger.info("allocation enqueue failure envelope validated");
    }

    public void validateErrorCode(Response response, String expectedCode) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertEquals(jp.getBoolean("success"), false, "success flag should be false");
        sa.assertEquals(jp.getString("error.code"), expectedCode, "error.code mismatch");
        sa.assertAll();
        logger.info("allocation enqueue error code validated: {}", expectedCode);
    }
}
