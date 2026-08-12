package stepdefinitions;

import auth.service.EncryptedUserAuthClient;
import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import io.cucumber.java.en.When;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import static io.restassured.RestAssured.given;

public class FirstLoginPasswordChangeStepDefinitions {

    private static final Logger logger = LogManager.getLogger(FirstLoginPasswordChangeStepDefinitions.class);

    private static final String GLOBAL_USERS_PATH = "/user/global/users/";
    private static final String EMAIL_TEMPLATE = "globalfl{RANDOM_STRING:8}@credgenics.com";

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final EncryptedUserAuthClient authClient;
    private final PasswordManagementStepDefinitions passwordManagementSteps;

    private String createdEmail;
    private String createdUserId;

    public FirstLoginPasswordChangeStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            ScenarioTestDataResolver scenarioTestDataResolver,
            EncryptedUserAuthClient authClient,
            PasswordManagementStepDefinitions passwordManagementSteps
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.authClient = authClient;
        this.passwordManagementSteps = passwordManagementSteps;
    }

    @When("I create a global user with a random email")
    public void i_create_a_global_user_with_a_random_email() {
        String adminToken = requireAdminToken();
        this.createdEmail = scenarioTestDataResolver.replaceScenarioPlaceholders(EMAIL_TEMPLATE);
        String companyId = configReader.getApiKeyGlobalCompanyId();
        if (companyId == null || companyId.isBlank()) {
            throw new AssertionError("No global company id configured ({env}_api_key_global_company_id); "
                    + "cannot create a global user.");
        }

        String createBody = String.format(
                "{\"first_name\":\"FirstLogin\",\"email\":\"%s\",\"user_type\":\"super user\","
                        + "\"assigned_companies\":[{\"company_id\":\"%s\"}]}",
                createdEmail, companyId);

        Response response = given()
                .baseUri(configReader.getBaseUrl())
                .header("authenticationtoken", adminToken)
                .header("referer", configReader.getBaseUrl())
                .header("Content-Type", "application/json")
                .header("accept", "application/json, text/plain, */*")
                .body(createBody)
                .when()
                .post(GLOBAL_USERS_PATH)
                .then()
                .extract()
                .response();

        int status = response.getStatusCode();
        testContext.setResponse(response);
        if (status != 201) {
            throw new AssertionError("Global user create failed for email '" + createdEmail + "': status "
                    + status + ", body " + response.getBody().asString());
        }
        this.createdUserId = response.jsonPath().getString("data.user_id");
        if (createdUserId == null || createdUserId.isBlank()) {
            throw new AssertionError("Global user create returned no data.user_id; body "
                    + response.getBody().asString());
        }
        logger.info("Created global user email='{}', user_id={}", createdEmail, createdUserId);
    }

    @When("I set the created user's password to {string} using the chief admin token")
    public void i_set_the_created_users_password_using_the_chief_admin_token(String newPassword) {
        requireCreatedUser();
        requireAdminToken();
        passwordManagementSteps.changePasswordByUserId(createdUserId, newPassword, null);
    }

    @When("I log in as the created user with password {string}")
    public void i_log_in_as_the_created_user_with_password(String password) {
        requireCreatedUser();
        String resolvedPassword = scenarioTestDataResolver.replaceScenarioPlaceholders(password);
        Response response = authClient.login(createdEmail, resolvedPassword);
        JsonPath jp = response.jsonPath();
        testContext.setResponse(response);
        logger.info("Login for created user '{}': status={}, user_id={}, last_login={}",
                createdEmail, response.getStatusCode(), jp.getString("data.user_id"), jp.get("data.last_login"));
    }

    private String requireAdminToken() {
        String adminToken = testContext.getAuthToken();
        if (adminToken == null || adminToken.isBlank()) {
            throw new AssertionError(
                    "No chief admin token available. Authenticate as chief-admin in the Background first.");
        }
        return adminToken;
    }

    private void requireCreatedUser() {
        if (createdEmail == null || createdUserId == null) {
            throw new AssertionError("No created user in scope. Run 'I create a global user with a random "
                    + "email' first.");
        }
    }
}
