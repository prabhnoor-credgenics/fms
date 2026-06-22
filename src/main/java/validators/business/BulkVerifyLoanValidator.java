package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;


public class BulkVerifyLoanValidator {

    private static final Logger logger = LogManager.getLogger(BulkVerifyLoanValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(jp.getBoolean("success"), "success flag should be true");
        sa.assertNotNull(jp.getList("data.verified_loan_ids"), "data.verified_loan_ids must be a list");
        sa.assertNotNull(jp.getList("data.non_verified_loan_ids"), "data.non_verified_loan_ids must be a list");
        sa.assertAll();
        logger.info("bulk verify loan success envelope validated (verified: {}, non-verified: {})",
                jp.getList("data.verified_loan_ids"), jp.getList("data.non_verified_loan_ids"));
    }

    public void validateLoanVerified(Response response, String loanId) {
        validateSuccessEnvelope(response);
        List<String> verified = response.jsonPath().getList("data.verified_loan_ids");
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(verified != null && verified.contains(loanId),
                "verified_loan_ids should contain loan id: " + loanId + " but was: " + verified);
        sa.assertAll();
        logger.info("bulk verify loan verified-presence validated for {}", loanId);
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present on a failure response");
        sa.assertAll();
        logger.info("bulk verify loan failure envelope validated (message: {})", jp.getString("message"));
    }
}
