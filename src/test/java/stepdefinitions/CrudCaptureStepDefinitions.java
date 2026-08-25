package stepdefinitions;

import context.ContextKeys;
import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CrudCaptureStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CrudCaptureStepDefinitions.class);

    private final TestContext testContext;

    public CrudCaptureStepDefinitions(TestContext testContext) {
        this.testContext = testContext;
    }

    @Then("I store response field {string} as variable id")
    public void i_store_response_field_as_variable_id(String jsonPath) {
        String value = requireFieldAsString(jsonPath, "variable id");
        testContext.setScenarioVariableId(value);
        logger.info("Stored response field '{}' = '{}' as {{VARIABLE_ID}} [thread={}]",
                jsonPath, value, Thread.currentThread().getName());
    }

    @Then("I store response field {string} as mapping id")
    public void i_store_response_field_as_mapping_id(String jsonPath) {
        String value = requireFieldAsString(jsonPath, "mapping id");
        testContext.setScenarioMappingId(value);
        logger.info("Stored response field '{}' = '{}' as {{MAPPING_ID}} [thread={}]",
                jsonPath, value, Thread.currentThread().getName());
    }
//
    @Given("I capture request field {string} as {string}")
public void i_capture_request_field_as(String jsonPath, String key) {

    String requestBody = testContext.getLastRequestBody();

    if (requestBody == null || requestBody.isBlank()) {
        throw new AssertionError(
                "Request body is empty; cannot store request field '"
                        + jsonPath + "' as '" + key + "'."
        );
    }

    Object raw = JsonPath.from(requestBody).get(jsonPath);

    if (raw == null) {
        throw new AssertionError(
                "Request field '" + jsonPath + "' is missing/null; cannot store as '"
                        + key + "'. Request body: " + requestBody
        );
    }

    if (raw instanceof String s && s.isBlank()) {
        throw new AssertionError(
                "Request field '" + jsonPath + "' is blank; cannot store as '"
                        + key + "'. Request body: " + requestBody
        );
    }

    testContext.captureObject(key, raw);

    logger.info(
            "Stored request field '{}' ({}) as {{CAPTURED:{}}} [thread={}]",
            jsonPath,
            describeType(raw),
            key,
            Thread.currentThread().getName()
    );
}
    @Then("I store response field {string} as {string}")
    @Given("I capture response field {string} as {string}")
    public void i_store_response_field_as(String jsonPath, String key) {
        Object raw = requireRawField(jsonPath, key);
        testContext.captureObject(key, raw);
        logger.info("Stored response field '{}' ({}) as {{CAPTURED:{}}} [thread={}]",
                jsonPath, describeType(raw), key, Thread.currentThread().getName());
    }

    @Then("I extract query parameter {string} from response path {string} and remember as {string}")
    public void i_extract_query_parameter_from_response_path_and_remember_as(
            String queryParam, String jsonPath, String rememberAs) {
        String field = requireFieldAsString(jsonPath, rememberAs);
        String value = extractQueryParameter(field, queryParam);
        if (value == null || value.isBlank()) {
            throw new AssertionError(
                    "Query parameter '" + queryParam + "' in response path '" + jsonPath
                            + "' is blank. Field: " + field);
        }
        testContext.captureObject(rememberAs, value);
        logger.info(
                "Extracted query '{}'='{}' from response path '{}' and remembered as {{CAPTURED:{}}} [thread={}]",
                queryParam, value, jsonPath, rememberAs, Thread.currentThread().getName());
    }

    @Then("the captured value {string} should equal captured value {string}")
    public void the_captured_value_should_equal_captured_value(String firstKey, String secondKey) {
        assertCapturedValuesEqual(firstKey, secondKey, true);
    }

    @Then("the captured value {string} should not equal captured value {string}")
    public void the_captured_value_should_not_equal_captured_value(String firstKey, String secondKey) {
        assertCapturedValuesEqual(firstKey, secondKey, false);
    }

    @Then("I validate captured values {string} and {string} are equal")
    public void i_validate_captured_values_are_equal(String firstKey, String secondKey) {
        assertCapturedValuesEqual(firstKey, secondKey, true);
    }

    @Then("I validate captured values {string} and {string} are not equal")
    public void i_validate_captured_values_are_not_equal(String firstKey, String secondKey) {
        assertCapturedValuesEqual(firstKey, secondKey, false);
    }

    @Then("I store response field {string} as map {string}")
    @Given("I capture response field {string} as map {string}")
    public void i_store_response_field_as_map(String jsonPath, String key) {
        Object raw = requireRawField(jsonPath, key);
        if (!(raw instanceof Map<?, ?>)) {
            throw new AssertionError("Response field '" + jsonPath + "' is not a JSON object/map (found "
                    + describeType(raw) + "). Body: " + activeResponse().getBody().asString());
        }
        testContext.captureObject(key, toStringKeyedMap((Map<?, ?>) raw));
        logger.info("Stored response field '{}' as map {{CAPTURED:{}}} [thread={}]",
                jsonPath, key, Thread.currentThread().getName());
    }

    @Then("I store response field {string} as list {string}")
    @Given("I capture response field {string} as list {string}")
    public void i_store_response_field_as_list(String jsonPath, String key) {
        Object raw = requireRawField(jsonPath, key);
        if (!(raw instanceof List<?>)) {
            throw new AssertionError("Response field '" + jsonPath + "' is not a JSON array/list (found "
                    + describeType(raw) + "). Body: " + activeResponse().getBody().asString());
        }
        testContext.captureObject(key, new ArrayList<>((List<?>) raw));
        logger.info("Stored response field '{}' as list {{CAPTURED:{}}} [thread={}]",
                jsonPath, key, Thread.currentThread().getName());
    }

    @Then("I store response field {string} as {string} allowing missing")
    @Given("I capture response field {string} as {string} allowing missing")
    public void i_store_response_field_as_allowing_missing(String jsonPath, String key) {
        Object raw = activeResponse().jsonPath().get(jsonPath);
        testContext.captureObject(key, raw == null ? "" : raw);
        logger.info("Stored response field '{}' ({}) as {{CAPTURED:{}}} (missing allowed) [thread={}]",
                jsonPath, describeType(raw), key, Thread.currentThread().getName());
    }

    @Then("I store response header {string} as {string}")
    @Given("I capture response header {string} as {string}")
    public void i_store_response_header_as(String headerName, String key) {
        String value = activeResponse().getHeader(headerName);
        if (value == null || value.isBlank()) {
            throw new AssertionError("Response header '" + headerName + "' is missing/blank; cannot store as '"
                    + key + "'.");
        }
        testContext.captureObject(key, value);
        logger.info("Stored response header '{}' = '{}' as {{CAPTURED:{}}} [thread={}]",
                headerName, value, key, Thread.currentThread().getName());
    }

    @Then("I store response fields:")
    @Given("I capture response fields for chaining:")
    public void i_store_response_fields(DataTable table) {
        List<List<String>> rows = table.asLists();
        if (rows.isEmpty()) {
            throw new IllegalArgumentException("Response field capture table must not be empty");
        }
        int start = 0;
        List<String> first = rows.get(0);
        boolean hasTypeColumn = first.size() >= 3;
        if (first.size() >= 2 && isHeaderRow(first.get(0), first.get(1))) {
            start = 1;
            hasTypeColumn = first.size() >= 3;
        }
        for (int i = start; i < rows.size(); i++) {
            List<String> row = rows.get(i);
            if (row.size() < 2) {
                throw new IllegalArgumentException(
                        "Each capture row needs jsonPath and key. Got: " + row);
            }
            String jsonPath = safe(row.get(0));
            String key = safe(row.get(1));
            String type = row.size() >= 3 ? safe(row.get(2)) : "";
            if (jsonPath.isEmpty() || key.isEmpty()) {
                throw new IllegalArgumentException(
                        "jsonPath and key must be non-blank in capture row: " + row);
            }
            if (hasTypeColumn && !type.isEmpty()) {
                storeTyped(jsonPath, key, type);
            } else {
                i_store_response_field_as(jsonPath, key);
            }
        }
    }

    @Given("I store the following as map {string}:")
    public void i_store_the_following_as_map(String key, DataTable table) {
        Map<String, Object> map = new LinkedHashMap<>();
        List<List<String>> rows = table.asLists();
        int start = 0;
        if (!rows.isEmpty() && rows.get(0).size() >= 2) {
            String c0 = safe(rows.get(0).get(0)).toLowerCase(Locale.ROOT);
            String c1 = safe(rows.get(0).get(1)).toLowerCase(Locale.ROOT);
            if (("key".equals(c0) || "field".equals(c0) || "name".equals(c0))
                    && ("value".equals(c1) || "val".equals(c1))) {
                start = 1;
            }
        }
        for (int i = start; i < rows.size(); i++) {
            List<String> row = rows.get(i);
            if (row.size() < 2) {
                throw new IllegalArgumentException("Map rows need key and value. Got: " + row);
            }
            map.put(safe(row.get(0)), safe(row.get(1)));
        }
        testContext.captureObject(key, map);
        logger.info("Stored table as map {{CAPTURED:{}}} with {} entries [thread={}]",
                key, map.size(), Thread.currentThread().getName());
    }

    @Given("I clear captured chaining values")
    public void i_clear_captured_chaining_values() {
        testContext.clearCapturedValues();
        logger.info("Cleared all captured chaining values [thread={}]", Thread.currentThread().getName());
    }

    @Given("I clear captured chaining value {string}")
    public void i_clear_captured_chaining_value(String key) {
        if (!testContext.hasCapturedValue(key)) {
            logger.warn("No captured value '{}' to clear [thread={}]", key, Thread.currentThread().getName());
        }
        testContext.clearCapturedValue(key);
        logger.info("Cleared captured chaining value '{{CAPTURED:{}}}' [thread={}]",
                key, Thread.currentThread().getName());
    }

    private void storeTyped(String jsonPath, String key, String type) {
        String normalized = type.toLowerCase(Locale.ROOT);
        switch (normalized) {
            case "map", "object", "dict" -> i_store_response_field_as_map(jsonPath, key);
            case "list", "array" -> i_store_response_field_as_list(jsonPath, key);
            case "string", "str", "text", "auto", "any", "json" -> i_store_response_field_as(jsonPath, key);
            default -> throw new IllegalArgumentException(
                    "Unsupported capture type '" + type + "'. Use map, list, string, or json.");
        }
    }

    private boolean isHeaderRow(String col0, String col1) {
        String a = col0 == null ? "" : col0.trim().toLowerCase(Locale.ROOT);
        String b = col1 == null ? "" : col1.trim().toLowerCase(Locale.ROOT);
        return ("jsonpath".equals(a) || "path".equals(a) || "field".equals(a))
                && ("as".equals(b) || "key".equals(b) || "name".equals(b));
    }

    private String requireFieldAsString(String jsonPath, String keyLabel) {
        Object raw = requireRawField(jsonPath, keyLabel);
        String value = TestContext.stringifyCaptured(raw);
        if (value == null || value.isBlank()) {
            throw new AssertionError("Response field '" + jsonPath + "' is missing/blank; cannot store as '"
                    + keyLabel + "'. Body: " + activeResponse().getBody().asString());
        }
        return value;
    }

    private Object requireRawField(String jsonPath, String keyLabel) {
        Object raw = activeResponse().jsonPath().get(jsonPath);
        if (raw == null) {
            throw new AssertionError("Response field '" + jsonPath + "' is missing/null; cannot store as '"
                    + keyLabel + "'. Body: " + activeResponse().getBody().asString());
        }
        if (raw instanceof String s && s.isBlank()) {
            throw new AssertionError("Response field '" + jsonPath + "' is blank; cannot store as '"
                    + keyLabel + "'. Body: " + activeResponse().getBody().asString());
        }
        return raw;
    }

    

    private static Map<String, Object> toStringKeyedMap(Map<?, ?> raw) {
        Map<String, Object> map = new LinkedHashMap<>();
        for (Map.Entry<?, ?> entry : raw.entrySet()) {
            map.put(String.valueOf(entry.getKey()), entry.getValue());
        }
        return map;
    }

    private static String describeType(Object raw) {
        if (raw == null) {
            return "null";
        }
        if (raw instanceof Map) {
            return "map";
        }
        if (raw instanceof List) {
            return "list";
        }
        return raw.getClass().getSimpleName();
    }

    private static String safe(String value) {
        return value == null ? "" : value.trim();
    }

    /**
     * Reads {@code queryParam} from a URL or from HTML that contains an {@code href}
     * (including relative paths and {@code &amp;} entities).
     */
    static String extractQueryParameter(String text, String queryParam) {
        if (text == null || queryParam == null || queryParam.isBlank()) {
            return null;
        }
        String decodedHtml = text.replace("&amp;", "&");
        List<String> candidates = new ArrayList<>();
        Matcher href = Pattern.compile("(?i)href\\s*=\\s*['\"]([^'\"]+)['\"]").matcher(decodedHtml);
        while (href.find()) {
            candidates.add(href.group(1));
        }
        candidates.add(decodedHtml);

        Pattern qp = Pattern.compile("[?&]" + Pattern.quote(queryParam) + "=([^&\"'<>\\s]*)");
        for (String candidate : candidates) {
            Matcher matcher = qp.matcher(candidate);
            if (matcher.find()) {
                return URLDecoder.decode(matcher.group(1), StandardCharsets.UTF_8);
            }
        }
        throw new AssertionError(
                "Query parameter '" + queryParam + "' was not found in: " + text);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }

    private void assertCapturedValuesEqual(String firstKey, String secondKey, boolean expectEqual) {
        String leftKey = unwrapCapturedKey(firstKey);
        String rightKey = unwrapCapturedKey(secondKey);
        String left = TestContext.stringifyCaptured(testContext.getCapturedObject(leftKey));
        String right = TestContext.stringifyCaptured(testContext.getCapturedObject(rightKey));
        boolean equal = Objects.equals(left, right);
        if (expectEqual && !equal) {
            throw new AssertionError(
                    "Captured values are not equal: {{CAPTURED:" + leftKey + "}}='" + left
                            + "' vs {{CAPTURED:" + rightKey + "}}='" + right + "'");
        }
        if (!expectEqual && equal) {
            throw new AssertionError(
                    "Captured values were expected to differ but both are '" + left
                            + "' ({{CAPTURED:" + leftKey + "}} and {{CAPTURED:" + rightKey + "}})");
        }
        logger.info(
                "Captured value comparison {}: {{CAPTURED:{}}}='{}' {} {{CAPTURED:{}}}='{}'",
                expectEqual ? "equal" : "not equal",
                leftKey, left, expectEqual ? "==" : "!=", rightKey, right);
    }

    private static String unwrapCapturedKey(String key) {
        if (key == null || key.isBlank()) {
            throw new AssertionError("Captured key must not be blank");
        }
        String trimmed = key.trim();
        if (trimmed.startsWith(ContextKeys.CAPTURED_PREFIX) && trimmed.endsWith("}")) {
            return trimmed.substring(ContextKeys.CAPTURED_PREFIX.length(), trimmed.length() - 1).trim();
        }
        return trimmed;
    }
}
