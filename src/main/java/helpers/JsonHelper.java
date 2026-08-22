package helpers;

import utils.JsonUtils;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.BooleanNode;
import com.fasterxml.jackson.databind.node.DoubleNode;
import com.fasterxml.jackson.databind.node.FloatNode;
import com.fasterxml.jackson.databind.node.IntNode;
import com.fasterxml.jackson.databind.node.LongNode;
import com.fasterxml.jackson.databind.node.NullNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.TextNode;

public final class JsonHelper {

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
    
    public static String removeField(String json, String jsonPath) {

        try {
            ObjectMapper objectMapper = new ObjectMapper();

            JsonNode root = objectMapper.readTree(json);

            String[] parts = jsonPath.split("\\.");

            JsonNode current = root;

            for (int i = 0; i < parts.length - 1; i++) {

                String part = parts[i];

                if (part.contains("[")) {
                    String fieldName = part.substring(0, part.indexOf("["));
                    int index = Integer.parseInt(
                            part.substring(
                                    part.indexOf("[") + 1,
                                    part.indexOf("]")
                            )
                    );

                    current = current.get(fieldName).get(index);

                } else {
                    current = current.get(part);
                }

                if (current == null) {
                    throw new IllegalArgumentException(
                            "JSON path does not exist: " + jsonPath
                    );
                }
            }

            String lastPart = parts[parts.length - 1];

            if (lastPart.contains("[")) {
                throw new IllegalArgumentException(
                        "Removing array elements is not supported by this method: "
                                + jsonPath
                );
            }

            if (!current.isObject()) {
                throw new IllegalArgumentException(
                        "Parent of JSON field is not an object: " + jsonPath
                );
            }

            ((ObjectNode) current).remove(lastPart);

            return objectMapper.writeValueAsString(root);

        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Failed to remove JSON field '" + jsonPath + "'",
                    e
            );
        }
    }
    public static String addField(
            String json,
            String jsonPath,
            String type,
            String rawValue) {

        try {
            ObjectMapper objectMapper = new ObjectMapper();

            JsonNode root = objectMapper.readTree(json);

            String[] parts = jsonPath.split("\\.");

            JsonNode current = root;

            // Navigate to parent
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

            // Field already exists → fail
            if (current.has(fieldName)) {
                throw new IllegalArgumentException(
                        "JSON field '" + jsonPath + "' already exists. "
                                + "Use 'I update JSON field' to change its value."
                );
            }

            // Create value according to type
            JsonNode valueNode;

            if ("null".equalsIgnoreCase(type)) {

                valueNode = NullNode.getInstance();

            } else if ("string".equalsIgnoreCase(type)) {

                valueNode = TextNode.valueOf(
                        rawValue == null ? "" : rawValue
                );

            } else if ("boolean".equalsIgnoreCase(type)) {

                valueNode = BooleanNode.valueOf(
                        Boolean.parseBoolean(rawValue)
                );

            } else if ("integer".equalsIgnoreCase(type)
                    || "int".equalsIgnoreCase(type)) {

                valueNode = IntNode.valueOf(
                        Integer.parseInt(rawValue)
                );

            } else if ("long".equalsIgnoreCase(type)) {

                valueNode = LongNode.valueOf(
                        Long.parseLong(rawValue)
                );

            } else if ("double".equalsIgnoreCase(type)) {

                valueNode = DoubleNode.valueOf(
                        Double.parseDouble(rawValue)
                );

            } else if ("float".equalsIgnoreCase(type)) {

                valueNode = FloatNode.valueOf(
                        Float.parseFloat(rawValue)
                );

            } else {

                throw new IllegalArgumentException(
                        "Unsupported JSON field type '" + type
                                + "' for field '" + jsonPath + "'"
                );
            }

            ((ObjectNode) current).set(fieldName, valueNode);

            return objectMapper.writeValueAsString(root);

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
