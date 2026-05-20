package helpers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;


public final class PayloadHelper {

    private static final Logger LOGGER = LogManager.getLogger(PayloadHelper.class);

    
    private static final String[] BOOLEAN_AS_STRING_FIELDS = {
            "tenure_finished",
            "backed_by_security",
            "backed_by_surety"
    };

    private PayloadHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    
    public static String convertBooleansToStrings(String jsonBody) {
        if (jsonBody == null || jsonBody.isBlank()) {
            return jsonBody;
        }
        String result = jsonBody;
        for (String field : BOOLEAN_AS_STRING_FIELDS) {
            String truePattern = "\"" + field + "\"\\s*:\\s*true\\b";
            String falsePattern = "\"" + field + "\"\\s*:\\s*false\\b";
            result = result.replaceAll(truePattern, "\"" + field + "\": \"TRUE\"");
            result = result.replaceAll(falsePattern, "\"" + field + "\": \"FALSE\"");
        }
        LOGGER.debug("PayloadHelper.convertBooleansToStrings applied");
        return result;
    }

    
    public static String stripSurroundingQuotes(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        if (trimmed.length() >= 2 && trimmed.startsWith("\"") && trimmed.endsWith("\"")) {
            return trimmed.substring(1, trimmed.length() - 1);
        }
        return value;
    }

    
    public static boolean isNullToken(String value) {
        return value != null && "null".equalsIgnoreCase(value.trim());
    }
}
