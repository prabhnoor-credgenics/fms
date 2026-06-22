package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


public class ExportLoanPaymentsValidator {

    private static final Logger logger = LogManager.getLogger(ExportLoanPaymentsValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("data"), "data must be present");
        sa.assertAll();
        logger.info("export loan payments success envelope validated (message: {})", jp.getString("message"));
    }

    public void validateLinkEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("data.document_link"), "data.document_link must be present in link mode");
        sa.assertAll();
        logger.info("export loan payments link envelope validated");
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present on a failure response");
        sa.assertAll();
        logger.info("export loan payments failure envelope validated (message: {})", jp.getString("message"));
    }
}
