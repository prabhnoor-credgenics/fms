package stepdefinitions;

import auth.service.EncryptedUserAuthClient;
import auth.service.UserProfileService;
import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.FileHelper;
import io.cucumber.java.en.When;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import static io.restassured.RestAssured.given;

public class UserLifecycleStepDefinitions {

    private static final Logger logger = LogManager.getLogger(UserLifecycleStepDefinitions.class);

    private static final String COMPANY_USERS_PATH = "/user/company/users/";
    private static final String PROFILES_PATH = "/user/profiles";
    private static final String VERIFY_USER_PATH = "/user/public/verify/user/";
    private static final String EMAIL_TEMPLATE = "lifecycle{RANDOM_STRING:8}@credgenics.com";
    private static final String PROFILE_NAME_TEMPLATE = "lifecycleProfile{RANDOM_STRING:6}";
    private static final String PROFILE_PERMISSIONS_FILE = "test-data/profile_create_permissions.json";
    private static final String CREATOR_SESSION_KEY = "creator0";

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final UserProfileService userProfileService;
    private final EncryptedUserAuthClient authClient;
    private final PasswordManagementStepDefinitions passwordManagementSteps;

    private String createdEmail;
    private String createdUserId;
    private String createdInCompanyId;
    private String createdProfileId;

