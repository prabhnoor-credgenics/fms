package stepdefinitions;

import auth.manager.AuthManager;
import auth.service.UserProfileService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import enums.UserRole;
import helpers.FileHelper;
import helpers.ResponseHelper;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.Assert;

import java.util.ArrayList;
import java.util.List;

import static io.restassured.RestAssured.given;

public class PermissionStepDefinitions {

    private static final Logger logger = LogManager.getLogger(PermissionStepDefinitions.class);
    private static final String PERMISSIONS_FILE = "test-data/permissions_all_loan.json";

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final UserProfileService userProfileService;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final AuthManager authManager;

    public PermissionStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            UserProfileService userProfileService,
            ScenarioTestDataResolver scenarioTestDataResolver,
            AuthManager authManager
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.userProfileService = userProfileService;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.authManager = authManager;
    }

    @Given("I grant the current user all loan permissions")
    public void i_grant_the_current_user_all_loan_permissions() {
        
        String savedToken = testContext.getAuthToken();
        String savedCompanyId = testContext.getCompanyId();
        int savedSlot = testContext.getUserSlot();
        UserRole savedRole = testContext.getUserRole();

        String baseUrl = configReader.getBaseUrl();
        String body = FileHelper.readResourceAsString(PERMISSIONS_FILE);

        Response response;
        String profileId;
        String companyId;
        try {
            
            Creator creator = resolveCreator(savedToken, savedRole);
            companyId = creator.companyId;

            try {
                profileId = userProfileService.fetchProfileId(creator.token, creator.companyId);
            } catch (RuntimeException e) {
                logger.warn("Could not resolve creator profile_id for company '{}': {}. Re-authenticating creator (slot {}) and retrying once.",
                        creator.companyId, e.getMessage(), creator.slot);
                testContext.setUserSlot(creator.slot);
                authManager.reAuthenticate(UserRole.CREATOR);
                creator = new Creator(testContext.getAuthToken(),
                        notBlank(testContext.getCompanyId()) ? testContext.getCompanyId() : creator.companyId,
                        creator.slot);
                companyId = creator.companyId;
                profileId = userProfileService.fetchProfileId(creator.token, creator.companyId);
            }

            authManager.initializeAuthentication(UserRole.CHIEF_ADMIN);
            response = patchPermissions(testContext.getAuthToken(), baseUrl, profileId, companyId, body);

            if (response.getStatusCode() == 401) {
                logger.warn("Chief-admin token rejected (401) when setting permissions; re-authenticating and retrying once.");
                authManager.reAuthenticate(UserRole.CHIEF_ADMIN);
                response = patchPermissions(testContext.getAuthToken(), baseUrl, profileId, companyId, body);
            }
        } finally {
            testContext.setAuthToken(savedToken);
            testContext.setCompanyId(savedCompanyId);
            testContext.setUserSlot(savedSlot);
            testContext.setUserRole(savedRole);
        }

        testContext.setResponse(response);
        int sc = response.getStatusCode();
        if (sc == 409) {
            logger.info("Permission group already exists for profile_id '{}' (company '{}'); treating as already-granted (HTTP 409)",
                    profileId, companyId);
            return;
        }
        if (sc != 200) {
            throw new AssertionError("PATCH /user/profiles/" + profileId + " (set permissions) expected 200 (or 409 already-exists) but was "
                    + sc + ". Body: " + response.getBody().asString());
        }
        logger.info("Granted full loan permissions to creator profile_id '{}' (company '{}') as chief-admin", profileId, companyId);
    }

    private record Creator(String token, String companyId, int slot) {}

    private Creator resolveCreator(String activeToken, UserRole activeRole) {
        if (activeRole == UserRole.CREATOR && notBlank(activeToken)) {
            return new Creator(activeToken, scenarioTestDataResolver.resolveUserCompanyId(), testContext.getUserSlot());
        }
        for (TestContext.UserSession s : testContext.getNamedSessions().values()) {
            if (s.role() == UserRole.CREATOR && notBlank(s.authToken())) {
                String company = notBlank(s.companyId()) ? s.companyId() : scenarioTestDataResolver.resolveUserCompanyId();
                return new Creator(s.authToken(), company, s.slot());
            }
        }
        if (notBlank(activeToken)) {
            
            return new Creator(activeToken, scenarioTestDataResolver.resolveUserCompanyId(), testContext.getUserSlot());
        }
        throw new IllegalStateException(
                "No active auth token and no remembered creator session. Authenticate "
                        + "(e.g. 'I authenticate as \"creator\" slot 0 and remember as \"creator0\"') before granting permissions.");
    }

    private static boolean notBlank(String s) {
        return s != null && !s.isBlank();
    }

    private Response patchPermissions(String chiefAdminToken, String baseUrl, String profileId, String companyId, String body) {
        return given()
                .baseUri(baseUrl)
                .header("accept", "application/json")
                .header("authenticationtoken", chiefAdminToken)
                .header("content-type", "application/json")
                .header("role", "admin")
                .header("x-company-id", companyId)
                .header("referer", baseUrl + "/user/profiles/" + profileId)
                .queryParam("company_id", companyId)
                .body(body)
                .when()
                .patch("/user/profiles/" + profileId)
                .then()
                .extract()
                .response();
    }

    @Then("I validate company permissions against test data {string}")
    public void i_validate_company_permissions_against_test_data(String testDataFile) {
        Response response = ResponseHelper.resolve(null, testContext);
        String responseBody = response.getBody().asString();
        String testDataContent = FileHelper.readResourceAsString(testDataFile);

        ObjectMapper mapper = new ObjectMapper();
        List<String> failures = new ArrayList<>();

        try {
            JsonNode responseJson = mapper.readTree(responseBody);
            JsonNode testDataJson = mapper.readTree(testDataContent);
            JsonNode permissionsArray = testDataJson.get("permissions");
            JsonNode responsePermissions = responseJson.path("data").path("profile_details").path("permissions");

            if (permissionsArray == null || !permissionsArray.isArray()) {
                throw new AssertionError("Test data file does not contain 'permissions' array");
            }

            for (JsonNode expected : permissionsArray) {
                String module = expected.get("module").asText();
                String permission = expected.get("permission").asText();
                String expectedName = expected.get("permission_name").asText();
                String expectedDescription = expected.get("permission_description").asText();
                boolean expectedRead = expected.has("read") && expected.get("read").asBoolean();
                boolean expectedWrite = expected.has("write") && expected.get("write").asBoolean();

                JsonNode moduleNode = responsePermissions.path(module);
                if (moduleNode.isMissingNode()) {
                    failures.add(String.format("Module '%s' not found in response", module));
                    continue;
                }

                JsonNode permissionNode = moduleNode.path(permission);
                if (permissionNode.isMissingNode()) {
                    failures.add(String.format("Permission '%s.%s' not found in response", module, permission));
                    continue;
                }

                JsonNode metaData = permissionNode.path("meta_data");
                String actualName = metaData.path("name").asText("");
                String actualDescription = metaData.path("description").asText("");
                boolean actualRead = permissionNode.path("read").asBoolean(false);
                boolean actualWrite = permissionNode.path("write").asBoolean(false);

                if (!expectedName.equals(actualName)) {
                    failures.add(String.format("[%s.%s] name mismatch: expected '%s', actual '%s'",
                            module, permission, expectedName, actualName));
                }

                if (!expectedDescription.isEmpty() && !expectedDescription.equals(actualDescription)) {
                    failures.add(String.format("[%s.%s] description mismatch: expected '%s', actual '%s'",
                            module, permission, expectedDescription, actualDescription));
                }

                if (expectedRead != actualRead) {
                    failures.add(String.format("[%s.%s] read mismatch: expected %s, actual %s",
                            module, permission, expectedRead, actualRead));
                }

                if (expectedWrite != actualWrite) {
                    failures.add(String.format("[%s.%s] write mismatch: expected %s, actual %s",
                            module, permission, expectedWrite, actualWrite));
                }

                logger.debug("Validated permission: {}.{} - name={}, read={}, write={}",
                        module, permission, actualName, actualRead, actualWrite);
            }

            if (!failures.isEmpty()) {
                StringBuilder errorMsg = new StringBuilder("Permission validation failures:\n");
                for (String failure : failures) {
                    errorMsg.append("  - ").append(failure).append("\n");
                }
                Assert.fail(errorMsg.toString());
            }

            logger.info("Successfully validated {} permissions against test data", permissionsArray.size());

        } catch (AssertionError e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Failed to validate company permissions: " + e.getMessage(), e);
        }
    }
}
