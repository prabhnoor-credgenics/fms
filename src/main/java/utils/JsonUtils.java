package utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.InputStream;

/**
 * Utility class for JSON operations
 */
public class JsonUtils {
    private static final Logger logger = LogManager.getLogger(JsonUtils.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Read JSON file from resources directory and return as String
     * 
     * @param filePath Path to JSON file in resources (e.g., "test-data/user.json")
     * @return JSON content as String
     */
    public static String readJsonFromFile(String filePath) {
        try (InputStream inputStream = JsonUtils.class.getClassLoader().getResourceAsStream(filePath)) {
            if (inputStream == null) {
                logger.error("JSON file '{}' not found in resources", filePath);
                throw new RuntimeException("JSON file not found: " + filePath);
            }
            byte[] bytes = inputStream.readAllBytes();
            String jsonContent = new String(bytes);
            logger.info("Successfully loaded JSON from file: {}", filePath);
            return jsonContent;
        } catch (Exception e) {
            logger.error("Error reading JSON file '{}': {}", filePath, e.getMessage(), e);
            throw new RuntimeException("Failed to read JSON file: " + filePath, e);
        }
    }

    /**
     * Convert Java object to JSON string
     * 
     * @param object Object to convert
     * @return JSON string representation
     */
    public static String toJsonString(Object object) {
        try {
            String json = objectMapper.writeValueAsString(object);
            logger.debug("Converted object to JSON: {}", json);
            return json;
        } catch (Exception e) {
            logger.error("Error converting object to JSON: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to convert object to JSON", e);
        }
    }

    /**
     * Convert JSON string to Java object
     * 
     * @param jsonString JSON string to parse
     * @param clazz Target class type
     * @param <T> Generic type
     * @return Parsed object of type T
     */
    public static <T> T fromJsonString(String jsonString, Class<T> clazz) {
        try {
            T object = objectMapper.readValue(jsonString, clazz);
            logger.debug("Parsed JSON to object of type: {}", clazz.getSimpleName());
            return object;
        } catch (Exception e) {
            logger.error("Error parsing JSON string to {}: {}", clazz.getSimpleName(), e.getMessage(), e);
            throw new RuntimeException("Failed to parse JSON to " + clazz.getSimpleName(), e);
        }
    }

    /**
     * Pretty print JSON string with indentation
     * 
     * @param jsonString JSON string to format
     * @return Formatted JSON string
     */
    public static String prettyPrint(String jsonString) {
        try {
            Object jsonObject = objectMapper.readValue(jsonString, Object.class);
            String prettyJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(jsonObject);
            logger.debug("Pretty printed JSON");
            return prettyJson;
        } catch (Exception e) {
            logger.error("Error pretty printing JSON: {}", e.getMessage(), e);
            return jsonString; // Return original if formatting fails
        }
    }

    /**
     * Validate JSON string format
     * 
     * @param jsonString JSON string to validate
     * @return true if valid JSON, false otherwise
     */
    public static boolean isValidJson(String jsonString) {
        try {
            objectMapper.readTree(jsonString);
            logger.debug("JSON string is valid");
            return true;
        } catch (Exception e) {
            logger.warn("Invalid JSON string: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Update a JSON field using JSONPath-like notation (e.g., "field", "nested.field", "array[0].field")
     * 
     * @param jsonString Original JSON string
     * @param jsonPath JSONPath to the field (supports dot notation and array indices)
     * @param newValue New value (can be null, String, Number, Boolean, or String representation)
     * @return Updated JSON string
     */
    public static String updateJsonField(String jsonString, String jsonPath, Object newValue) {
        try {
            JsonNode rootNode = objectMapper.readTree(jsonString);
            String[] pathParts = jsonPath.split("\\.");
            
            JsonNode currentNode = rootNode;
            for (int i = 0; i < pathParts.length - 1; i++) {
                String part = pathParts[i];
                
                // Handle array notation (e.g., "array[0]")
                if (part.contains("[") && part.contains("]")) {
                    String arrayName = part.substring(0, part.indexOf('['));
                    int index = Integer.parseInt(part.substring(part.indexOf('[') + 1, part.indexOf(']')));
                    currentNode = currentNode.get(arrayName).get(index);
                } else {
                    currentNode = currentNode.get(part);
                }
                
                if (currentNode == null) {
                    logger.warn("Path '{}' not found in JSON, creating path", jsonPath);
                    return jsonString; // Return original if path doesn't exist
                }
            }
            
            // Get the last part of the path
            String lastPart = pathParts[pathParts.length - 1];
            
            // Handle array notation in last part
            if (lastPart.contains("[") && lastPart.contains("]")) {
                String arrayName = lastPart.substring(0, lastPart.indexOf('['));
                int index = Integer.parseInt(lastPart.substring(lastPart.indexOf('[') + 1, lastPart.indexOf(']')));
                JsonNode arrayNode = currentNode.get(arrayName);
                if (arrayNode != null && arrayNode.isArray()) {
                    JsonNode valueNode = convertToJsonNode(newValue);
                    ((com.fasterxml.jackson.databind.node.ArrayNode) arrayNode).set(index, valueNode);
                }
            } else {
                // Update the field value
                JsonNode valueNode = convertToJsonNode(newValue);
                if (currentNode.isObject()) {
                    ((ObjectNode) currentNode).set(lastPart, valueNode);
                } else {
                    logger.warn("Cannot update field '{}' - parent is not an object", jsonPath);
                    return jsonString;
                }
            }
            
            return objectMapper.writeValueAsString(rootNode);
        } catch (Exception e) {
            logger.error("Error updating JSON field '{}': {}", jsonPath, e.getMessage(), e);
            throw new RuntimeException("Failed to update JSON field: " + jsonPath, e);
        }
    }
    
    /**
     * Convert a value to JsonNode
     */
    private static JsonNode convertToJsonNode(Object value) {
        if (value == null) {
            return objectMapper.getNodeFactory().nullNode();
        }
        
        if (value instanceof String) {
            String strValue = (String) value;
            // Try to parse as boolean
            if ("true".equalsIgnoreCase(strValue)) {
                return objectMapper.getNodeFactory().booleanNode(true);
            }
            if ("false".equalsIgnoreCase(strValue)) {
                return objectMapper.getNodeFactory().booleanNode(false);
            }
            // Try to parse as number
            try {
                if (strValue.contains(".")) {
                    return objectMapper.getNodeFactory().numberNode(Double.parseDouble(strValue));
                } else {
                    return objectMapper.getNodeFactory().numberNode(Long.parseLong(strValue));
                }
            } catch (NumberFormatException e) {
                // It's a string
                return objectMapper.getNodeFactory().textNode(strValue);
            }
        }
        
        if (value instanceof Number) {
            return objectMapper.getNodeFactory().numberNode(((Number) value).doubleValue());
        }
        
        if (value instanceof Boolean) {
            return objectMapper.getNodeFactory().booleanNode((Boolean) value);
        }
        
        // For other types, convert to string first
        return objectMapper.getNodeFactory().textNode(value.toString());
    }
}