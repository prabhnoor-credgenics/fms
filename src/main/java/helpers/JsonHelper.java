package helpers;

import utils.JsonUtils;


public final class JsonHelper {

    private JsonHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static String readClasspath(String classpathLocation) {
        return JsonUtils.readJsonFromFile(classpathLocation);
    }

    public static String updateField(String json, String jsonPath, Object value) {
        return JsonUtils.updateJsonField(json, jsonPath, value);
    }

    public static String removeField(String json, String jsonPath) {
        return JsonUtils.removeJsonField(json, jsonPath);
    }

    public static String prettyPrint(String json) {
        return JsonUtils.prettyPrint(json);
    }
}
