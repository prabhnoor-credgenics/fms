package helpers;

import io.restassured.response.Response;

import java.util.List;
import java.util.Map;

/**
 * Asserts whether a JSON object or array items contain (or do not contain) a given key.
 */
public final class JsonKeyHelper {

    private JsonKeyHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    @SuppressWarnings("unchecked")
    public static Map<String, Object> requireObject(Response response, String objectPath) {
        if (response == null) {
            throw new IllegalStateException("No API response available. Send a request first.");
        }
        if (objectPath == null || objectPath.isBlank() || "$".equals(objectPath.trim())) {
            Object root = response.jsonPath().get("$");
            if (!(root instanceof Map<?, ?>)) {
                throw new AssertionError(
                        "Response root is not a JSON object (found "
                                + (root == null ? "null" : root.getClass().getSimpleName()) + ")."
                );
            }
            return (Map<String, Object>) root;
        }

        Object raw = response.jsonPath().get(objectPath.trim());
        if (raw == null) {
            throw new AssertionError(
                    "JSON object path '" + objectPath + "' is missing/null in response. Body: "
                            + response.getBody().asString()
            );
        }
        if (!(raw instanceof Map<?, ?>)) {
            throw new AssertionError(
                    "Path '" + objectPath + "' is not a JSON object (found "
                            + raw.getClass().getSimpleName() + "). Body: "
                            + response.getBody().asString()
            );
        }
        return (Map<String, Object>) raw;
    }

    public static void assertObjectContainsKey(Response response, String objectPath, String key) {
        requireKey(key);
        Map<String, Object> object = requireObject(response, objectPath);
        if (!object.containsKey(key)) {
            throw new AssertionError(
                    "Expected JSON object at '" + displayPath(objectPath)
                            + "' to contain key '" + key + "'. Keys present: " + object.keySet()
            );
        }
    }

    public static void assertObjectDoesNotContainKey(Response response, String objectPath, String key) {
        requireKey(key);
        Map<String, Object> object = requireObject(response, objectPath);
        if (object.containsKey(key)) {
            throw new AssertionError(
                    "Expected JSON object at '" + displayPath(objectPath)
                            + "' to NOT contain key '" + key + "'."
            );
        }
    }

    public static void assertAnyItemHasKey(Response response, String arrayPath, String key) {
        requireKey(key);
        List<Map<String, Object>> array = JsonArrayHelper.requireObjectArray(response, arrayPath, true);
        for (Map<String, Object> item : array) {
            if (item.containsKey(key)) {
                return;
            }
        }
        throw new AssertionError(
                "Expected at least one item in array '" + arrayPath
                        + "' to contain key '" + key + "'."
        );
    }

    public static void assertNoItemHasKey(Response response, String arrayPath, String key) {
        requireKey(key);
        List<Map<String, Object>> array = JsonArrayHelper.requireObjectArray(response, arrayPath, true);
        for (int i = 0; i < array.size(); i++) {
            Map<String, Object> item = array.get(i);
            if (item.containsKey(key)) {
                throw new AssertionError(
                        "Expected no item in array '" + arrayPath
                                + "' to contain key '" + key + "'. Found at index " + i + "."
                );
            }
        }
    }

    public static void assertMatchedItemContainsKey(
            Response response,
            String arrayPath,
            String referenceKey,
            String referenceValue,
            String key
    ) {
        requireKey(key);
        Map<String, Object> match = JsonArrayHelper.findObjectByReference(
                JsonArrayHelper.requireObjectArray(response, arrayPath, false),
                referenceKey,
                referenceValue
        );
        if (!match.containsKey(key)) {
            throw new AssertionError(
                    "Expected matched item in array '" + arrayPath + "' where '"
                            + referenceKey + "' = '" + referenceValue
                            + "' to contain key '" + key + "'. Item: " + match
            );
        }
    }

    public static void assertMatchedItemDoesNotContainKey(
            Response response,
            String arrayPath,
            String referenceKey,
            String referenceValue,
            String key
    ) {
        requireKey(key);
        Map<String, Object> match = JsonArrayHelper.findObjectByReference(
                JsonArrayHelper.requireObjectArray(response, arrayPath, false),
                referenceKey,
                referenceValue
        );
        if (match.containsKey(key)) {
            throw new AssertionError(
                    "Expected matched item in array '" + arrayPath + "' where '"
                            + referenceKey + "' = '" + referenceValue
                            + "' to NOT contain key '" + key + "'. Item: " + match
            );
        }
    }

    private static void requireKey(String key) {
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException("Key must not be blank");
        }
    }

    private static String displayPath(String objectPath) {
        if (objectPath == null || objectPath.isBlank() || "$".equals(objectPath.trim())) {
            return "$";
        }
        return objectPath.trim();
    }
}
