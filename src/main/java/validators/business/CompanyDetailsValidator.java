package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.Map;

public class CompanyDetailsValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(CompanyDetailsValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        Map<String, Object> companyDetails = jp.getMap("data.company_details");
        sa.assertNotNull(companyDetails, "data.company_details must be present and be an object");
        if (companyDetails != null) {
            sa.assertTrue(companyDetails.containsKey("company_id"), "company_details should carry a 'company_id'");
        }
        sa.assertNotNull(jp.get("message"), "message must be present");

        sa.assertAll();
        logger.info("company details success envelope validated");
    }
}
