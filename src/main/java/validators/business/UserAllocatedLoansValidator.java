package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;


public class UserAllocatedLoansValidator implements EnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(UserAllocatedLoansValidator.class);

    public void validateSuccessShape(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertEquals(response.getStatusCode(), 200, "Success should be HTTP 200");
        sa.assertNotNull(jp.get("data"), "data must be present");
        List<Object> loanIds = jp.getList("data.loan_ids");
        sa.assertNotNull(loanIds, "data.loan_ids must be present and be an array");
        sa.assertNotNull(jp.get("data.complete_access"), "data.complete_access must be present");
        sa.assertNotNull(jp.get("message"), "message must be present");

        sa.assertAll();
        logger.info("user allocated loans success shape validated (loan_ids: {})",
                loanIds == null ? 0 : loanIds.size());
    }
}
