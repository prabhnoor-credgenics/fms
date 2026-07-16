package utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;


public class JsonUtils {
    private static final Logger logger = LogManager.getLogger(JsonUtils.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();


    private static final String TEST_RESOURCES_PATH = "src/test/resources/";

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

    public static String removeJsonField(String jsonString, String jsonPath) {
        try {
            JsonNode rootNode = objectMapper.readTree(jsonString);
            String[] pathParts = jsonPath.split("\\.");
            JsonNode parent = rootNode;
            String fieldToRemove = pathParts[pathParts.length - 1];

            for (int i = 0; i < pathParts.length - 1; i++) {
                parent = parent.get(pathParts[i]);
                if (parent == null) {
                    logger.warn("Path '{}' not found in JSON; field not removed", jsonPath);
                    return jsonString;
                }
            }

            if (parent.isObject()) {
                ((ObjectNode) parent).remove(fieldToRemove);
            } else {
                logger.warn("Cannot remove field '{}' — parent is not an object", jsonPath);
                return jsonString;
            }

            return objectMapper.writeValueAsString(rootNode);
        } catch (Exception e) {
            logger.error("Error removing JSON field '{}': {}", jsonPath, e.getMessage(), e);
            throw new RuntimeException("Failed to remove JSON field: " + jsonPath, e);
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