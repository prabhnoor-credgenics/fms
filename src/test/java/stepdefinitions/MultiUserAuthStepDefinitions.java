package stepdefinitions;

import auth.manager.AuthManager;
import auth.service.UserProfileService;
import context.TestContext;
import enums.UserRole;
import io.cucumber.java.en.Given;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;


public class MultiUserAuthStepDefinitions {

    private static final Logger logger = LogManager.getLogger(MultiUserAuthStepDefinitions.class);

    private final TestContext testContext;
    private final AuthManager authManager;
    private final UserProfileService userProfileService;

    public MultiUserAuthStepDefinitions(
            TestContext testContext,
            AuthManager authManager,
            UserProfileService userProfileService
    ) {
        this.testContext = testContext;
        this.authManager = authManager;
        this.userProfileService = userProfileService;
    }


    @Given("I authenticate as {string} slot {int} and remember as {string}")
    public void i_authenticate_as_slot_and_remember_as(String roleName, int slot, String key) {
        UserRole role = parseRole(roleName);


        testContext.setUserRole(role);
        authManager.initializeAuthentication(role, slot);
        String token = testContext.getAuthToken();
        String companyId = testContext.getCompanyId();


        String userId = null;
        try {
            userId = userProfileService.fetchUserId(token);
        } catch (RuntimeException e) {
            logger.warn("Could not resolve user id for remembered user '{}' (role={}, slot={}): {}. "
                    + "{{USER_ID:{}}} will be unavailable.", key, role, slot, e.getMessage(), key);
        }

        // Remember a full snapshot addressable by the friendly key for the rest of the scenario
        // (usable via {AUTH_TOKEN:<key>} / {COMPANY_ID:<key>} / {USER_ID:<key>}).
        testContext.rememberUserSession(key, new TestContext.UserSession(token, companyId, userId, role, slot));
        logger.info("Authenticated + remembered user '{}' (role={}, slot={}, companyId={}, userId={}) — now the active user",
                key, role, slot, companyId, userId);
    }


    /**
     * Authenticates via the environment API key instead of a user login. After this step
     * {@code {AUTH_TOKEN}} resolves to the API key and {@code {COMPANY_ID}} to
     * {@code <env>_api_key_global_company_id} (e.g. stag = 3e561a13-3be3-4672-85b0-e1c49a35d8fb).
     * Send the key exactly like a user token: header {@code authenticationtoken | {AUTH_TOKEN}}.
     */
    @Given("I authenticate using the API key")
    public void i_authenticate_using_the_api_key() {
        authManager.initializeApiKeyAuthentication();
        logger.info("Active session is now API-key based (company id={})", testContext.getCompanyId());
    }

    /**
     * Same as {@link #i_authenticate_using_the_api_key()} but also remembers the session under
     * {@code key} so it can be referenced later via {@code {AUTH_TOKEN:<key>}} / {@code {COMPANY_ID:<key>}}.
     * The API key has no user profile, so {@code {USER_ID:<key>}} is unavailable for this session.
     */
    @Given("I authenticate using the API key and remember as {string}")
    public void i_authenticate_using_the_api_key_and_remember_as(String key) {
        authManager.initializeApiKeyAuthentication();
        testContext.rememberUserSession(key, new TestContext.UserSession(
                testContext.getAuthToken(), testContext.getCompanyId(), null, null, 0));
        logger.info("Authenticated via API key + remembered as '{}' (company id={}) — now the active session",
                key, testContext.getCompanyId());
    }

    @Given("I switch active user to {string}")
    public void i_switch_active_user_to(String key) {
        TestContext.UserSession session = testContext.getUserSession(key);
        if (session == null) {
            throw new IllegalStateException(
                    "No user remembered as '" + key + "'. Use "
                            + "'I authenticate as \"<role>\" slot <n> and remember as \"" + key + "\"' first.");
        }
        testContext.setAuthToken(session.authToken());
        testContext.setCompanyId(session.companyId());
        testContext.setUserId(session.userId());
        testContext.setUserSlot(session.slot());
        testContext.setUserRole(session.role());
        logger.info("Active user is now '{}' (role={}, slot={})", key, session.role(), session.slot());
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
