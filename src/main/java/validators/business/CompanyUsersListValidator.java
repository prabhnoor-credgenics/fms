package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;


public class CompanyUsersListValidator extends BaseEnvelopeValidator {

    private static final Logger logger = LogManager.getLogger(CompanyUsersListValidator.class);

    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();

        sa.assertNotNull(jp.get("data"), "data must be present");
        sa.assertNotNull(jp.get("data.total_count"), "data.total_count must be present");
        List<Map<String, Object>> users = jp.getList("data.users");
        sa.assertNotNull(users, "data.users must be present and be an array");
        sa.assertNotNull(jp.get("message"), "message must be present");

        sa.assertAll();
        logger.info("company users list success envelope validated (users: {})", users == null ? 0 : users.size());
    }
}
