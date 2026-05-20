package auth.service;

import auth.crypto.RSAEncryptionUtil;
import auth.model.UserCredentials;
import auth.resolver.UserCredentialsResolver;
import config.ConfigReader;
import context.TestContext;
import enums.Environment;
import enums.UserRole;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.List;
import java.util.Map;

import static io.restassured.RestAssured.given;

public class UserLoginService {
    private static final Logger logger = LogManager.getLogger(UserLoginService.class);

    private final ConfigReader configReader;
    private final TestContext testContext;
    private final RSAEncryptionUtil rsaEncryptionUtil;
    private final UserCredentialsResolver userCredentialsResolver;

    public UserLoginService(
            ConfigReader configReader,
            TestContext testContext,
            RSAEncryptionUtil rsaEncryptionUtil,
            UserCredentialsResolver userCredentialsResolver
    ) {
        this.configReader = configReader;
        this.testContext = testContext;
        this.rsaEncryptionUtil = rsaEncryptionUtil;
        this.userCredentialsResolver = userCredentialsResolver;
    }

    public void performUserLogin(Environment env, UserRole role, int userSlot) {
        UserCredentials credentials = userCredentialsResolver.resolve(env, role, userSlot);

        String encryptedPayload = rsaEncryptionUtil.encrypt(
                "{\"username\":\"" + credentials.email() + "\"," +
                        "\"password\":\"" + credentials.password() + "\"," +
                        "\"username_type\":\"email\"}"
        );

        String baseUrl = configReader.getBaseUrl();
        Response loginResponse = given()
                .baseUri(baseUrl)
                .body(encryptedPayload)
                .header("accept", "application/json, text/plain, */*")
                .header("origin", baseUrl)
                .header("referer", baseUrl + "/login")
                .header("Content-Type", "application/x-www-form-urlencoded")
                .when()
                .post("/user/public/login?source=web")
                .then()
                .extract()
                .response();

        String authToken = loginResponse.jsonPath().getString("data.authentication_token");
        testContext.setAuthToken(authToken);
        testContext.setUserSlot(userSlot);
        logger.info("User logged in for env={}, role={}, slot={}", env, role, userSlot);

        fetchAndStoreCompanyId(authToken);
    }

    private void fetchAndStoreCompanyId(String authToken) {
        String baseUrl = configReader.getBaseUrl();
        Response response = given()
                .baseUri(baseUrl)
                .header("referer", baseUrl + "/user/public/verify/user")
                .queryParam("auth_token", authToken)
                .when()
                .get("/user/public/verify/user")
                .then()
                .statusCode(200)
                .extract()
                .response();

        JsonPath jp = response.jsonPath();
        Object assignedCompaniesObj = jp.get("output.assigned_companies");
        if (assignedCompaniesObj == null) {
            assignedCompaniesObj = jp.getString("data.output.assigned_companies");
        }

        String companyId = null;

        if (assignedCompaniesObj instanceof String) {
            companyId = (String) assignedCompaniesObj;
        } else if (assignedCompaniesObj instanceof List<?> list && !list.isEmpty()) {
            Object first = list.get(0);
            companyId = first == null ? null : first.toString();
        } else {
            Object dictObj = jp.get("output.assigned_companies_dict");
            if (dictObj instanceof Map<?, ?> map) {
                companyId = map.keySet().stream().findFirst().map(Object::toString).orElse(null);
            } else if (assignedCompaniesObj != null) {
                companyId = assignedCompaniesObj.toString();
            }
        }

        if (companyId == null || companyId.isEmpty()) {
            throw new RuntimeException("company_id not found in response");
        }

        testContext.setCompanyId(companyId);
        logger.info("Company ID stored for user slot {}: {}", testContext.getUserSlot(), companyId);
    }
}
