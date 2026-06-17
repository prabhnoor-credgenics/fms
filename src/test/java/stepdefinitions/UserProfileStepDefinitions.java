package stepdefinitions;

import config.ConfigReader;
import context.TestContext;
import io.cucumber.java.en.Given;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import static io.restassured.RestAssured.given;

/**
 * Steps that read the currently-authenticated user's own profile, so a scenario
 * can capture (for example) the creator's user id for use in allocation /
 * de-allocation request bodies via the {CREATOR_USER_ID} placeholder.
 */
public class UserProfileStepDefinitions {

    private static final Logger logger = LogManager.getLogger(UserProfileStepDefinitions.class);

    // Candidate JSON paths the verify endpoint may use for the caller's own id.
    private static final String[] USER_ID_PATHS = {
            "output.user_id",
            "output.user_profile_id",
            "output.profile_id",
            "output.user_nano_id",
            "output.nano_id",
            "output._id",
            "output.id",
            "data.output.user_id",
            "data.output.profile_id",
            "data.output._id"
    };

    private final TestContext testContext;
    private final ConfigReader configReader;

    public UserProfileStepDefinitions(TestContext testContext, ConfigReader configReader) {
        this.testContext = testContext;
        this.configReader = configReader;
    }

    @Given("I store the current user id from the user profile")
    public void i_store_the_current_user_id_from_the_user_profile() {
        String authToken = testContext.getAuthToken();
        if (authToken == null || authToken.isBlank()) {
            throw new IllegalStateException(
                    "No active auth token. Authenticate (e.g. 'I authenticate as \"creator\"') before storing the user id.");
        }

        String baseUrl = configReader.getBaseUrl();
        Response response = given()
                .baseUri(baseUrl)
                .header("referer", baseUrl + "/user/public/verify/user")
                .queryParam("auth_token", authToken)
                .when()
                .get("/user/public/verify/user")
                .then()
                .extract()
                .response();

        logger.info("verify/user response (for user-id discovery): {}", response.getBody().asString());

        JsonPath jp = response.jsonPath();
        String userId = null;
        String matchedPath = null;
        for (String path : USER_ID_PATHS) {
            String candidate = jp.getString(path);
            if (candidate != null && !candidate.isBlank()) {
                userId = candidate;
                matchedPath = path;
                break;
            }
        }

        if (userId == null) {
            throw new IllegalStateException(
                    "Could not find a user id in the verify/user response. Tried paths "
                            + String.join(", ", USER_ID_PATHS)
                            + ". Response body: " + response.getBody().asString());
        }

        testContext.setUserId(userId);
        logger.info("Stored current user id '{}' (from '{}') for role {}",
                userId, matchedPath, testContext.getUserRole());
    }
}
