package auth.service;

import auth.crypto.RSAEncryptionUtil;
import config.ConfigReader;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import static io.restassured.RestAssured.given;


public class EncryptedUserAuthClient {

    private static final Logger logger = LogManager.getLogger(EncryptedUserAuthClient.class);

    private static final String LOGIN_PATH = "/user/public/login?source=web";
    private static final String CHANGE_PASSWORD_PATH = "/user/change-password?source=web";

    private final ConfigReader configReader;
    private final RSAEncryptionUtil rsaEncryptionUtil;

    public EncryptedUserAuthClient(ConfigReader configReader, RSAEncryptionUtil rsaEncryptionUtil) {
        this.configReader = configReader;
        this.rsaEncryptionUtil = rsaEncryptionUtil;
    }

    public Response login(String username, String password) {
        String loginJson = String.format(
                "{\"username\":\"%s\",\"password\":\"%s\",\"username_type\":\"email\"}", username, password);
        String baseUrl = configReader.getBaseUrl();
        String encrypted = rsaEncryptionUtil.encrypt(loginJson);
        Response response = given()
                .baseUri(baseUrl)
                .header("accept", "application/json, text/plain, */*")
                .header("origin", baseUrl)
                .header("referer", baseUrl + "/login")
                .header("Content-Type", "application/x-www-form-urlencoded")
                .body(encrypted)
                .when()
                .post(LOGIN_PATH)
                .then()
                .extract()
                .response();
        logger.info("Login for '{}': status={}", username, response.getStatusCode());
        return response;
    }


    public Response changePassword(String userId, String newPassword, String source, String authToken) {
        String payloadJson = String.format(
                "{\"user_id\":\"%s\",\"new_password\":\"%s\",\"source\":\"%s\"}", userId, newPassword, source);
        String baseUrl = configReader.getBaseUrl();
        String encrypted = rsaEncryptionUtil.encrypt(payloadJson);
        Response response = given()
                .baseUri(baseUrl)
                .header("accept", "application/json, text/plain, */*")
                .header("origin", baseUrl)
                .header("referer", baseUrl + "/login")
                .header("authenticationtoken", authToken)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .body(encrypted)
                .when()
                .patch(CHANGE_PASSWORD_PATH)
                .then()
                .extract()
                .response();
        logger.info("Change-password for user_id={}: status={}", userId, response.getStatusCode());
        return response;
    }
}
