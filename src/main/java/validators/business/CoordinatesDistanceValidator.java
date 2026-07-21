package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;


public class CoordinatesDistanceValidator implements EnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(CoordinatesDistanceValidator.class);

    public void validateSuccessShape(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertEquals(response.getStatusCode(), 200, "Success should be HTTP 200");
        sa.assertEquals(jp.getString("message"), "success", "message should be 'success'");
        Map<String, Object> output = jp.getMap("output");
        sa.assertNotNull(output, "output must be present and be an object (loan_id -> distance)");

        sa.assertAll();
        logger.info("coordinates distance success shape validated (output keys: {})",
                output == null ? 0 : output.size());
    }

    public void validateLoanPresent(Response response, String loanId) {
        validateSuccessShape(response);
        Map<String, Object> output = response.jsonPath().getMap("output");
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(output != null && output.containsKey(loanId),
                "output should contain an entry for loan id: " + loanId);
        sa.assertAll();
        logger.info("coordinates distance output contains loan id {}", loanId);
    }
}