    public UserLifecycleStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            ScenarioTestDataResolver scenarioTestDataResolver,
            UserProfileService userProfileService,
            EncryptedUserAuthClient authClient,
            PasswordManagementStepDefinitions passwordManagementSteps
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.userProfileService = userProfileService;
        this.authClient = authClient;
        this.passwordManagementSteps = passwordManagementSteps;
    }

    @When("I create a permission profile")
    public void i_create_a_permission_profile() {
        
        String creatorToken = testContext.getAuthToken();
        String companyId = testContext.getCompanyId();
        if (creatorToken == null || creatorToken.isBlank() || companyId == null || companyId.isBlank()) {
            throw new AssertionError("Creator token/company not available; authenticate as creator first.");
        }

        String profileName = scenarioTestDataResolver.replaceScenarioPlaceholders(PROFILE_NAME_TEMPLATE);
        String permissions = FileHelper.readResourceAsString(PROFILE_PERMISSIONS_FILE);
        String body = "{\"profile_name\":\"" + profileName + "\",\"permissions\":" + permissions
                + ",\"profile_description\":\"created by automation\"}";

        Response response = given()
                .baseUri(configReader.getBaseUrl())
                .header("authenticationtoken", creatorToken)
                .header("Content-Type", "application/json")
                .header("accept", "application/json")
                .header("Referer", configReader.getBaseUrl() + PROFILES_PATH)
                .header("x-company-id", companyId)
                .header("role", "admin")
                .queryParam("company_id", companyId)
                .body(body)
                .when()
                .post(PROFILES_PATH)
                .then()
                .extract()
                .response();

        int status = response.getStatusCode();
        testContext.setResponse(response);
        logger.info("Create profile '{}': status={}, body={}", profileName, status, response.getBody().asString());
        if (status < 200 || status >= 300) {
            throw new AssertionError("Create permission profile failed: status " + status
                    + ", body " + response.getBody().asString());
        }
        JsonPath jp = response.jsonPath();
        this.createdProfileId = firstNonBlank(
                jp.getString("data.profile_id"),
                jp.getString("data.output.profile_id"),
                jp.getString("data.output"),
                jp.getString("data.id"),
                jp.getString("profile_id"));
        if (createdProfileId == null || createdProfileId.isBlank()) {
            throw new AssertionError("Create profile returned no profile_id; body " + response.getBody().asString());
        }
        logger.info("Created permission profile '{}', profile_id={}", profileName, createdProfileId);
    }

    @When("I create a company user assigned the created role")
    public void i_create_a_company_user_assigned_the_created_role() {
        
        String creatorToken = testContext.getAuthToken();
        String companyId = testContext.getCompanyId();
        if (creatorToken == null || creatorToken.isBlank() || companyId == null || companyId.isBlank()) {
            throw new AssertionError("Creator token/company not available; authenticate as creator first.");
        }
        String roleId = testContext.getScenarioVariableId();
        if (roleId == null || roleId.isBlank()) {
            throw new AssertionError("No role id in scope. Store the created role via "
                    + "'I store response field \"data.role_id\" as variable id' first.");
        }

        String reportsToUserId = userProfileService.fetchUserId(creatorToken);
        
        String profileId = createdProfileId != null && !createdProfileId.isBlank()
                ? createdProfileId
                : userProfileService.fetchProfileId(creatorToken, companyId);
        this.createdEmail = scenarioTestDataResolver.replaceScenarioPlaceholders(EMAIL_TEMPLATE);
        this.createdInCompanyId = companyId;

        String body = String.format(
                "{\"company_id\":\"%s\",\"first_name\":\"Lifecycle\",\"email\":\"%s\","
                        + "\"role_id\":\"%s\",\"profile_id\":\"%s\",\"reports_to_user_id\":\"%s\"}",
                companyId, createdEmail, roleId, profileId, reportsToUserId);

        Response response = given()
                .baseUri(configReader.getBaseUrl())
                .header("authenticationtoken", creatorToken)
                .header("Content-Type", "application/json")
                .header("accept", "application/json, text/plain, */*")
                
                .header("Referer", configReader.getBaseUrl() + COMPANY_USERS_PATH)
                .queryParam("company_id", companyId)
                .body(body)
                .when()
                .post(COMPANY_USERS_PATH)
                .then()
                .extract()
                .response();

        int status = response.getStatusCode();
        testContext.setResponse(response);
        logger.info("Create company user (role_id={}, profile_id={}, reports_to={}): status={}, body={}",
                roleId, profileId, reportsToUserId, status, response.getBody().asString());
        if (status != 201) {
            throw new AssertionError("Create company user (role-bound) failed for email '" + createdEmail
                    + "': status " + status + ", body " + response.getBody().asString());
        }
        this.createdUserId = firstNonBlank(
                response.jsonPath().getString("data.user_id"),
                response.jsonPath().getString("data.user_details.user_id"));
        if (createdUserId == null || createdUserId.isBlank()) {
            throw new AssertionError("Create company user returned no user_id; body "
                    + response.getBody().asString());
        }
        logger.info("Created lifecycle user email='{}', user_id={}", createdEmail, createdUserId);
    }

    @When("I set the lifecycle user's password to {string} using the chief admin token")
    public void i_set_the_lifecycle_users_password_using_the_chief_admin_token(String newPassword) {
        requireCreatedUser();
        requireAdminToken();
        passwordManagementSteps.changePasswordByUserId(createdUserId, newPassword, null);
    }

    @When("I log in as the lifecycle user with password {string}")
    public void i_log_in_as_the_lifecycle_user_with_password(String password) {
        requireCreatedUser();
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(password);
        Response response = authClient.login(createdEmail, resolved);
        JsonPath jp = response.jsonPath();
        testContext.setResponse(response);
        logger.info("Login for lifecycle user '{}': status={}, user_id={}, last_login={}",
                createdEmail, response.getStatusCode(), jp.getString("data.user_id"), jp.get("data.last_login"));
        if (response.getStatusCode() != 200) {
            throw new AssertionError("Lifecycle user login expected 200 but was " + response.getStatusCode()
                    + ", body " + response.getBody().asString());
        }
    }

    @When("I verify the lifecycle user's details by user id")
    public void i_verify_the_lifecycle_users_details_by_user_id() {
        requireCreatedUser();
        String adminToken = requireAdminToken();
        String companyId = createdInCompanyId != null ? createdInCompanyId : creatorCompanyId();

        Response response = given()
                .baseUri(configReader.getBaseUrl())
                .header("authenticationtoken", adminToken)
                .header("Referer", configReader.getBaseUrl() + VERIFY_USER_PATH)
                .header("accept", "application/json, text/plain, */*")
                .queryParam("key_name", "user_id")
                .queryParam("key_value", createdUserId)
                .queryParam("company_id", companyId)
                .when()
                .get(VERIFY_USER_PATH)
                .then()
                .extract()
                .response();

        testContext.setResponse(response);
        logger.info("Verify user by user_id={} (company_id={}): status={}, body={}",
                createdUserId, companyId, response.getStatusCode(), response.getBody().asString());
        if (response.getStatusCode() != 200) {
            throw new AssertionError("Verify-user by user_id expected 200 but was " + response.getStatusCode()
                    + ", body " + response.getBody().asString());
        }
    }

    private String requireAdminToken() {
        String adminToken = testContext.getAuthToken();
        if (adminToken == null || adminToken.isBlank()) {
            throw new AssertionError("No admin token available. Authenticate as chief-admin first.");
        }
        return adminToken;
    }

    private void requireCreatedUser() {
        if (createdEmail == null || createdUserId == null) {
            throw new AssertionError("No lifecycle user in scope. Run 'I create a company user assigned the "
                    + "created role' first.");
        }
    }

    private String creatorCompanyId() {
        TestContext.UserSession creator = testContext.getUserSession(CREATOR_SESSION_KEY);
        if (creator == null || creator.companyId() == null || creator.companyId().isBlank()) {
            throw new AssertionError("Creator company id unavailable; remember a 'creator0' session first.");
        }
        return creator.companyId();
    }

    private static String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }
}
