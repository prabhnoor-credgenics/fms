package auth;

import config.ConfigReader;
import context.TestContext;
import enums.Environment;
import io.restassured.response.Response;

import static io.restassured.RestAssured.given;

public class ApiKeyService {

    private final ConfigReader configReader;
    private final TestContext testContext;

    public ApiKeyService(ConfigReader configReader, TestContext testContext) {
        this.configReader = configReader;
        this.testContext = testContext;
    }

    public void generateSingleCompanyApiKey(Environment env) {
        String clientId = configReader.getProperty("prod.client.id");
        String clientSecret = configReader.getProperty("prod.client.secret");
        String baseUrl = configReader.getBaseUrl();

        Response response = given()
                .baseUri(baseUrl)
                .contentType("application/json")
                .body("""
                        {
                          "client_id":"%s",
                          "client_secret":"%s",
                          "token_expiry_duration":86400
                        }
                        """.formatted(clientId, clientSecret))
                .when()
                .post("/user/public/access-token")
                .then()
                .statusCode(200)
                .extract()
                .response();

        String apiKey = response.jsonPath().getString("data.api_key");
        testContext.setAuthToken(apiKey);
    }

    public void loadMultiCompanyApiKey(Environment env) {
        String apiKey = configReader.getCryptoProperty(env.name().toLowerCase() + ".api.key");
        testContext.setAuthToken(apiKey);

        String companyIdKey = env.name().toLowerCase() + ".api.key.global.company.id";
        String companyId = configReader.getProperty(companyIdKey);
        testContext.setCompanyId(companyId);
    }
}
