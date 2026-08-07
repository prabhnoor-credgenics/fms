package utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class JsonUtils {
    private static final Logger logger = LogManager.getLogger(JsonUtils.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    private static final String TEST_RESOURCES_PATH = "src/test/resources/";
    private static final Pattern SEGMENT_PATTERN = Pattern.compile("([^.\\[\\]]+)|\\[(\\d+)]");

    private JsonUtils() {
    }

    public static String readJsonFromFile(String filePath) {
        File file = new File(TEST_RESOURCES_PATH + filePath);
        try (InputStream inputStream = new FileInputStream(file)) {
            byte[] bytes = inputStream.readAllBytes();
            String jsonContent = new String(bytes);
            logger.info("Successfully loaded JSON from file: {}", file.getPath());
            return jsonContent;
        } catch (Exception e) {
            logger.error("Error reading JSON file '{}': {}", file.getPath(), e.getMessage(), e);
            throw new RuntimeException("Failed to read JSON file: " + file.getPath(), e);
        }
    }

    public static String prettyPrint(String jsonString) {
        try {
            Object jsonObject = objectMapper.readValue(jsonString, Object.class);
            String prettyJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(jsonObject);
            logger.debug("Pretty printed JSON");
            return prettyJson;
        } catch (Exception e) {
            logger.error("Error pretty printing JSON: {}", e.getMessage(), e);
            return jsonString;
        }
    }

    public static String updateJsonFieldAsString(String jsonString, String jsonPath, String newValue) {
        return updateJsonFieldTyped(jsonString, jsonPath, "string", newValue);
    }

    public static String updateJsonField(String jsonString, String jsonPath, Object newValue) {
        return updateJsonFieldInternal(jsonString, jsonPath, newValue, false);
    }

    public static String updateJsonFieldTyped(String jsonString, String jsonPath, String type, String rawValue) {
        String normalized = type == null ? "" : type.trim().toLowerCase(Locale.ROOT);
        Object typedValue = parseTypedValue(normalized.isEmpty() ? "auto" : normalized, rawValue);
        boolean forceString = isStringType(normalized);
        return updateJsonFieldInternal(jsonString, jsonPath, typedValue, forceString);
    }

    public static Object parseTypedValue(String type, String rawValue) {
        if (type == null || type.isBlank()) {
            throw new IllegalArgumentException("JSON field type must be provided");
        }
        String normalized = type.trim().toLowerCase(Locale.ROOT);
        if ("null".equals(normalized)) {
            return null;
        }

        String value = rawValue == null ? "" : rawValue.trim();
        try {
            return switch (normalized) {
                case "string", "str", "text" -> value;
                case "int", "integer" -> Integer.valueOf(value);
                case "long" -> Long.valueOf(value);
                case "double", "float", "number", "decimal" -> Double.valueOf(value);
                case "boolean", "bool" -> parseBooleanStrict(value);
                case "list", "array" -> parseJsonAs(value, true);
                case "map", "object", "dict" -> parseJsonAs(value, false);
                case "json" -> objectMapper.readTree(value);
                case "auto", "any", "coerce" -> value;
                default -> throw new IllegalArgumentException(
                        "Unsupported JSON field type '" + type + "'. Supported: string, int, long, double, "
                                + "boolean, list, map, json, auto, null");
            };
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Cannot parse value '" + rawValue + "' as type '" + type + "': " + e.getMessage(), e);
        }
    }

    public static Object parseTypedValueAsJava(String type, String rawValue) {
        Object typed = parseTypedValue(type, rawValue);
        if (typed instanceof JsonNode node) {
            return objectMapper.convertValue(node, Object.class);
        }
        return typed;
    }

    private static boolean isStringType(String normalizedType) {
        return "string".equals(normalizedType)
                || "str".equals(normalizedType)
                || "text".equals(normalizedType);
    }

    private static Boolean parseBooleanStrict(String value) {
        if ("true".equalsIgnoreCase(value)) {
            return Boolean.TRUE;
        }
        if ("false".equalsIgnoreCase(value)) {
            return Boolean.FALSE;
        }
        throw new IllegalArgumentException("Boolean value must be true or false, got: " + value);
    }

    private static JsonNode parseJsonAs(String value, boolean requireArray) throws Exception {
        JsonNode node = objectMapper.readTree(value);
        if (requireArray && !node.isArray()) {
            throw new IllegalArgumentException("Expected a JSON array, got: " + value);
        }
        if (!requireArray && !node.isObject()) {
            throw new IllegalArgumentException("Expected a JSON object, got: " + value);
        }
        return node;
    }

    private static String updateJsonFieldInternal(String jsonString, String jsonPath, Object newValue, boolean forceString) {
        try {
            JsonNode rootNode = objectMapper.readTree(jsonString);
            List<PathSegment> segments = parsePath(jsonPath);
            if (segments.isEmpty()) {
                throw new IllegalArgumentException("JSON path must not be empty");
            }

            JsonNode valueNode = toNode(newValue, forceString);
            ensureContainerRoot(rootNode, segments.get(0));

            JsonNode parent = rootNode;
            for (int i = 0; i < segments.size() - 1; i++) {
                PathSegment segment = segments.get(i);
                PathSegment next = segments.get(i + 1);
                parent = descendCreating(parent, segment, next);
            }

            PathSegment last = segments.get(segments.size() - 1);
            setAtSegment(parent, last, valueNode);

            logger.info("Updated JSON path '{}' ({} level(s))", jsonPath, segments.size());
            return objectMapper.writeValueAsString(rootNode);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            logger.error("Error updating JSON field '{}': {}", jsonPath, e.getMessage(), e);
            throw new RuntimeException("Failed to update JSON field: " + jsonPath, e);
        }
    }

    public static String removeJsonField(String jsonString, String jsonPath) {
        try {
            JsonNode rootNode = objectMapper.readTree(jsonString);
            List<PathSegment> segments = parsePath(jsonPath);
            if (segments.isEmpty()) {
                return jsonString;
            }

            JsonNode parent = rootNode;
            for (int i = 0; i < segments.size() - 1; i++) {
                parent = descendExisting(parent, segments.get(i));
                if (parent == null) {
                    logger.warn("Path '{}' not found in JSON; field not removed", jsonPath);
                    return jsonString;
                }
            }

            PathSegment last = segments.get(segments.size() - 1);
            if (last.fieldName != null) {
                if (!parent.isObject()) {
                    logger.warn("Cannot remove field '{}' — parent is not an object", jsonPath);
                    return jsonString;
                }
                ((ObjectNode) parent).remove(last.fieldName);
            } else {
                if (!parent.isArray()) {
                    logger.warn("Cannot remove index '{}' — parent is not an array", jsonPath);
                    return jsonString;
                }
                ((ArrayNode) parent).remove(last.index);
            }

            return objectMapper.writeValueAsString(rootNode);
        } catch (Exception e) {
            logger.error("Error removing JSON field '{}': {}", jsonPath, e.getMessage(), e);
            throw new RuntimeException("Failed to remove JSON field: " + jsonPath, e);
        }
    }

    static List<PathSegment> parsePath(String jsonPath) {
        if (jsonPath == null || jsonPath.isBlank()) {
            return List.of();
        }
        String normalized = jsonPath.trim();
        if (normalized.startsWith("$.")) {
            normalized = normalized.substring(2);
        } else if (normalized.startsWith("$")) {
            normalized = normalized.substring(1);
            if (normalized.startsWith(".")) {
                normalized = normalized.substring(1);
            }
        }

        List<PathSegment> segments = new ArrayList<>();
        Matcher matcher = SEGMENT_PATTERN.matcher(normalized);
        int expected = 0;
        while (matcher.find()) {
            if (matcher.start() != expected) {
                throw new IllegalArgumentException("Invalid JSON path syntax near: " + jsonPath);
            }
            expected = matcher.end();
            if (matcher.group(1) != null) {
                segments.add(PathSegment.field(matcher.group(1)));
            } else {
                segments.add(PathSegment.index(Integer.parseInt(matcher.group(2))));
            }
            if (expected < normalized.length() && normalized.charAt(expected) == '.') {
                expected++;
            }
        }
        if (expected != normalized.length()) {
            throw new IllegalArgumentException("Invalid JSON path syntax: " + jsonPath);
        }
        return segments;
    }

    private static void ensureContainerRoot(JsonNode rootNode, PathSegment first) {
        if (first.fieldName != null && !rootNode.isObject()) {
            throw new IllegalArgumentException("Cannot update object path on non-object JSON root");
        }
        if (first.fieldName == null && !rootNode.isArray()) {
            throw new IllegalArgumentException("Cannot update array index path on non-array JSON root");
        }
    }

    private static JsonNode descendCreating(JsonNode parent, PathSegment segment, PathSegment next) {
        if (segment.fieldName != null) {
            if (!parent.isObject()) {
                throw new IllegalArgumentException("Cannot descend into field '" + segment.fieldName + "' on non-object");
            }
            ObjectNode objectParent = (ObjectNode) parent;
            JsonNode child = objectParent.get(segment.fieldName);
            if (child == null || child.isNull()) {
                child = next.fieldName != null ? objectMapper.createObjectNode() : objectMapper.createArrayNode();
                objectParent.set(segment.fieldName, child);
            } else if (next.fieldName != null && !child.isObject()) {
                throw new IllegalArgumentException(
                        "Path segment '" + segment.fieldName + "' exists but is not an object");
            } else if (next.fieldName == null && !child.isArray()) {
                throw new IllegalArgumentException(
                        "Path segment '" + segment.fieldName + "' exists but is not an array");
            }
            return child;
        }

        if (!parent.isArray()) {
            throw new IllegalArgumentException("Cannot descend into index [" + segment.index + "] on non-array");
        }
        ArrayNode arrayParent = (ArrayNode) parent;
        ensureArraySize(arrayParent, segment.index);
        JsonNode child = arrayParent.get(segment.index);
        if (child == null || child.isNull()) {
            child = next.fieldName != null ? objectMapper.createObjectNode() : objectMapper.createArrayNode();
            arrayParent.set(segment.index, child);
        } else if (next.fieldName != null && !child.isObject()) {
            throw new IllegalArgumentException("Array index [" + segment.index + "] exists but is not an object");
        } else if (next.fieldName == null && !child.isArray()) {
            throw new IllegalArgumentException("Array index [" + segment.index + "] exists but is not an array");
        }
        return child;
    }

    private static JsonNode descendExisting(JsonNode parent, PathSegment segment) {
        if (segment.fieldName != null) {
            return parent != null && parent.isObject() ? parent.get(segment.fieldName) : null;
        }
        if (parent == null || !parent.isArray() || segment.index < 0 || segment.index >= parent.size()) {
            return null;
        }
        return parent.get(segment.index);
    }

    private static void setAtSegment(JsonNode parent, PathSegment segment, JsonNode valueNode) {
        if (segment.fieldName != null) {
            if (!parent.isObject()) {
                throw new IllegalArgumentException("Cannot set field '" + segment.fieldName + "' on non-object parent");
            }
            ((ObjectNode) parent).set(segment.fieldName, valueNode);
            return;
        }
        if (!parent.isArray()) {
            throw new IllegalArgumentException("Cannot set index [" + segment.index + "] on non-array parent");
        }
        ArrayNode arrayParent = (ArrayNode) parent;
        ensureArraySize(arrayParent, segment.index);
        arrayParent.set(segment.index, valueNode);
    }

    private static void ensureArraySize(ArrayNode arrayNode, int index) {
        while (arrayNode.size() <= index) {
            arrayNode.addNull();
        }
    }

    private static JsonNode toNode(Object value, boolean forceString) {
        if (forceString) {
            return value == null
                    ? objectMapper.getNodeFactory().nullNode()
                    : objectMapper.getNodeFactory().textNode(value.toString());
        }
        return convertToJsonNode(value);
    }

    private static JsonNode convertToJsonNode(Object value) {
        if (value == null) {
            return objectMapper.getNodeFactory().nullNode();
        }

        if (value instanceof JsonNode) {
            return (JsonNode) value;
        }

        if (value instanceof String) {
            String strValue = (String) value;

            if ("true".equalsIgnoreCase(strValue)) {
                return objectMapper.getNodeFactory().booleanNode(true);
            }
            if ("false".equalsIgnoreCase(strValue)) {
                return objectMapper.getNodeFactory().booleanNode(false);
            }

            try {
                if (strValue.contains(".")) {
                    return objectMapper.getNodeFactory().numberNode(Double.parseDouble(strValue));
                }
                return objectMapper.getNodeFactory().numberNode(Long.parseLong(strValue));
            } catch (NumberFormatException e) {
                return objectMapper.getNodeFactory().textNode(strValue);
            }
        }

        if (value instanceof Integer) {
            return objectMapper.getNodeFactory().numberNode((Integer) value);
        }
        if (value instanceof Long) {
            return objectMapper.getNodeFactory().numberNode((Long) value);
        }
        if (value instanceof Double) {
            return objectMapper.getNodeFactory().numberNode((Double) value);
        }
        if (value instanceof Float) {
            return objectMapper.getNodeFactory().numberNode((Float) value);
        }
        if (value instanceof Number) {
            return objectMapper.getNodeFactory().numberNode(((Number) value).doubleValue());
        }

        if (value instanceof Boolean) {
            return objectMapper.getNodeFactory().booleanNode((Boolean) value);
        }

        if (value instanceof Map || value instanceof Collection || value.getClass().isArray()) {
            return objectMapper.valueToTree(value);
        }

        return objectMapper.getNodeFactory().textNode(value.toString());
    }

    static final class PathSegment {
        final String fieldName;
        final int index;

        private PathSegment(String fieldName, int index) {
            this.fieldName = fieldName;
            this.index = index;
        }

        static PathSegment field(String name) {
            return new PathSegment(name, -1);
        }

        static PathSegment index(int index) {
            return new PathSegment(null, index);
        }
    }
}
