package stepdefinitions;

import auth.service.EncryptedUserAuthClient;
import auth.service.UserProfileService;
import context.ScenarioTestDataResolver;
import context.TestContext;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class PasswordManagementStepDefinitions {

    private static final Logger logger = LogManager.getLogger(PasswordManagementStepDefinitions.class);

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final EncryptedUserAuthClient authClient;
    private final UserProfileService userProfileService;

    public PasswordManagementStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver,
            EncryptedUserAuthClient authClient,
            UserProfileService userProfileService
    ) {
        this.testContext = testContext;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.authClient = authClient;
        this.userProfileService = userProfileService;
    }

    @When("I change password for user id {string} to {string}")
    public void i_change_password_for_user_id_to(String userIdInput, String newPasswordInput) {
        changePasswordByUserId(userIdInput, newPasswordInput, null);
    }

    @When("I change password for user email {string} to {string}")
    public void i_change_password_for_user_email_to(String emailInput, String newPasswordInput) {
        changePasswordByEmail(emailInput, newPasswordInput, null);
    }

    @When("I change password for user id {string} to {string} using remembered user {string}")
    public void i_change_password_for_user_id_to_using_remembered_user(
            String userIdInput, String newPasswordInput, String rememberedUserKey) {
        changePasswordByUserId(userIdInput, newPasswordInput, rememberedUserKey);
    }

    @When("I change password for user email {string} to {string} using remembered user {string}")
    public void i_change_password_for_user_email_to_using_remembered_user(
            String emailInput, String newPasswordInput, String rememberedUserKey) {
        changePasswordByEmail(emailInput, newPasswordInput, rememberedUserKey);
    }

    public Response changePasswordByUserId(String userIdInput, String newPasswordInput, String rememberedUserKey) {
        String authToken = resolveAuthToken(rememberedUserKey);
        String resolvedUserId = requireResolved("user id", userIdInput);
        String resolvedPassword = requireResolved("new password", newPasswordInput);
        Response response = authClient.changePassword(resolvedUserId, resolvedPassword, "web", authToken);
        return recordPasswordChangeResponse(response, resolvedUserId, rememberedUserKey, "user_id");
    }

    public Response changePasswordByEmail(String emailInput, String newPasswordInput, String rememberedUserKey) {
        String authToken = resolveAuthToken(rememberedUserKey);
        String resolvedEmail = requireResolved("user email", emailInput);
        String resolvedPassword = requireResolved("new password", newPasswordInput);
        String companyId = resolveCompanyId(rememberedUserKey);
        String userId = userProfileService.fetchUserIdByLookup(authToken, "email", resolvedEmail, companyId);
        Response response = authClient.changePassword(userId, resolvedPassword, "web", authToken);
        return recordPasswordChangeResponse(response, userId, rememberedUserKey, "email=" + resolvedEmail);
    }

    private Response recordPasswordChangeResponse(
            Response response, String targetUserId, String rememberedUserKey, String targetDescription) {
        int status = response.getStatusCode();
        String body = response.getBody().asString();
        logger.info("Change-password target={} user_id={} actingUser={} status={} body={}",
                targetDescription,
                targetUserId,
                rememberedUserKey == null ? "active-user" : rememberedUserKey,
                status,
                body);
        testContext.setResponse(response);

        boolean success = status >= 200 && status < 300;
        boolean alreadySet = status == 400 && body != null
                && (body.contains("USER_022")
                || body.toLowerCase().contains("same as the previous password"));
        if (!success && !alreadySet) {
            throw new AssertionError("Change-password failed for " + targetDescription + " (user_id=" + targetUserId
                    + "): status " + status + ", body " + body);
        }
        return response;
    }

    private String resolveAuthToken(String rememberedUserKey) {
        if (rememberedUserKey == null || rememberedUserKey.isBlank()) {
            String activeToken = testContext.getAuthToken();
            if (activeToken == null || activeToken.isBlank()) {
                throw new AssertionError("No active auth token available. Authenticate first.");
            }
            return activeToken;
        }
        TestContext.UserSession session = testContext.getUserSession(rememberedUserKey);
        if (session == null) {
            throw new AssertionError("No remembered user found as '" + rememberedUserKey + "'.");
        }
        if (session.authToken() == null || session.authToken().isBlank()) {
            throw new AssertionError("Remembered user '" + rememberedUserKey + "' has no auth token.");
        }
        return session.authToken();
    }

    private String resolveCompanyId(String rememberedUserKey) {
        if (rememberedUserKey != null && !rememberedUserKey.isBlank()) {
            TestContext.UserSession session = testContext.getUserSession(rememberedUserKey);
            if (session == null) {
                throw new AssertionError("No remembered user found as '" + rememberedUserKey + "'.");
            }
            if (session.companyId() != null && !session.companyId().isBlank()) {
                return session.companyId();
            }
        }
        return scenarioTestDataResolver.resolveUserCompanyId();
    }

    private String requireResolved(String fieldLabel, String raw) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(raw);
        if (resolved == null || resolved.isBlank()) {
            throw new AssertionError("Resolved " + fieldLabel + " is blank.");
        }
        return resolved;
    }
}
