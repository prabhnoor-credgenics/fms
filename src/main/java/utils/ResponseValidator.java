package utils;

import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.hamcrest.Matcher;
import org.hamcrest.Matchers;

import static org.hamcrest.MatcherAssert.assertThat;


public class ResponseValidator {
    private static final Logger logger = LogManager.getLogger(ResponseValidator.class);


    public static void validateStatusCode(Response response, int expectedStatusCode) {
        int actualStatusCode = response.getStatusCode();
        logger.info("Validating status code. Expected: {}, Actual: {}", expectedStatusCode, actualStatusCode);
        assertThat("Status code mismatch", actualStatusCode, Matchers.equalTo(expectedStatusCode));
    }


    public static void validateStatusCode(Response response, Matcher<Integer> matcher) {
        int actualStatusCode = response.getStatusCode();
        logger.info("Validating status code using matcher. Actual: {}", actualStatusCode);
        assertThat("Status code validation failed", actualStatusCode, matcher);
    }


    public static void validateJsonField(Response response, String jsonPath, Object expectedValue) {
        Object actualValue = response.jsonPath().get(jsonPath);
        logger.info("Validating JSON field '{}'. Expected: {}, Actual: {}", jsonPath, expectedValue, actualValue);
        assertThat("JSON field validation failed for path: " + jsonPath, actualValue, Matchers.equalTo(expectedValue));
    }


    @SuppressWarnings("unchecked")
    public static void validateJsonField(Response response, String jsonPath, Matcher<?> matcher) {
        Object actualValue = response.jsonPath().get(jsonPath);
        logger.info("Validating JSON field '{}' using matcher. Actual: {}", jsonPath, actualValue);
        assertThat("JSON field validation failed for path: " + jsonPath, actualValue, (Matcher<Object>) matcher);
    }


    public static void validateHeader(Response response, String headerName, String expectedValue) {
        String actualValue = response.getHeader(headerName);
        logger.info("Validating header '{}'. Expected: {}, Actual: {}", headerName, expectedValue, actualValue);
        assertThat("Header validation failed for: " + headerName, actualValue, Matchers.equalTo(expectedValue));
    }


    public static void validateHeader(Response response, String headerName, Matcher<String> matcher) {
        String actualValue = response.getHeader(headerName);
        logger.info("Validating header '{}' using matcher. Actual: {}", headerName, actualValue);
        assertThat("Header validation failed for: " + headerName, actualValue, matcher);
    }


    public static void validateContentType(Response response, String expectedContentType) {
        String actualContentType = response.getContentType();
        logger.info("Validating content type. Expected: {}, Actual: {}", expectedContentType, actualContentType);
        assertThat("Content type mismatch", actualContentType, Matchers.containsString(expectedContentType));
    }


    public static void validateResponseBodyNotEmpty(Response response) {
        String body = response.getBody().asString();
        logger.info("Validating response body is not empty");
        assertThat("Response body is empty", body, Matchers.notNullValue());
        assertThat("Response body is empty", body.length(), Matchers.greaterThan(0));
    }
}