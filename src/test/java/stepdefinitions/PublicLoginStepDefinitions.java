package stepdefinitions;

import auth.crypto.RSAEncryptionUtil;
import auth.model.UserCredentials;
import auth.resolver.UserCredentialsResolver;
import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import enums.UserRole;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.PublicLoginValidator;

import static io.restassured.RestAssured.given;


public class PublicLoginStepDefinitions {

    private static final Logger logger = LogManager.getLogger(PublicLoginStepDefinitions.class);
    private static final String LOGIN_PATH = "/user/public/login?source=web";

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final RSAEncryptionUtil rsaEncryptionUtil;
    private final UserCredentialsResolver userCredentialsResolver;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final PublicLoginValidator validator;

    public PublicLoginStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            RSAEncryptionUtil rsaEncryptionUtil,
            UserCredentialsResolver userCredentialsResolver,
            ScenarioTestDataResolver scenarioTestDataResolver,
            PublicLoginValidator validator
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.rsaEncryptionUtil = rsaEncryptionUtil;
        this.userCredentialsResolver = userCredentialsResolver;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.validator = validator;
    }

    @When("I send an encrypted login request as {string}")
    public void i_send_an_encrypted_login_request_as(String roleName) {
        UserRole role = parseRole(roleName);
        UserCredentials creds = userCredentialsResolver.resolve(configReader.getEnvironment(), role, 0);
        String loginJson = String.format(
                "{\"username\":\"%s\",\"password\":\"%s\",\"username_type\":\"email\"}",
                creds.email(), creds.password());
        postEncrypted(loginJson);
    }

    @When("I send an encrypted login request with body:")
    public void i_send_an_encrypted_login_request_with_body(String body) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(body);
        postEncrypted(resolved);
    }

    @When("I send a plaintext login request with body:")
    public void i_send_a_plaintext_login_request_with_body(String body) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(body);
        String baseUrl = configReader.getBaseUrl();
        Response response = given()
                .baseUri(baseUrl)
                .header("accept", "application/json, text/plain, */*")
                .header("origin", baseUrl)
                .header("referer", baseUrl + "/login")
                .header("Content-Type", "application/json")
                .body(resolved)
                .when()
                .post(LOGIN_PATH)
                .then()
                .extract()
                .response();
        store(response);
    }

    private void postEncrypted(String json) {
        String baseUrl = configReader.getBaseUrl();
        String encrypted = rsaEncryptionUtil.encrypt(json);
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
        store(response);
    }

    private void store(Response response) {
        testContext.setResponse(response);
        logger.info("Login request sent; status={}", response.getStatusCode());
    }

    @Then("the public login success response should be valid")
    public void the_public_login_success_response_should_be_valid() {
        validator.validateSuccessEnvelope(activeResponse());
    }

    @Then("the public login failure response should be valid")
    public void the_public_login_failure_response_should_be_valid() {
        validator.validateFailureEnvelope(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }

    private static UserRole parseRole(String roleName) {
        return switch (roleName.trim().toLowerCase()) {
            case "creator" -> UserRole.CREATOR;
            case "approver" -> UserRole.APPROVER;
            case "chief-admin", "chief_admin", "chiefadmin" -> UserRole.CHIEF_ADMIN;
            default -> throw new IllegalArgumentException(
                    "Unknown role '" + roleName + "'. Expected: creator | approver | chief-admin");
        };
    }
}
