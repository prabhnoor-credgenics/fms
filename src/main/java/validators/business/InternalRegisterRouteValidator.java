package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;


public class InternalRegisterRouteValidator {

    private static final Logger logger = LogManager.getLogger(InternalRegisterRouteValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
   
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertNotNull(jp.get("service_name"), "service_name must be echoed back");
        sa.assertNotNull(jp.get("route_map"), "route_map must be echoed back as a JSON string");
        sa.assertNotNull(jp.get("module_name"), "module_name must be echoed back");
        sa.assertAll();
        logger.info("internal register route success envelope validated");
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("internal register route failure envelope validated");
    }
}
