package auth.service;

import config.ConfigReader;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.Map;

import static io.restassured.RestAssured.given;


public class UserProfileService {

    private static final Logger logger = LogManager.getLogger(UserProfileService.class);


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

    private final ConfigReader configReader;

    public UserProfileService(ConfigReader configReader) {
        this.configReader = configReader;
    }


    public String fetchUserId(String authToken) {
        if (authToken == null || authToken.isBlank()) {
            throw new IllegalStateException(
                    "Cannot fetch user id: auth token is blank. Authenticate first.");
        }

        JsonPath jp = verifyUser(authToken).jsonPath();
        for (String path : USER_ID_PATHS) {
            String candidate = jp.getString(path);
            if (candidate != null && !candidate.isBlank()) {
                logger.info("Resolved user id '{}' from verify/user path '{}'", candidate, path);
                return candidate;
            }
        }

        throw new IllegalStateException(
                "Could not find a user id in the verify/user response. Tried the known paths.");
    }


    public String fetchProfileId(String authToken, String companyId) {
        if (authToken == null || authToken.isBlank()) {
            throw new IllegalStateException("Cannot fetch profile id: auth token is blank. Authenticate first.");
        }
        JsonPath jp = verifyUser(authToken).jsonPath();
        Map<String, Object> dict = jp.getMap("output.assigned_companies_dict");
        if (dict == null) {
            dict = jp.getMap("data.output.assigned_companies_dict");
        }
        if (dict != null && !dict.isEmpty()) {
            // Prefer the entry for the requested company; fall back to the first usable entry.
            Object entry = (companyId != null) ? dict.get(companyId) : null;
            String pid = profileIdOf(entry);
            if (pid != null) {
                logger.info("Resolved profile_id '{}' for company '{}'", pid, companyId);
                return pid;
            }
            for (Object v : dict.values()) {
                pid = profileIdOf(v);
                if (pid != null) {
                    logger.info("Resolved profile_id '{}' (first assigned company)", pid);
                    return pid;
                }
            }
        }
        throw new IllegalStateException(
                "profile_id not found in assigned_companies_dict for company '" + companyId + "'.");
    }

    private static String profileIdOf(Object entry) {
        if (entry instanceof Map<?, ?> m && m.get("profile_id") != null) {
            String pid = m.get("profile_id").toString();
            return pid.isBlank() ? null : pid;
        }
        return null;
    }


    private Response verifyUser(String authToken) {
        return requestVerifyUser(configReader, authToken);
    }

    /**
     * Issues the raw {@code GET /user/public/verify/user} call. Shared with
     * {@link UserLoginService} so the request is built in exactly one place.
     */
    static Response requestVerifyUser(ConfigReader configReader, String authToken) {
        String baseUrl = configReader.getBaseUrl();
        return given()
                .baseUri(baseUrl)
                .header("referer", baseUrl + "/user/public/verify/user")
                .queryParam("auth_token", authToken)
                .when()
                .get("/user/public/verify/user")
                .then()
                .extract()
                .response();
    }
}
