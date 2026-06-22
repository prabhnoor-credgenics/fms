package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;

/**
 * Shared response-envelope assertions for the per-feature business validators.
 *
 * <p>Most validators only need the standard envelope checks (a human-readable
 * {@code message}, the {@code success} flag, a structured {@code error.code} /
 * {@code error.data}). Those were previously copy-pasted into every validator;
 * they now live here once. Subclasses inherit the public {@code validate*}
 * methods directly, override them when a feature needs richer assertions, and
 * reuse the {@code protected} primitives inside their own success-envelope checks.
 *
 * <p>The logger resolves via {@code getClass()} so inherited assertions still log
 * under the concrete subclass name.
 */
public abstract class BaseEnvelopeValidator {

    protected final Logger logger = LogManager.getLogger(getClass());

    /** Plain failure envelope: a human-readable {@code message} must be present. */
    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        assertMessagePresent(sa, jp);
        sa.assertAll();
        logger.info("failure envelope validated");
    }

    /** {@code success == false}, a {@code message}, an {@code error.code}, and a non-empty {@code error.data} list. */
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

    /** {@code success == false} and {@code error.code} equals the expected code. */
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
