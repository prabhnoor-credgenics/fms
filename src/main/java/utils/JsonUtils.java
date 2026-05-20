package utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.InputStream;


public class JsonUtils {
    private static final Logger logger = LogManager.getLogger(JsonUtils.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();


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


    public static String updateJsonField(String jsonString, String jsonPath, Object newValue) {
        try {
            JsonNode rootNode = objectMapper.readTree(jsonString);
            String[] pathParts = jsonPath.split("\\.");
            
            JsonNode currentNode = rootNode;
            for (int i = 0; i < pathParts.length - 1; i++) {
                String part = pathParts[i];
                
                
                if (part.contains("[") && part.contains("]")) {
                    String arrayName = part.substring(0, part.indexOf('['));
                    int index = Integer.parseInt(part.substring(part.indexOf('[') + 1, part.indexOf(']')));
                    currentNode = currentNode.get(arrayName).get(index);
                } else {
                    currentNode = currentNode.get(part);
                }
                
                if (currentNode == null) {
                    logger.warn("Path '{}' not found in JSON, creating path", jsonPath);
                    return jsonString; 
                }
            }
            
            
            String lastPart = pathParts[pathParts.length - 1];
            
            
            if (lastPart.contains("[") && lastPart.contains("]")) {
                String arrayName = lastPart.substring(0, lastPart.indexOf('['));
                int index = Integer.parseInt(lastPart.substring(lastPart.indexOf('[') + 1, lastPart.indexOf(']')));
                JsonNode arrayNode = currentNode.get(arrayName);
                if (arrayNode != null && arrayNode.isArray()) {
                    JsonNode valueNode = convertToJsonNode(newValue);
                    ((com.fasterxml.jackson.databind.node.ArrayNode) arrayNode).set(index, valueNode);
                }
            } else {
                
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
    

    private static JsonNode convertToJsonNode(Object value) {
        if (value == null) {
            return objectMapper.getNodeFactory().nullNode();
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
                } else {
                    return objectMapper.getNodeFactory().numberNode(Long.parseLong(strValue));
                }
            } catch (NumberFormatException e) {
                
                return objectMapper.getNodeFactory().textNode(strValue);
            }
        }
        
        if (value instanceof Number) {
            return objectMapper.getNodeFactory().numberNode(((Number) value).doubleValue());
        }
        
        if (value instanceof Boolean) {
            return objectMapper.getNodeFactory().booleanNode((Boolean) value);
        }
        
        
        return objectMapper.getNodeFactory().textNode(value.toString());
    }
}