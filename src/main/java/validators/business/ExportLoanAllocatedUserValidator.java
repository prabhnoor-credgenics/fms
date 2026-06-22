package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


public class ExportLoanAllocatedUserValidator {

    private static final Logger logger = LogManager.getLogger(ExportLoanAllocatedUserValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("export loan allocated user success envelope validated (message: {})", jp.getString("message"));
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present on a failure response");
        sa.assertAll();
        logger.info("export loan allocated user failure envelope validated (message: {})", jp.getString("message"));
    }
}
