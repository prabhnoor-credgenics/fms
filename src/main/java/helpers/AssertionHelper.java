package helpers;

import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.hamcrest.Matchers;

import static org.hamcrest.MatcherAssert.assertThat;

public final class AssertionHelper {

    private static final Logger LOGGER = LogManager.getLogger(AssertionHelper.class);

    private AssertionHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static void assertStatusCodeOneOf(Response response, String csvCodes) {
        if (response == null) {
            throw new IllegalArgumentException("response must not be null");
        }
        if (csvCodes == null || csvCodes.isBlank()) {
            throw new IllegalArgumentException("csvCodes must not be blank");
        }
        int actual = response.getStatusCode();
        boolean matches = false;
        for (String token : csvCodes.split(",")) {
            String trimmed = token.trim();
            if (trimmed.isEmpty()) {
                continue;
            }
            if (actual == Integer.parseInt(trimmed)) {
                matches = true;
                break;
            }
        }
        assertThat("Status code " + actual + " should be one of: " + csvCodes,
                matches, Matchers.is(true));
        LOGGER.info("Status code {} is valid (one of: {})", actual, csvCodes);
    }

    public static void assertFieldExists(Response response, String jsonPath) {
        Object value = response.jsonPath().get(jsonPath);
        assertThat("Field " + jsonPath + " should exist", value, Matchers.notNullValue());
        LOGGER.info("Field '{}' exists in response with value: {}", jsonPath, value);
    }
}
