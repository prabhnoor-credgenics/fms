package auth.service;

import config.ConfigReader;
import context.TestContext;
import enums.Environment;
import helpers.LoggingHelper;
import io.restassured.response.Response;

import java.util.Map;

import static io.restassured.RestAssured.given;

public class ApiKeyService {

    private final ConfigReader configReader;
    private final TestContext testContext;

    public ApiKeyService(ConfigReader configReader, TestContext testContext) {
        this.configReader = configReader;
        this.testContext = testContext;
    }

    public void generateSingleCompanyApiKey(Environment env) {
        // client_id/client_secret live in secrets/crypto.properties, keyed per active env
        // (e.g. stag_client_id), and must be read via getCryptoProperty — getProperty reads the
        // env-merged app properties, where these keys do not exist (would return null).
        String clientId = configReader.getCryptoProperty(env.getValue() + "_client_id");
        String clientSecret = configReader.getCryptoProperty(env.getValue() + "_client_secret");
        String baseUrl = configReader.getBaseUrl();
        String requestBody = """
                {
                  "client_id":"%s",
                  "client_secret":"%s",
                  "token_expiry_duration":86400
                }
                """.formatted(clientId, clientSecret);
        String logBody = requestBody.replace(clientSecret, "***");

        LoggingHelper.logRequestDetails(
                "POST",
                baseUrl,
                "/user/public/access-token",
                Map.of("Content-Type", "application/json"),
                null,
                logBody,
                requestBody
        );

        Response response = given()
                .baseUri(baseUrl)
                .contentType("application/json")
                .body(requestBody)
                .when()
                .post("/user/public/access-token")
                .then()
                .statusCode(200)
                .extract()
                .response();

        LoggingHelper.logResponseDetails(response);

        String apiKey = response.jsonPath().getString("data.api_key");
        testContext.setAuthToken(apiKey);
    }

    public void loadMultiCompanyApiKey(Environment env) {
        String apiKey = configReader.getCryptoProperty(env.name().toLowerCase() + "_api_key");
        testContext.setAuthToken(apiKey);

        String companyIdKey = env.name().toLowerCase() + "_api_key_global_company_id";
        String companyId = configReader.getProperty(companyIdKey);
        testContext.setCompanyId(companyId);
    }
}
