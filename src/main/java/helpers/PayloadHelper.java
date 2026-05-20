package helpers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Payload string transformations used by step definitions.
 *
 * <p>Centralises quirky JSON conversions so they are reusable across endpoints and easy to extend.
 */
public final class PayloadHelper {

    private static final Logger LOGGER = LogManager.getLogger(PayloadHelper.class);

    /** Fields whose API contract expects the string literals {@code "TRUE"}/{@code "FALSE"}. */
    private static final String[] BOOLEAN_AS_STRING_FIELDS = {
            "tenure_finished",
            "backed_by_security",
            "backed_by_surety"
    };

    private PayloadHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    /**
     * Converts JSON boolean values to "TRUE"/"FALSE" strings for fields where the API contract
     * mandates string booleans. Idempotent and safe to call on bodies that don't contain the fields.
     *
     * @param jsonBody source JSON string (may be null)
     * @return transformed JSON string, or the input unchanged if null/blank
     */
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

    /**
     * Strips a single pair of surrounding double quotes from a trimmed value, if present.
     * Used when accepting Gherkin values like {@code "yes"} that should be stored unquoted.
     */
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

    /**
     * Returns true if the value (case-insensitive, trimmed) equals {@code "null"}.
     */
    public static boolean isNullToken(String value) {
        return value != null && "null".equalsIgnoreCase(value.trim());
    }
}
