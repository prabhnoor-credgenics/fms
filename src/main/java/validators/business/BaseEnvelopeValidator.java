package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;


public abstract class BaseEnvelopeValidator implements EnvelopeValidator {

    protected final Logger logger = LogManager.getLogger(getClass());


    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        assertMessagePresent(sa, jp);
        sa.assertAll();
        logger.info("failure envelope validated");
    }


    public void validateValidationError(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        assertSuccessFalse(sa, jp);
        assertMessagePresent(sa, jp);
        sa.assertNotNull(jp.get("error.code"), "error.code must be present");
        List<Object> errorData = jp.getList("error.data");
        sa.assertTrue(errorData != null && !errorData.isEmpty(),
                "error.data should be a non-empty array of field errors");
        sa.assertAll();
        logger.info("validation-error envelope validated (error.data items: {})",
                errorData == null ? 0 : errorData.size());
    }


    public void validateErrorCode(Response response, String expectedCode) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        assertSuccessFalse(sa, jp);
        sa.assertEquals(jp.getString("error.code"), expectedCode, "error.code mismatch");
        sa.assertAll();
        logger.info("error code validated: {}", expectedCode);
    }

    protected void assertMessagePresent(SoftAssert sa, JsonPath jp) {
        sa.assertNotNull(jp.get("message"), "message must be present");
    }

    protected void assertSuccessTrue(SoftAssert sa, JsonPath jp) {
        sa.assertTrue(jp.getBoolean("success"), "success flag should be true");
    }

    protected void assertSuccessFalse(SoftAssert sa, JsonPath jp) {
        sa.assertEquals(jp.getBoolean("success"), false, "success flag should be false");
    }
}
