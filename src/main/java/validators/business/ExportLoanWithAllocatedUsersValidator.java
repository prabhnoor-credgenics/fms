package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


public class ExportLoanWithAllocatedUsersValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(ExportLoanWithAllocatedUsersValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("export loan with allocated users success envelope validated (message: {})", jp.getString("message"));
    }
}
