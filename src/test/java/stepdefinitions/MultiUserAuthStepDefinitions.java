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
