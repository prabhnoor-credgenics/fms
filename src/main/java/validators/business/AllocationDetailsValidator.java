package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;

public class AllocationDetailsValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(AllocationDetailsValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.getList("output"), "output must be present and be an array");
        sa.assertAll();
        logger.info("allocation details success envelope validated (output rows: {})",
                jp.getList("output") == null ? 0 : jp.getList("output").size());
    }

    public void validateOutputContainsLoan(Response response, String loanId) {
        validateSuccessEnvelope(response);
        List<Map<String, Object>> output = response.jsonPath().getList("output");
        boolean found = output != null && output.stream()
                .anyMatch(row -> row != null && loanId.equals(String.valueOf(row.get("loan_id"))));
        SoftAssert sa = new SoftAssert();
        sa.assertTrue(found, "output should contain a row with loan_id: " + loanId);
        sa.assertAll();
        logger.info("allocation details output contains loan_id {}", loanId);
    }
}
