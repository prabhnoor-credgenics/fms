package stepdefinitions;

import auth.service.UserProfileService;
import context.TestContext;
import io.cucumber.java.en.Given;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class UserProfileStepDefinitions {

    private static final Logger logger = LogManager.getLogger(UserProfileStepDefinitions.class);

    private final TestContext testContext;
    private final UserProfileService userProfileService;

    public UserProfileStepDefinitions(TestContext testContext, UserProfileService userProfileService) {
        this.testContext = testContext;
        this.userProfileService = userProfileService;
    }

    @Given("I store the current user id from the user profile")
    public void i_store_the_current_user_id_from_the_user_profile() {
        
        String userId = userProfileService.fetchUserId(testContext.getAuthToken());
        testContext.setUserId(userId);
        logger.info("Stored current user id '{}' for role {}", userId, testContext.getUserRole());
    }
}
