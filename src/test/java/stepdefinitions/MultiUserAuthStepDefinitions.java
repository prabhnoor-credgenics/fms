package stepdefinitions;

import auth.manager.AuthManager;
import auth.service.UserProfileService;
import context.TestContext;
import enums.UserRole;
import io.cucumber.java.en.*;
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
        authenticateAndRemember(parseRole(roleName), null, slot, key);
    }

    @Given("I authenticate as {string} for {string} slot {int} and remember as {string}")
    public void i_authenticate_as_for_module_slot_and_remember_as(
            String roleName, String module, int slot, String key) {
        authenticateAndRemember(parseRole(roleName), module, slot, key);
    }

    @When("I reauthenticate the user remembered as {string}")
    public void i_reauthenticate_the_user_remembered_as(String key) {

        // 1. Get the existing session before clearing it
        TestContext.UserSession oldSession = testContext.getUserSession(key);

        if (oldSession == null) {
            throw new IllegalStateException(
                    "No remembered user session found for key: " + key);
        }

        // Store the details required for reauthentication
        UserRole role = oldSession.role();
        String module = oldSession.module();
        int slot = oldSession.slot();

        logger.info(
                "Reauthenticating user '{}' (role={}, module={}, slot={})",
                key,
                role,
                module,
                slot
        );

        // 2. Clear the old session
        testContext.removeUserSession(key);

        logger.info("Cleared old session for key '{}'", key);

        // 3. Authenticate again
        authenticateAndRemember(
                role,
                module,
                slot,
                key
        );

        // 4. authenticateAndRemember() creates and stores
        // the new UserSession using the same key

        logger.info(
                "Successfully reauthenticated user '{}' and stored new session",
                key
        );
    }

    private void authenticateAndRemember(UserRole role, String module, int slot, String key) {
        testContext.setUserRole(role);
        authManager.initializeAuthentication(role, module, slot);
        String token = testContext.getAuthToken();
        String companyId = testContext.getCompanyId();
        String effectiveModule = testContext.getActiveModule();

        String userId = null;
        try {
            userId = userProfileService.fetchUserId(token);
        } catch (RuntimeException e) {
            logger.warn("Could not resolve user id for remembered user '{}' (role={}, module={}, slot={}): {}. "
                    + "{{USER_ID:{}}} will be unavailable.", key, role, effectiveModule, slot, e.getMessage(), key);
        }

        testContext.rememberUserSession(key,
                new TestContext.UserSession(token, companyId, userId, role, slot, effectiveModule));
        logger.info("Authenticated + remembered user '{}' (role={}, module={}, slot={}, companyId={}, userId={}) — now the active user",
                key, role, effectiveModule == null ? "-" : effectiveModule, slot, companyId, userId);
    }

    @Given("I authenticate using the API key")
    public void i_authenticate_using_the_api_key() {
        authManager.initializeApiKeyAuthentication();
        logger.info("Active session is now API-key based (company id={})", testContext.getCompanyId());
    }

    @Given("I authenticate using the API key and remember as {string}")
    public void i_authenticate_using_the_api_key_and_remember_as(String key) {
        authManager.initializeApiKeyAuthentication();
        testContext.rememberUserSession(key, new TestContext.UserSession(
                testContext.getAuthToken(), testContext.getCompanyId(), null, null, 0, null));
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
        testContext.setActiveModule(session.module());
        logger.info("Active user is now '{}' (role={}, module={}, slot={})",
                key, session.role(), session.module() == null ? "-" : session.module(), session.slot());
    }

    private static UserRole parseRole(String roleName) {
        return UserRole.fromString(roleName);
    }
}
