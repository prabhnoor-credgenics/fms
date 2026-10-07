package auth.service;

import config.ConfigReader;
import context.TestContext;
import helpers.LoggingHelper;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.LinkedHashMap;
import java.util.Map;

import static io.restassured.RestAssured.given;

/**
 * Secure FMS (FixMyScore) login.
 *
 * <p>Flow: {@code POST /fixmyscore-user-service/auth/register} with
 * {@code {"mobile":"...","type":"login"}} returns {@code data[0].user_id}.
 * That {@code user_id}, together with the static {@code x-api-key} and device
 * headers, authenticates every subsequent FMS call.</p>
 *
 * <p>All secrets come from {@code src/main/resources/secrets/crypto.properties}
 * (git-ignored) via env-scoped keys ({@code stag_fms_api_key},
 * {@code stag_fms_mobile}, {@code stag_fms_imei}, {@code stag_fms_app_version},
 * {@code stag_fms_token_v2}). Nothing is hardcoded in feature files.</p>
 */
public class FmsAuthService {

    private static final Logger logger = LogManager.getLogger(FmsAuthService.class);

    private static final String REGISTER_PATH = "/fixmyscore-user-service/auth/register";

    private final ConfigReader configReader;
    private final TestContext testContext;

    public FmsAuthService(ConfigReader configReader, TestContext testContext) {
        this.configReader = configReader;
        this.testContext = testContext;
    }

    /**
     * Performs the FMS register/login, stores the resolved {@code user_id} plus
     * header material on the active {@link TestContext}, and returns the user id.
     */
    public String authorize() {
        String mobile = configReader.getFmsMobile();
        String apiKey = configReader.getFmsApiKey();
        String imei = configReader.getFmsImei();
        String appVersion = configReader.getFmsAppVersion();
        String tokenV2 = configReader.getFmsTokenV2();
        String baseUrl = configReader.getBaseUrl();

        String requestBody = String.format(
                "{\"mobile\":\"%s\",\"type\":\"login\"}",
                mobile
        );

        Map<String, String> headers = new LinkedHashMap<>();
        headers.put("Content-Type", "application/json");
        headers.put("x-api-key", LoggingHelper.maskToken(apiKey));

        LoggingHelper.logRequestDetails(
                "POST",
                baseUrl,
                REGISTER_PATH,
                headers,
                null,
                requestBody
        );
        logger.info("Authorizing FMS user (mobile={}***, apiKey={}, imei={}, appVersion={}, tokenV2={})",
                mobile.length() > 4 ? mobile.substring(0, 2) + "***" + mobile.substring(mobile.length() - 2) : "***",
                LoggingHelper.maskToken(apiKey),
                LoggingHelper.maskToken(imei),
                appVersion,
                tokenV2);

        Response response = given()
                .baseUri(baseUrl)
                .contentType("application/json")
                .accept("application/json")
                .body(requestBody)
                .when()
                .post(REGISTER_PATH)
                .then()
                .extract()
                .response();

        LoggingHelper.logResponseDetails(response);
        assertStatus(response, 200, "POST " + REGISTER_PATH);

        String userId = extractUserId(response);
        if (userId == null || userId.isBlank()) {
            throw new IllegalStateException(
                    "FMS register response missing user id. Tried data[0].user_id, data.user_id, user_id. "
                            + "Body: " + response.getBody().asString());
        }

        testContext.applyFmsSession(userId.trim(), apiKey, imei, appVersion, tokenV2);
        logger.info("FMS user authorized (userId={}, apiKey={})",
                LoggingHelper.maskToken(userId), LoggingHelper.maskToken(apiKey));
        return userId.trim();
    }

    /** Header map for an FMS-authenticated request, built from the active session. */
    public Map<String, String> fmsHeaders() {
        String userId = testContext.getFmsUserId();
        if (userId == null || userId.isBlank()) {
            throw new IllegalStateException(
                    "FMS user id is not set. Use 'Given I authorize as FMS user' first.");
        }
        Map<String, String> headers = new LinkedHashMap<>();
        headers.put("user_id", userId);
        headers.put("token-v2", testContext.getFmsTokenV2() != null
                ? testContext.getFmsTokenV2() : configReader.getFmsTokenV2());
        headers.put("app_version", testContext.getFmsAppVersion() != null
                ? testContext.getFmsAppVersion() : configReader.getFmsAppVersion());
        headers.put("imei", testContext.getFmsImei() != null
                ? testContext.getFmsImei() : configReader.getFmsImei());
        headers.put("x-api-key", testContext.getFmsApiKey() != null
                ? testContext.getFmsApiKey() : configReader.getFmsApiKey());
        return headers;
    }

    private static String extractUserId(Response response) {
        String[] candidates = {
                "data[0].user_id",
                "data[0].userId",
                "data[0].id",
                "data.user_id",
                "data.userId",
                "user_id",
                "userId"
        };
        for (String path : candidates) {
            try {
                String value = response.jsonPath().getString(path);
                if (value != null && !value.isBlank()) {
                    return value;
                }
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private static void assertStatus(Response response, int expected, String operation) {
        if (response == null) {
            throw new IllegalStateException(operation + " returned null response");
        }
        int actual = response.getStatusCode();
        if (actual != expected) {
            throw new AssertionError(
                    operation + " expected status code <" + expected + "> but was <" + actual + ">. "
                            + "Body: " + response.getBody().asString());
        }
    }
}
