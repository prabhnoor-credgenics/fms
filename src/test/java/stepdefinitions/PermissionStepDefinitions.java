package stepdefinitions;

import auth.manager.AuthManager;
import auth.service.UserProfileService;
import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import enums.UserRole;
import helpers.FileHelper;
import io.cucumber.java.en.Given;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

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
        // Snapshot whoever is active so the scenario continues as that user afterwards.
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
            // The grant must target the CREATOR's profile even when another role (e.g. chief-admin)
            // is the active user — some scenarios authenticate as chief-admin right before this step,
            // which would otherwise make the grant target the chief-admin's profile / its "All"
            // company instead of the creator's.
            Creator creator = resolveCreator(savedToken, savedRole);
            companyId = creator.companyId;

            // Resolve the creator's profile_id (verify API reads assigned_companies_dict.<companyId>).
            // The creator token can be a stale cached token on long runs (verify then returns an empty
            // dict); refresh the creator once and retry before giving up.
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

            // PATCH as chief-admin (owns permission-group management).
            authManager.initializeAuthentication(UserRole.CHIEF_ADMIN);
            response = patchPermissions(testContext.getAuthToken(), baseUrl, profileId, companyId, body);

            // The chief-admin token is cached and shared across scenarios, so it can go stale
            // mid-run ("Session expired"). On 401, force a fresh chief-admin login once and retry.
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

    /** The creator the grant targets: token + own company + credential slot. */
    private record Creator(String token, String companyId, int slot) {}

    /**
     * Resolve the creator to grant. If the active user is the creator, use the active session
     * (its token is freshest). Otherwise fall back to a remembered creator session (e.g. "creator0"),
     * so the grant still targets the creator when chief-admin/approver is the active user.
     */
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
            // No creator available; grant the active user (best effort).
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
}
