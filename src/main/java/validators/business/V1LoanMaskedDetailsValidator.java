package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;


public class V1LoanMaskedDetailsValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(V1LoanMaskedDetailsValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(jp.getBoolean("success"), "success flag should be true");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("data"), "data must be present");
        sa.assertNotNull(jp.getMap("data.variable_data"), "data.variable_data must be present and be an object");
        sa.assertAll();
        Map<String, Object> vd = jp.getMap("data.variable_data");
        logger.info("v1 loan masked success envelope validated (variable_data keys: {})", vd == null ? 0 : vd.size());
    }

    public void validateLoanPresent(Response response, String loanId) {
        validateSuccessEnvelope(response);
        Map<String, Object> vd = response.jsonPath().getMap("data.variable_data");
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(vd != null && vd.containsKey(loanId),
                "data.variable_data should contain an entry for loan id: " + loanId);
        sa.assertAll();
        logger.info("v1 loan masked variable_data contains loan id {}", loanId);
    }
}
