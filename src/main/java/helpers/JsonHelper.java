package helpers;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import utils.JsonUtils;

public final class JsonHelper {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private JsonHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static String updateFieldAsString(String json, String jsonPath, String value) {
        return JsonUtils.updateJsonFieldAsString(json, jsonPath, value);
    }

    public static String updateField(String json, String jsonPath, Object value) {
        return JsonUtils.updateJsonField(json, jsonPath, value);
    }

    public static String updateFieldTyped(
            String json,
            String jsonPath,
            String type,
            String value) {

        return JsonUtils.updateJsonFieldTyped(
                json,
                jsonPath,
                type,
                value
        );
    }

    /**
     * Removes an object field or an array element. Supports paths like
     * {@code tags}, {@code meta.key}, {@code items[0]}, {@code items[0].name}.
     */
    public static String removeField(String json, String jsonPath) {
        try {
            return JsonUtils.removeJsonField(json, jsonPath);
        } catch (RuntimeException e) {
            throw new IllegalArgumentException(
                    "Failed to remove JSON field '" + jsonPath + "'",
                    e
            );
        }
    }

    /**
     * Adds a new field. Supported types match update: string, int, long, double,
     * boolean, list/array, map/object/dict, json, auto, null.
     */
    public static String addField(
            String json,
            String jsonPath,
            String type,
            String rawValue) {

        try {
            JsonNode root = OBJECT_MAPPER.readTree(json);

            String[] parts = jsonPath.split("\\.");

            JsonNode current = root;

            for (int i = 0; i < parts.length - 1; i++) {

                String part = parts[i];

                if (part.contains("[")) {

                    String fieldName =
                            part.substring(0, part.indexOf("["));

                    int index = Integer.parseInt(
                            part.substring(
                                    part.indexOf("[") + 1,
                                    part.indexOf("]")
                            )
                    );

                    JsonNode arrayNode = current.get(fieldName);

                    if (arrayNode == null || !arrayNode.isArray()) {
                        throw new IllegalArgumentException(
                                "JSON path does not exist: " + jsonPath
                        );
                    }

                    if (index >= arrayNode.size()) {
                        throw new IllegalArgumentException(
                                "Array index does not exist for JSON path: "
                                        + jsonPath
                        );
                    }

                    current = arrayNode.get(index);

                } else {

                    JsonNode next = current.get(part);

                    if (next == null) {
                        throw new IllegalArgumentException(
                                "Parent JSON path does not exist: "
                                        + jsonPath
                        );
                    }

                    current = next;
                }
            }

            if (!current.isObject()) {
                throw new IllegalArgumentException(
                        "Parent of JSON field is not an object: " + jsonPath
                );
            }

            String fieldName = parts[parts.length - 1];
            if (fieldName.contains("[")) {
                throw new IllegalArgumentException(
                        "Cannot add an array element with this step; add a field "
                                + "whose value is a list, or update an existing array index. Path: "
                                + jsonPath
                );
            }

            if (current.has(fieldName)) {
                throw new IllegalArgumentException(
                        "JSON field '" + jsonPath + "' already exists. "
                                + "Use 'I update JSON field' to change its value."
                );
            }

            String normalized = type == null ? "auto" : type.trim();
            Object typedValue = JsonUtils.parseTypedValue(normalized, rawValue);
            JsonNode valueNode = OBJECT_MAPPER.valueToTree(typedValue);

            ((ObjectNode) current).set(fieldName, valueNode);

            return OBJECT_MAPPER.writeValueAsString(root);

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Failed to add JSON field '" + jsonPath + "'",
                    e
            );
        }
    }
}
