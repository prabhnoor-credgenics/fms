package helpers;

import utils.JsonUtils;

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

    public static String updateFieldTyped(String json, String jsonPath, String type, String value) {
        return JsonUtils.updateJsonFieldTyped(json, jsonPath, type, value);
    }

    public static String removeField(String json, String jsonPath) {
        return JsonUtils.removeJsonField(json, jsonPath);
    }
}
