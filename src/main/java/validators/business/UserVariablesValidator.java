package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;


public class UserVariablesValidator implements EnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(UserVariablesValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("data"), "data must be present");
        List<Map<String, Object>> variables = jp.getList("data.variables");
        sa.assertNotNull(variables, "data.variables must be present and be an array");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("user variables success envelope validated (variables: {})",
                variables == null ? 0 : variables.size());
    }

    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("user variables failure envelope validated");
    }
}
