package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;

public class InternalBulkLoansValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(InternalBulkLoansValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertTrue(jp.getBoolean("success"), "success flag should be true");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("data"), "data must be present");

        Map<String, Object> variableData = jp.getMap("data.variable_data");
        sa.assertNotNull(variableData, "data.variable_data must be present and be an object");

        sa.assertAll();
        logger.info("internal bulk loans success envelope validated (variable_data keys: {})",
                variableData == null ? 0 : variableData.size());
    }

    public void validateLoanPresent(Response response, String loanId) {
        validateSuccessEnvelope(response);
        Map<String, Object> variableData = response.jsonPath().getMap("data.variable_data");
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(
                variableData != null && variableData.containsKey(loanId),
                "data.variable_data should contain an entry for loan id: " + loanId);
        sa.assertAll();
        logger.info("internal bulk loans variable_data contains loan id {}", loanId);
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertEquals(jp.getBoolean("success"), false, "success flag should be false");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("error.code"), "error.code must be present");
        sa.assertAll();
        logger.info("internal bulk loans failure envelope validated");
    }
}
