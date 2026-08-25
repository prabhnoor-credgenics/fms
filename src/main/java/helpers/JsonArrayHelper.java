package helpers;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.restassured.response.Response;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public final class JsonArrayHelper {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final Pattern PATH_SEGMENT =
            Pattern.compile("([^.\\[\\]]+)|\\[(\\d+)]");

    private JsonArrayHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static List<?> requireAnyArray(Response response, String arrayPath) {
        return requireAnyArray(response, arrayPath, true);
    }

    public static List<?> requireAnyArray(Response response, String arrayPath, boolean allowEmpty) {
        if (response == null) {
            throw new IllegalStateException("No API response available. Send a request first.");
        }
        if (arrayPath == null || arrayPath.isBlank()) {
            throw new IllegalArgumentException("Array path must not be blank");
        }

        String path = arrayPath.trim();
        Object raw = response.jsonPath().get(path);
        if (raw == null) {
            raw = resolveThroughStringifiedJson(response.getBody().asString(), path);
        }
        if (raw == null) {
            throw new AssertionError(
                    "Array path '" + arrayPath + "' is missing/null in response. Body: "
                            + response.getBody().asString());
        }
        if (!(raw instanceof List<?> list)) {
            throw new AssertionError(
                    "Path '" + arrayPath + "' is not a JSON array (found "
                            + raw.getClass().getSimpleName() + "). Body: "
                            + response.getBody().asString());
        }
        if (!allowEmpty && list.isEmpty()) {
            throw new AssertionError("Array path '" + arrayPath + "' is empty.");
        }
        return list;
    }

    /**
     * Walks a dotted path and parses intermediate string values that contain JSON
     * (e.g. {@code output} is a stringified object, then {@code variable_filter_value}).
     */
    static Object resolveThroughStringifiedJson(String body, String path) {
        if (body == null || body.isBlank() || path == null || path.isBlank()) {
            return null;
        }
        try {
            JsonNode node = OBJECT_MAPPER.readTree(body);
            Matcher matcher = PATH_SEGMENT.matcher(path.trim());
            boolean matched = false;
            while (matcher.find()) {
                matched = true;
                node = unwrapStringifiedJson(node);
                if (node == null || node.isMissingNode() || node.isNull()) {
                    return null;
                }
                String field = matcher.group(1);
                String index = matcher.group(2);
                if (field != null) {
                    if (!node.isObject()) {
                        return null;
                    }
                    node = node.get(field);
                } else if (index != null) {
                    if (!node.isArray()) {
                        return null;
                    }
                    int i = Integer.parseInt(index);
                    if (i < 0 || i >= node.size()) {
                        return null;
                    }
                    node = node.get(i);
                }
            }
            if (!matched) {
                return null;
            }
            node = unwrapStringifiedJson(node);
            if (node == null || node.isMissingNode() || node.isNull()) {
                return null;
            }
            return OBJECT_MAPPER.convertValue(node, Object.class);
        } catch (Exception e) {
            return null;
        }
    }

    private static JsonNode unwrapStringifiedJson(JsonNode node) throws Exception {
        if (node == null || !node.isTextual()) {
            return node;
        }
        String text = node.asText().trim();
        if (!(text.startsWith("{") || text.startsWith("["))) {
            return node;
        }
        return OBJECT_MAPPER.readTree(text);
    }

    @SuppressWarnings("unchecked")
    public static List<Map<String, Object>> requireObjectArray(Response response, String arrayPath) {
        return requireObjectArray(response, arrayPath, false);
    }

    @SuppressWarnings("unchecked")
    public static List<Map<String, Object>> requireObjectArray(
            Response response,
            String arrayPath,
            boolean allowEmpty
    ) {
        List<?> list = requireAnyArray(response, arrayPath, allowEmpty);
        for (Object item : list) {
            if (!(item instanceof Map<?, ?>)) {
                throw new AssertionError(
                        "Array path '" + arrayPath + "' must contain JSON objects. Found item type: "
                                + (item == null ? "null" : item.getClass().getSimpleName()));
            }
        }
        return (List<Map<String, Object>>) (List<?>) list;
    }

    public static int size(Response response, String arrayPath) {
        return requireAnyArray(response, arrayPath, true).size();
    }

    public static void assertEmpty(Response response, String arrayPath) {
        int actual = size(response, arrayPath);
        if (actual != 0) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' to be empty but size was " + actual + "."
            );
        }
    }

    public static void assertNotEmpty(Response response, String arrayPath) {
        int actual = size(response, arrayPath);
        if (actual == 0) {
            throw new AssertionError("Expected array '" + arrayPath + "' to be not empty but it was empty.");
        }
    }

    public static void assertSizeEquals(Response response, String arrayPath, int expected) {
        int actual = size(response, arrayPath);
        if (actual != expected) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' size to be " + expected
                            + " but was " + actual + "."
            );
        }
    }

    public static void assertSizeGreaterThan(Response response, String arrayPath, int minExclusive) {
        int actual = size(response, arrayPath);
        if (!(actual > minExclusive)) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' size > " + minExclusive
                            + " but was " + actual + "."
            );
        }
    }

    public static void assertSizeLessThan(Response response, String arrayPath, int maxExclusive) {
        int actual = size(response, arrayPath);
        if (!(actual < maxExclusive)) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' size < " + maxExclusive
                            + " but was " + actual + "."
            );
        }
    }

    public static void assertSizeAtLeast(Response response, String arrayPath, int minInclusive) {
        int actual = size(response, arrayPath);
        if (actual < minInclusive) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' size >= " + minInclusive
                            + " but was " + actual + "."
            );
        }
    }

    public static void assertSizeAtMost(Response response, String arrayPath, int maxInclusive) {
        int actual = size(response, arrayPath);
        if (actual > maxInclusive) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' size <= " + maxInclusive
                            + " but was " + actual + "."
            );
        }
    }

    public static void assertSizeBetween(
            Response response,
            String arrayPath,
            int minInclusive,
            int maxInclusive
    ) {
        if (minInclusive > maxInclusive) {
            throw new IllegalArgumentException(
                    "Invalid size range: min (" + minInclusive + ") > max (" + maxInclusive + ")"
            );
        }
        int actual = size(response, arrayPath);
        if (actual < minInclusive || actual > maxInclusive) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' size between " + minInclusive
                            + " and " + maxInclusive + " (inclusive) but was " + actual + "."
            );
        }
    }

    public static Map<String, Object> findObjectByReference(
            List<Map<String, Object>> array,
            String referenceKey,
            String referenceValue
    ) {
        Map<String, Object> match = findObjectByReferenceOrNull(array, referenceKey, referenceValue);
        if (match == null) {
            throw new AssertionError(
                    "No array item found where '" + referenceKey + "' = '" + referenceValue + "'."
            );
        }
        return match;
    }

    public static Map<String, Object> findObjectByReferenceOrNull(
            List<Map<String, Object>> array,
            String referenceKey,
            String referenceValue
    ) {
        if (referenceKey == null || referenceKey.isBlank()) {
            throw new IllegalArgumentException("Reference key must not be blank");
        }
        String expected = referenceValue == null ? "" : referenceValue.trim();

        for (Map<String, Object> item : array) {
            if (!item.containsKey(referenceKey)) {
                continue;
            }
            String actual = stringify(item.get(referenceKey));
            if (Objects.equals(actual, expected)) {
                return item;
            }
        }

        // header-list shape: [{ "header": "...", "options": [{ "label": "...", "value": ... }] }]
        for (Map<String, Object> item : array) {
            for (Object nested : item.values()) {
                List<Map<String, Object>> nestedObjects = asObjectMapListOrNull(nested);
                if (nestedObjects == null || nestedObjects.isEmpty()) {
                    continue;
                }
                Map<String, Object> found =
                        findObjectByReferenceOrNull(nestedObjects, referenceKey, referenceValue);
                if (found != null) {
                    return found;
                }
            }
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private static List<Map<String, Object>> asObjectMapListOrNull(Object value) {
        if (!(value instanceof List<?> list) || list.isEmpty()) {
            return null;
        }
        for (Object item : list) {
            if (!(item instanceof Map<?, ?>)) {
                return null;
            }
        }
        return (List<Map<String, Object>>) (List<?>) list;
    }

    public static void assertContainsItem(
            Response response,
            String arrayPath,
            String referenceKey,
            String referenceValue
    ) {
        List<Map<String, Object>> array = requireObjectArray(response, arrayPath, true);
        if (findObjectByReferenceOrNull(array, referenceKey, referenceValue) == null) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' to contain an item where '"
                            + referenceKey + "' = '" + referenceValue + "'."
            );
        }
    }

    public static void assertDoesNotContainItem(
            Response response,
            String arrayPath,
            String referenceKey,
            String referenceValue
    ) {
        List<Map<String, Object>> array = requireObjectArray(response, arrayPath, true);
        if (findObjectByReferenceOrNull(array, referenceKey, referenceValue) != null) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' to NOT contain an item where '"
                            + referenceKey + "' = '" + referenceValue + "'."
            );
        }
    }

    public static void assertEveryItemHasKey(Response response, String arrayPath, String key) {
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException("Key must not be blank");
        }
        List<Map<String, Object>> array = requireObjectArray(response, arrayPath, false);
        for (int i = 0; i < array.size(); i++) {
            Map<String, Object> item = array.get(i);
            if (!item.containsKey(key)) {
                throw new AssertionError(
                        "Expected every item in array '" + arrayPath + "' to have key '" + key
                                + "'. Missing at index " + i + ". Item: " + item
                );
            }
        }
    }

    public static void assertEveryItemFieldEquals(
            Response response,
            String arrayPath,
            String key,
            String expectedValue
    ) {
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException("Key must not be blank");
        }
        String expected = expectedValue == null ? "" : expectedValue.trim();
        List<Map<String, Object>> array = requireObjectArray(response, arrayPath, false);
        for (int i = 0; i < array.size(); i++) {
            Map<String, Object> item = array.get(i);
            if (!item.containsKey(key)) {
                throw new AssertionError(
                        "Expected every item in array '" + arrayPath + "' to have key '" + key
                                + "'. Missing at index " + i + ". Item: " + item
                );
            }
            String actual = stringify(item.get(key));
            if (!Objects.equals(actual, expected)) {
                throw new AssertionError(
                        "Expected every item in array '" + arrayPath + "' to have '" + key
                                + "' = '" + expected + "'. At index " + i + " actual was '"
                                + actual + "'. Item: " + item
                );
            }
        }
    }

    public static void assertValuesUnique(Response response, String arrayPath, String key) {
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException("Key must not be blank");
        }
        List<Map<String, Object>> array = requireObjectArray(response, arrayPath, false);
        Set<String> seen = new HashSet<>();
        for (int i = 0; i < array.size(); i++) {
            Map<String, Object> item = array.get(i);
            if (!item.containsKey(key)) {
                throw new AssertionError(
                        "Cannot assert uniqueness of '" + key + "' in array '" + arrayPath
                                + "': missing at index " + i + ". Item: " + item
                );
            }
            String value = stringify(item.get(key));
            if (!seen.add(value)) {
                throw new AssertionError(
                        "Expected values of '" + key + "' in array '" + arrayPath
                                + "' to be unique. Duplicate value '" + value + "' found at index " + i + "."
                );
            }
        }
    }

    public static List<String> extractAllFieldValues(Response response, String arrayPath, String key) {
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException("Key must not be blank");
        }
        List<Map<String, Object>> array = requireObjectArray(response, arrayPath, true);
        List<String> values = new ArrayList<>(array.size());
        for (int i = 0; i < array.size(); i++) {
            Map<String, Object> item = array.get(i);
            if (!item.containsKey(key)) {
                throw new AssertionError(
                        "Cannot extract '" + key + "' from array '" + arrayPath
                                + "': missing at index " + i + ". Item: " + item
                );
            }
            values.add(stringify(item.get(key)));
        }
        return values;
    }

    public static int countMatching(
            Response response,
            String arrayPath,
            String referenceKey,
            String referenceValue
    ) {
        List<Map<String, Object>> array = requireObjectArray(response, arrayPath, true);
        String expected = referenceValue == null ? "" : referenceValue.trim();
        int count = 0;
        for (Map<String, Object> item : array) {
            if (!item.containsKey(referenceKey)) {
                continue;
            }
            if (Objects.equals(stringify(item.get(referenceKey)), expected)) {
                count++;
            }
        }
        return count;
    }

    public static void assertMatchCount(
            Response response,
            String arrayPath,
            String referenceKey,
            String referenceValue,
            int expectedCount
    ) {
        int actual = countMatching(response, arrayPath, referenceKey, referenceValue);
        if (actual != expectedCount) {
            throw new AssertionError(
                    "Expected array '" + arrayPath + "' to have " + expectedCount
                            + " item(s) where '" + referenceKey + "' = '" + referenceValue
                            + "' but found " + actual + "."
            );
        }
    }

    public static String extractField(
            Response response,
            String arrayPath,
            String referenceKey,
            String referenceValue,
            String targetKey
    ) {
        if (targetKey == null || targetKey.isBlank()) {
            throw new IllegalArgumentException("Target key must not be blank");
        }
        Map<String, Object> match = findObjectByReference(
                requireObjectArray(response, arrayPath),
                referenceKey,
                referenceValue
        );
        if (!match.containsKey(targetKey)) {
            throw new AssertionError(
                    "Matched item where '" + referenceKey + "' = '" + referenceValue
                            + "' does not contain key '" + targetKey + "'. Item: " + match
            );
        }
        Object value = match.get(targetKey);
        if (value == null) {
            throw new AssertionError(
                    "Matched item where '" + referenceKey + "' = '" + referenceValue
                            + "' has null value for key '" + targetKey + "'. Item: " + match
            );
        }
        String asString = stringify(value);
        if (asString.isBlank()) {
            throw new AssertionError(
                    "Matched item where '" + referenceKey + "' = '" + referenceValue
                            + "' has blank value for key '" + targetKey + "'. Item: " + match
            );
        }
        return asString;
    }

    public static void validateField(
            Response response,
            String arrayPath,
            String referenceKey,
            String referenceValue,
            String targetKey,
            String expectedValue
    ) {
        if (targetKey == null || targetKey.isBlank()) {
            throw new IllegalArgumentException("Target key must not be blank");
        }
        Map<String, Object> match = findObjectByReference(
                requireObjectArray(response, arrayPath),
                referenceKey,
                referenceValue
        );
        if (!match.containsKey(targetKey)) {
            throw new AssertionError(
                    "Matched item where '" + referenceKey + "' = '" + referenceValue
                            + "' does not contain key '" + targetKey + "'. Item: " + match
            );
        }
        String actual = stringify(match.get(targetKey));
        String expected = expectedValue == null ? "" : expectedValue.trim();
        if (!Objects.equals(actual, expected)) {
            throw new AssertionError(
                    "Array validation failed for path '" + arrayPath + "'. "
                            + "Reference: " + referenceKey + "='" + referenceValue + "'. "
                            + "Target key: '" + targetKey + "'. "
                            + "Expected: '" + expected + "'. "
                            + "Actual: '" + actual + "'."
            );
        }
    }

    public static String stringify(Object value) {
        if (value == null) {
            return "";
        }
        return String.valueOf(value).trim();
    }
}
