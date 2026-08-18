package utils;

import com.fasterxml.jackson.databind.JsonNode;
import helpers.PayloadHelper;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.hamcrest.Matcher;
import org.hamcrest.Matchers;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

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
        if (expectedValue instanceof String stringExpected) {
            validateJsonFieldAuto(response, jsonPath, stringExpected);
            return;
        }
        Object actualValue = response.jsonPath().get(jsonPath);
        logger.info("Validating JSON field '{}'. Expected: {} ({}), Actual: {} ({})",
                jsonPath, expectedValue, typeName(expectedValue), actualValue, typeName(actualValue));
        assertValuesEqual(jsonPath, actualValue, expectedValue);
    }

    public static void validateJsonFieldAuto(Response response, String jsonPath, String expectedRaw) {

        Object actualValue = getJsonValue(response, jsonPath);

        String raw = PayloadHelper.stripSurroundingQuotes(
                expectedRaw == null ? null : expectedRaw.trim());

        if (actualValue instanceof List<?> list) {
            if (raw != null && ("[]".equals(raw) || "empty".equalsIgnoreCase(raw))) {
                assertThat("Expected empty array at path: " + jsonPath,
                        list, Matchers.empty());
                return;
            }

            if (raw != null && "not empty".equalsIgnoreCase(raw)) {
                assertThat("Expected non-empty array at path: " + jsonPath,
                        list, Matchers.not(Matchers.empty()));
                return;
            }
        }

        Object expectedValue = coerceExpected(actualValue, raw);

        logger.info(
                "Validating JSON field '{}' (auto). Expected: {} ({}), Actual: {} ({})",
                jsonPath,
                expectedValue,
                typeName(expectedValue),
                actualValue,
                typeName(actualValue)
        );

        assertValuesEqual(jsonPath, actualValue, expectedValue);
    }
    public static void validateJsonFieldTyped(Response response, String jsonPath, String type, String expectedRaw) {
        String normalized = type == null ? "auto" : type.trim().toLowerCase();
        if ("auto".equals(normalized) || "any".equals(normalized) || "coerce".equals(normalized)) {
            validateJsonFieldAuto(response, jsonPath, expectedRaw);
            return;
        }
        logger.info("JSON path received by validator: [{}]", jsonPath);
        Object actualValue = response.jsonPath().get(jsonPath);
        String raw = PayloadHelper.stripSurroundingQuotes(
                expectedRaw == null ? null : expectedRaw.trim());

        if (actualValue instanceof List<?> list) {
            if (raw != null && ("[]".equals(raw) || "empty".equalsIgnoreCase(raw))) {
                assertThat("Expected empty array at path: " + jsonPath, list, Matchers.empty());
                return;
            }
            if (raw != null && "not empty".equalsIgnoreCase(raw)) {
                assertThat("Expected non-empty array at path: " + jsonPath, list, Matchers.not(Matchers.empty()));
                return;
            }
        }

        Object expectedValue = JsonUtils.parseTypedValueAsJava(normalized, raw);
        logger.info("Validating JSON field '{}' as {}. Expected: {} ({}), Actual: {} ({})",
                jsonPath, type, expectedValue, typeName(expectedValue), actualValue, typeName(actualValue));
        assertValuesEqual(jsonPath, actualValue, expectedValue);
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

    static Object coerceExpected(Object actual, String expectedRaw) {
        if (expectedRaw == null || PayloadHelper.isNullToken(expectedRaw)) {
            return null;
        }
        if (actual instanceof Boolean) {
            return JsonUtils.parseTypedValueAsJava("boolean", expectedRaw);
        }
        if (actual instanceof Number) {
            return JsonUtils.parseTypedValueAsJava("number", expectedRaw);
        }
        if (actual instanceof Map) {
            return JsonUtils.parseTypedValueAsJava("map", expectedRaw);
        }
        if (actual instanceof List) {
            return JsonUtils.parseTypedValueAsJava("list", expectedRaw);
        }
        if (actual == null) {
            if (looksLikeJsonObject(expectedRaw)) {
                return JsonUtils.parseTypedValueAsJava("map", expectedRaw);
            }
            if (looksLikeJsonArray(expectedRaw)) {
                return JsonUtils.parseTypedValueAsJava("list", expectedRaw);
            }
            if ("true".equalsIgnoreCase(expectedRaw) || "false".equalsIgnoreCase(expectedRaw)) {
                return JsonUtils.parseTypedValueAsJava("boolean", expectedRaw);
            }
            try {
                return JsonUtils.parseTypedValueAsJava("number", expectedRaw);
            } catch (RuntimeException ignored) {
                return expectedRaw;
            }
        }
        return expectedRaw;
    }

    static void assertValuesEqual(String jsonPath, Object actual, Object expected) {
        if (actual instanceof Number && expected instanceof Number) {
            BigDecimal actualNumber = new BigDecimal(actual.toString());
            BigDecimal expectedNumber = new BigDecimal(expected.toString());
            assertThat(
                    "JSON field validation failed for path: " + jsonPath
                            + " (expected number " + expected + ", actual " + actual + ")",
                    actualNumber.compareTo(expectedNumber) == 0,
                    Matchers.is(true));
            return;
        }
        assertThat("JSON field validation failed for path: " + jsonPath, actual, Matchers.equalTo(expected));
    }

    private static boolean looksLikeJsonObject(String value) {
        String trimmed = value.trim();
        return trimmed.startsWith("{") && trimmed.endsWith("}");
    }

    private static boolean looksLikeJsonArray(String value) {
        String trimmed = value.trim();
        return trimmed.startsWith("[") && trimmed.endsWith("]");
    }

    private static String typeName(Object value) {
        return value == null ? "null" : value.getClass().getSimpleName();
    }
    
    
    private static Object getJsonValue(Response response, String jsonPath) {

        Object value = response.jsonPath().get(jsonPath);

        // RestAssured successfully resolved the path
        if (value != null) {
            return value;
        }

        // Only fallback for simple paths.
        // Do NOT try to manually parse Groovy/GPath expressions.
        if (jsonPath.contains("find {")) {
            return null;
        }

        return resolveNumericMapPath(response, jsonPath);
    }
    private static Object resolveNumericMapPath(Response response, String jsonPath) {

        String path = jsonPath;

        if (path.startsWith("$.")) {
            path = path.substring(2);
        }

        String[] parts = path.split("\\.");

        Object current = response.jsonPath().get("$");

        for (String part : parts) {

            if (current == null) {
                return null;
            }

            // Remove bracket notation:
            // ['0'] -> 0
            // ["0"] -> 0
            part = part.replaceAll("^\\['(.+)'\\]$", "$1");
            part = part.replaceAll("^\\[\"(.+)\"\\]$", "$1");

            if (current instanceof Map<?, ?> map) {

                if (map.containsKey(part)) {
                    current = map.get(part);
                } else {
                    return null;
                }

            } else if (current instanceof List<?> list) {

                try {
                    int index = Integer.parseInt(part);
                    current = list.get(index);
                } catch (NumberFormatException | IndexOutOfBoundsException e) {
                    return null;
                }

            } else {
                return null;
            }
        }

        return current;
    }
}
