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
import helpers.LoggingHelper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.LinkedHashMap;
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

        String loginJson = String.format(
                "{\"username\":\"%s\",\"password\":\"%s\",\"username_type\":\"email\"}",
                credentials.email(),
                credentials.password()
        );
        String encryptedPayload = rsaEncryptionUtil.encrypt(loginJson);

        String baseUrl = configReader.getBaseUrl();
        Map<String, String> loginHeaders = new LinkedHashMap<>();
        loginHeaders.put("accept", "application/json, text/plain, */*");
        loginHeaders.put("origin", baseUrl);
        loginHeaders.put("referer", baseUrl + "/login");
        loginHeaders.put("Content-Type", "application/x-www-form-urlencoded");
        String logBody = String.format(
                "{\"username\":\"%s\",\"password\":\"***\",\"username_type\":\"email\"}%n"
                        + "[RSA encrypted body on wire, length=%d]",
                credentials.email(),
                encryptedPayload.length()
        );
        LoggingHelper.logRequestDetails(
                "POST",
                baseUrl,
                "/user/public/login?source=web",
                loginHeaders,
                null,
                logBody,
                encryptedPayload
        );
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
        LoggingHelper.logResponseDetails(loginResponse);
        assertStatus(loginResponse, 200, "POST /user/public/login?source=web");

        String authToken = loginResponse.jsonPath().getString("data.authentication_token");
        if (authToken == null || authToken.isBlank()) {
            throw new IllegalStateException("Login response missing data.authentication_token");
        }
        testContext.setAuthToken(authToken);
        testContext.setUserSlot(userSlot);
        logger.info("User logged in for env={}, role={}, slot={}", env, role, userSlot);

        fetchAndStoreCompanyId(authToken);
    }

    private void fetchAndStoreCompanyId(String authToken) {
        String baseUrl = configReader.getBaseUrl();
        Map<String, String> queryParams = new LinkedHashMap<>();
        queryParams.put("auth_token", authToken);
        Map<String, String> headers = new LinkedHashMap<>();
        headers.put("referer", baseUrl + "/user/public/verify/user");
        LoggingHelper.logRequestDetails(
                "GET",
                baseUrl,
                "/user/public/verify/user",
                headers,
                queryParams,
                null
        );
        Response response = UserProfileService.requestVerifyUser(configReader, authToken);
        LoggingHelper.logResponseDetails(response);
        assertStatus(response, 200, "GET /user/public/verify/user");

        JsonPath jp = response.jsonPath();
        Object assignedCompaniesObj = jp.get("output.assigned_companies");
        if (assignedCompaniesObj == null) {
            assignedCompaniesObj = jp.getString("data.output.assigned_companies");
        }

        String companyId = null;

        if (assignedCompaniesObj instanceof String) {
            String s = (String) assignedCompaniesObj;
            companyId = s.contains(",") ? s.split(",")[0].trim() : s;
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

    private void assertStatus(Response response, int expected, String operation) {
        if (response == null) {
            throw new IllegalStateException(operation + " returned null response");
        }
        int actual = response.getStatusCode();
        if (actual != expected) {
            throw new AssertionError(
                    operation + " expected status code <" + expected + "> but was <" + actual + ">."
            );
        }
    }

}
