package validators.business;

import context.ScenarioTestDataResolver;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;


/**
 * Response-body assertions for the GET {BASE_ROUTE}/v3/loans/<loan_id> endpoint.
 *
 * Success envelope (ResponseHandler.success):
 *   { "success": true, "message": "...", "data": { "variable_data": { "<loan_id>": { ... } } }, ... }
 *
 * Error envelope (ResponseHandler.failure):
 *   { "success": false, "message": "...", "data": null, "error": { "code": "REC_xxxx", ... }, ... }
 */
public class V3LoansValidator {

    private static final Logger logger = LogManager.getLogger(V3LoansValidator.class);

    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public V3LoansValidator(ScenarioTestDataResolver scenarioTestDataResolver) {
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    /** Asserts the success envelope shape: success=true, message present, data.variable_data is an object. */
    public void validateSuccessEnvelope(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertTrue(jsonPath.getBoolean("success"), "success flag should be true");
        softAssert.assertNotNull(jsonPath.get("message"), "message must be present");
        softAssert.assertNotNull(jsonPath.get("data"), "data must be present");

        Map<String, Object> variableData = jsonPath.getMap("data.variable_data");
        softAssert.assertNotNull(variableData, "data.variable_data must be present and be an object");

        softAssert.assertAll();
        logger.info("v3 loan success envelope validated (variable_data keys: {})",
                variableData == null ? 0 : variableData.size());
    }

    /** Asserts the success envelope additionally carries an attribute map for the given loan id. */
    public void validateLoanPresent(Response response, String loanId) {
        validateSuccessEnvelope(response);
        Map<String, Object> variableData = response.jsonPath().getMap("data.variable_data");
        SoftAssert softAssert = new SoftAssert();
        softAssert.assertTrue(
                variableData != null && variableData.containsKey(loanId),
                "data.variable_data should contain an entry for loan id: " + loanId
        );
        softAssert.assertAll();
        logger.info("v3 loan variable_data contains loan id {}", loanId);
    }

    /** Asserts the failure envelope shape with a specific error code (e.g. REC_0003, REC_0007). */
    public void validateErrorEnvelope(Response response, String expectedCode) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(jsonPath.getBoolean("success"), false, "success flag should be false");
        softAssert.assertNotNull(jsonPath.get("message"), "message must be present");
        softAssert.assertNotNull(jsonPath.get("error"), "error object must be present");
        softAssert.assertEquals(
                jsonPath.getString("error.code"),
                expectedCode,
                "error.code mismatch"
        );

        softAssert.assertAll();
        logger.info("v3 loan error envelope validated with code {}", expectedCode);
    }
}
