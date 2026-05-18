package utils;

import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.hamcrest.Matcher;
import org.hamcrest.Matchers;

import static org.hamcrest.MatcherAssert.assertThat;

/**
 * Utility class for response validation using Hamcrest matchers
 */
public class ResponseValidator {
    private static final Logger logger = LogManager.getLogger(ResponseValidator.class);

    /**
     * Validate response status code
     */
    public static void validateStatusCode(Response response, int expectedStatusCode) {
        int actualStatusCode = response.getStatusCode();
        logger.info("Validating status code. Expected: {}, Actual: {}", expectedStatusCode, actualStatusCode);
        assertThat("Status code mismatch", actualStatusCode, Matchers.equalTo(expectedStatusCode));
    }

    /**
     * Validate response status code using Hamcrest matcher
     */
    public static void validateStatusCode(Response response, Matcher<Integer> matcher) {
        int actualStatusCode = response.getStatusCode();
        logger.info("Validating status code using matcher. Actual: {}", actualStatusCode);
        assertThat("Status code validation failed", actualStatusCode, matcher);
    }

    /**
     * Validate response body contains a field with expected value
     */
    public static void validateJsonField(Response response, String jsonPath, Object expectedValue) {
        Object actualValue = response.jsonPath().get(jsonPath);
        logger.info("Validating JSON field '{}'. Expected: {}, Actual: {}", jsonPath, expectedValue, actualValue);
        assertThat("JSON field validation failed for path: " + jsonPath, actualValue, Matchers.equalTo(expectedValue));
    }

    /**
     * Validate response body field using Hamcrest matcher
     */
    @SuppressWarnings("unchecked")
    public static void validateJsonField(Response response, String jsonPath, Matcher<?> matcher) {
        Object actualValue = response.jsonPath().get(jsonPath);
        logger.info("Validating JSON field '{}' using matcher. Actual: {}", jsonPath, actualValue);
        assertThat("JSON field validation failed for path: " + jsonPath, actualValue, (Matcher<Object>) matcher);
    }

    /**
     * Validate response header
     */
    public static void validateHeader(Response response, String headerName, String expectedValue) {
        String actualValue = response.getHeader(headerName);
        logger.info("Validating header '{}'. Expected: {}, Actual: {}", headerName, expectedValue, actualValue);
        assertThat("Header validation failed for: " + headerName, actualValue, Matchers.equalTo(expectedValue));
    }

    /**
     * Validate response header using Hamcrest matcher
     */
    public static void validateHeader(Response response, String headerName, Matcher<String> matcher) {
        String actualValue = response.getHeader(headerName);
        logger.info("Validating header '{}' using matcher. Actual: {}", headerName, actualValue);
        assertThat("Header validation failed for: " + headerName, actualValue, matcher);
    }

    /**
     * Validate response content type
     */
    public static void validateContentType(Response response, String expectedContentType) {
        String actualContentType = response.getContentType();
        logger.info("Validating content type. Expected: {}, Actual: {}", expectedContentType, actualContentType);
        assertThat("Content type mismatch", actualContentType, Matchers.containsString(expectedContentType));
    }

    /**
     * Validate response body is not empty
     */
    public static void validateResponseBodyNotEmpty(Response response) {
        String body = response.getBody().asString();
        logger.info("Validating response body is not empty");
        assertThat("Response body is empty", body, Matchers.notNullValue());
        assertThat("Response body is empty", body.length(), Matchers.greaterThan(0));
    }
}