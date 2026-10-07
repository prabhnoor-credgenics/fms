package stepdefinitions;

import auth.service.FmsAuthService;
import context.TestContext;
import helpers.LoggingHelper;
import io.cucumber.java.en.Given;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Secure FMS login steps — mirrors the creator/approver pattern:
 * <pre>
 *   Given I authorize as FMS user and remember as "fms0"
 *   ...
 *   | user_id     | {FMS_USER_ID} |
 *   | token-v2    | {FMS_TOKEN_V2}  |
 *   | app_version | {FMS_APP_VERSION} |
 *   | imei        | {FMS_IMEI}      |
 *   | x-api-key   | {FMS_API_KEY}   |
 * </pre>
 * Named sessions also support {@code {FMS_USER_ID:fms0}} /
 * {@code {FMS_API_KEY:fms0}}. Both "authorize" and "authorise" spellings
 * (plus "authenticate") are accepted.
 */
public class FmsAuthStepDefinitions {

    private static final Logger logger = LogManager.getLogger(FmsAuthStepDefinitions.class);

    private final TestContext testContext;
    private final FmsAuthService fmsAuthService;

    public FmsAuthStepDefinitions(TestContext testContext, FmsAuthService fmsAuthService) {
        this.testContext = testContext;
        this.fmsAuthService = fmsAuthService;
    }

    @Given("I authorize as FMS user")
    @Given("I authorise as FMS user")
    @Given("I authenticate as FMS user")
    public void i_authorize_as_fms_user() {
        authorizeAndApply();
        logger.info("Active session is now FMS user (userId={})",
                LoggingHelper.maskToken(testContext.getFmsUserId()));
    }

    @Given("I authorize as FMS user and remember as {string}")
    @Given("I authorise as FMS user and remember as {string}")
    @Given("I authenticate as FMS user and remember as {string}")
    public void i_authorize_as_fms_user_and_remember_as(String key) {
        authorizeAndApply();
        testContext.rememberFmsSession(key, new TestContext.FmsSession(
                testContext.getFmsUserId(),
                testContext.getFmsApiKey(),
                testContext.getFmsImei(),
                testContext.getFmsAppVersion(),
                testContext.getFmsTokenV2()));
        logger.info("Authorized as FMS user + remembered as '{}' (userId={}) — now the active FMS session",
                key, LoggingHelper.maskToken(testContext.getFmsUserId()));
    }

    @Given("I switch active FMS user to {string}")
    public void i_switch_active_fms_user_to(String key) {
        TestContext.FmsSession session = testContext.getFmsSession(key);
        if (session == null) {
            throw new IllegalStateException(
                    "No FMS user remembered as '" + key + "'. Use "
                            + "'I authorize as FMS user and remember as \"" + key + "\"' first.");
        }
        testContext.applyFmsSession(
                session.userId(),
                session.apiKey(),
                session.imei(),
                session.appVersion(),
                session.tokenV2());
        logger.info("Active FMS user is now '{}' (userId={})",
                key, LoggingHelper.maskToken(session.userId()));
    }

    private void authorizeAndApply() {
        fmsAuthService.authorize();
    }
}
