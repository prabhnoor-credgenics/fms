package helpers;

import io.restassured.response.Response;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;


public final class JsonDeepFieldHelper {

    public record Occurrence(String path, Object value) {
    }

    private JsonDeepFieldHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static List<Occurrence> collect(Response response, String rootPath, String key) {
        requireKey(key);
        Object root = resolveRoot(response, rootPath);
        List<Occurrence> found = new ArrayList<>();
        walk(root, displayRoot(rootPath), key.trim(), found);
        return found;
    }

    public static void assertKeyPresent(Response response, String rootPath, String key) {
        List<Occurrence> found = collect(response, rootPath, key);
        if (found.isEmpty()) {
            throw new AssertionError(
                    "Expected at least one occurrence of key '" + key + "' under '"
                            + displayRoot(rootPath) + "' but found none."
            );
        }
    }

    public static void assertDatatype(
            Response response,
            String rootPath,
            String key,
            String typeSpec,
            boolean allowNull
    ) {
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        String expected = normalizeType(typeSpec);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() == null) {
                if (!allowNull) {
                    failures.add(occ.path() + " is null");
                }
                continue;
            }
            if (!matchesType(occ.value(), expected)) {
                failures.add(occ.path() + " expected type '" + expected
                        + "' but was " + describe(occ.value()));
            }
        }
        failIfAny(failures, "Datatype check failed for key '" + key + "'");
    }

    public static void assertAllNull(Response response, String rootPath, String key) {
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() != null) {
                failures.add(occ.path() + " expected null but was " + describe(occ.value()));
            }
        }
        failIfAny(failures, "Null check failed for key '" + key + "'");
    }

    public static void assertAllNotNull(Response response, String rootPath, String key) {
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() == null) {
                failures.add(occ.path() + " is null");
            }
        }
        failIfAny(failures, "Not-null check failed for key '" + key + "'");
    }

    public static void assertStringLengthEquals(
            Response response,
            String rootPath,
            String key,
            int expectedLength,
            boolean allowNull
    ) {
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() == null) {
                if (!allowNull) {
                    failures.add(occ.path() + " is null");
                }
                continue;
            }
            if (!(occ.value() instanceof String)
                    && !(occ.value() instanceof Number)
                    && !(occ.value() instanceof Boolean)) {
                failures.add(occ.path() + " is not a scalar string/number/boolean ("
                        + describe(occ.value()) + ")");
                continue;
            }
            String text = String.valueOf(occ.value());
            if (text.length() != expectedLength) {
                failures.add(occ.path() + " length expected " + expectedLength
                        + " but was " + text.length() + " (value='" + text + "')");
            }
        }
        failIfAny(failures, "Length check failed for key '" + key + "'");
    }

    public static void assertStringLengthBetween(
            Response response,
            String rootPath,
            String key,
            int minInclusive,
            int maxInclusive,
            boolean allowNull
    ) {
        if (minInclusive > maxInclusive) {
            throw new IllegalArgumentException("Invalid length range: min > max");
        }
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() == null) {
                if (!allowNull) {
                    failures.add(occ.path() + " is null");
                }
                continue;
            }
            String text = String.valueOf(occ.value());
            int len = text.length();
            if (len < minInclusive || len > maxInclusive) {
                failures.add(occ.path() + " length expected between " + minInclusive
                        + " and " + maxInclusive + " but was " + len
                        + " (value='" + text + "')");
            }
        }
        failIfAny(failures, "Length-range check failed for key '" + key + "'");
    }

    public static void assertMatchesRegex(
            Response response,
            String rootPath,
            String key,
            String regex,
            boolean allowNull
    ) {
        if (regex == null || regex.isBlank()) {
            throw new IllegalArgumentException("Regex must not be blank");
        }
        Pattern pattern = Pattern.compile(regex);
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() == null) {
                if (!allowNull) {
                    failures.add(occ.path() + " is null");
                }
                continue;
            }
            String text = String.valueOf(occ.value());
            if (!pattern.matcher(text).matches()) {
                failures.add(occ.path() + " value '" + text + "' does not match regex '" + regex + "'");
            }
        }
        failIfAny(failures, "Regex check failed for key '" + key + "'");
    }

    public static void assertNumericSign(
            Response response,
            String rootPath,
            String key,
            String signRule,
            boolean allowNull,
            boolean requireInteger
    ) {
        String rule = signRule == null ? "" : signRule.trim().toLowerCase(Locale.ROOT);
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() == null) {
                if (!allowNull) {
                    failures.add(occ.path() + " is null");
                }
                continue;
            }
            BigDecimal number = toNumber(occ.value());
            if (number == null) {
                failures.add(occ.path() + " is not numeric (" + describe(occ.value()) + ")");
                continue;
            }
            if (requireInteger && number.stripTrailingZeros().scale() > 0) {
                failures.add(occ.path() + " expected integer but was " + number);
                continue;
            }
            int cmp = number.compareTo(BigDecimal.ZERO);
            boolean ok = switch (rule) {
                case "positive", ">" -> cmp > 0;
                case "non-negative", "nonnegative", ">=" -> cmp >= 0;
                case "negative", "<" -> cmp < 0;
                case "non-positive", "nonpositive", "<=" -> cmp <= 0;
                case "zero", "==0", "0" -> cmp == 0;
                case "non-zero", "nonzero", "!=0" -> cmp != 0;
                default -> throw new IllegalArgumentException(
                        "Unsupported numeric rule '" + signRule
                                + "'. Use positive, non-negative, negative, non-positive, zero, non-zero."
                );
            };
            if (!ok) {
                failures.add(occ.path() + " expected " + rule + " number but was " + number);
            }
        }
        failIfAny(failures, "Numeric " + rule + " check failed for key '" + key + "'");
    }

    public static void assertArraySizeEquals(
            Response response,
            String rootPath,
            String key,
            int expectedSize,
            boolean allowNull
    ) {
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() == null) {
                if (!allowNull) {
                    failures.add(occ.path() + " is null");
                }
                continue;
            }
            if (!(occ.value() instanceof List<?> list)) {
                failures.add(occ.path() + " expected array but was " + describe(occ.value()));
                continue;
            }
            if (list.size() != expectedSize) {
                failures.add(occ.path() + " array size expected " + expectedSize
                        + " but was " + list.size());
            }
        }
        failIfAny(failures, "Array size check failed for key '" + key + "'");
    }

    public static void assertArraySizeAtLeast(
            Response response,
            String rootPath,
            String key,
            int minInclusive,
            boolean allowNull
    ) {
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        List<String> failures = new ArrayList<>();
        for (Occurrence occ : found) {
            if (occ.value() == null) {
                if (!allowNull) {
                    failures.add(occ.path() + " is null");
                }
                continue;
            }
            if (!(occ.value() instanceof List<?> list)) {
                failures.add(occ.path() + " expected array but was " + describe(occ.value()));
                continue;
            }
            if (list.size() < minInclusive) {
                failures.add(occ.path() + " array size expected >= " + minInclusive
                        + " but was " + list.size());
            }
        }
        failIfAny(failures, "Array min-size check failed for key '" + key + "'");
    }


    public static void assertUniqueValues(Response response, String rootPath, String key) {
        List<Occurrence> found = requireOccurrences(response, rootPath, key);
        Map<String, List<String>> pathsByValue = new LinkedHashMap<>();
        for (Occurrence occ : found) {
            String canonical = canonicalValue(occ.value());
            pathsByValue.computeIfAbsent(canonical, ignored -> new ArrayList<>()).add(occ.path());
        }
        List<String> failures = new ArrayList<>();
        for (Map.Entry<String, List<String>> entry : pathsByValue.entrySet()) {
            List<String> paths = entry.getValue();
            if (paths.size() > 1) {
                failures.add(
                        "value " + entry.getKey() + " appears " + paths.size()
                                + " times at: " + String.join(", ", paths)
                );
            }
        }
        failIfAny(failures, "Uniqueness check failed for key '" + key + "'");
    }

    public static int count(Response response, String rootPath, String key) {
        return collect(response, rootPath, key).size();
    }

    private static List<Occurrence> requireOccurrences(Response response, String rootPath, String key) {
        List<Occurrence> found = collect(response, rootPath, key);
        if (found.isEmpty()) {
            throw new AssertionError(
                    "No occurrences of key '" + key + "' found under '"
                            + displayRoot(rootPath) + "'."
            );
        }
        return found;
    }

    private static Object resolveRoot(Response response, String rootPath) {
        if (response == null) {
            throw new IllegalStateException("No API response available. Send a request first.");
        }
        if (rootPath == null || rootPath.isBlank() || "$".equals(rootPath.trim())) {
            return response.jsonPath().get("$");
        }
        Object raw = response.jsonPath().get(rootPath.trim());
        if (raw == null) {
            throw new AssertionError(
                    "Root path '" + rootPath + "' is missing/null in response."
            );
        }
        return raw;
    }

    @SuppressWarnings("unchecked")
    private static void walk(Object node, String path, String key, List<Occurrence> found) {
        if (node == null) {
            return;
        }
        if (node instanceof Map<?, ?> map) {
            Map<String, Object> typed = (Map<String, Object>) map;
            if (typed.containsKey(key)) {
                found.add(new Occurrence(path + "." + key, typed.get(key)));
            }
            for (Map.Entry<String, Object> entry : typed.entrySet()) {
                walk(entry.getValue(), path + "." + entry.getKey(), key, found);
            }
            return;
        }
        if (node instanceof List<?> list) {
            for (int i = 0; i < list.size(); i++) {
                walk(list.get(i), path + "[" + i + "]", key, found);
            }
        }
    }

    private static boolean matchesType(Object value, String expected) {
        return switch (expected) {
            case "string", "str", "text" -> value instanceof String;
            case "boolean", "bool" -> value instanceof Boolean;
            case "integer", "int", "long" -> isInteger(value);
            case "number", "numeric" -> toNumber(value) != null;
            case "float", "double", "decimal" -> toNumber(value) != null;
            case "array", "list" -> value instanceof List<?>;
            case "object", "map", "json" -> value instanceof Map<?, ?>;
            case "null" -> value == null;
            default -> throw new IllegalArgumentException(
                    "Unsupported datatype '" + expected
                            + "'. Use string, boolean, integer, number, float, array, object."
            );
        };
    }

    private static boolean isInteger(Object value) {
        if (value instanceof Integer || value instanceof Long || value instanceof Short
                || value instanceof Byte) {
            return true;
        }
        if (value instanceof BigDecimal bd) {
            return bd.stripTrailingZeros().scale() <= 0;
        }
        if (value instanceof Double || value instanceof Float) {
            BigDecimal bd = toNumber(value);
            return bd != null && bd.stripTrailingZeros().scale() <= 0;
        }
        if (value instanceof String s) {
            try {
                new BigDecimal(s.trim()).toBigIntegerExact();
                return true;
            } catch (Exception ignored) {
                return false;
            }
        }
        return false;
    }

    private static BigDecimal toNumber(Object value) {
        if (value instanceof Number n) {
            return new BigDecimal(n.toString());
        }
        if (value instanceof String s) {
            try {
                return new BigDecimal(s.trim());
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private static String normalizeType(String typeSpec) {
        if (typeSpec == null || typeSpec.isBlank()) {
            throw new IllegalArgumentException("Datatype must not be blank");
        }
        return typeSpec.trim().toLowerCase(Locale.ROOT);
    }

    private static void requireKey(String key) {
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException("Key must not be blank");
        }
    }

    private static String displayRoot(String rootPath) {
        if (rootPath == null || rootPath.isBlank() || "$".equals(rootPath.trim())) {
            return "$";
        }
        return rootPath.trim();
    }

    private static String describe(Object value) {
        if (value == null) {
            return "null";
        }
        return value.getClass().getSimpleName() + "(" + value + ")";
    }

    private static String canonicalValue(Object value) {
        if (value == null) {
            return "null";
        }
        if (value instanceof Number) {
            return new BigDecimal(value.toString()).stripTrailingZeros().toPlainString();
        }
        if (value instanceof Boolean || value instanceof CharSequence) {
            return String.valueOf(value);
        }
        return value.getClass().getSimpleName() + ":" + value;
    }

    private static void failIfAny(List<String> failures, String header) {
        if (failures.isEmpty()) {
            return;
        }
        int shown = Math.min(failures.size(), 20);
        StringBuilder sb = new StringBuilder(header)
                .append(". Failures: ")
                .append(failures.size())
                .append(". First ")
                .append(shown)
                .append(":\n");
        for (int i = 0; i < shown; i++) {
            sb.append(" - ").append(failures.get(i)).append('\n');
        }
        throw new AssertionError(sb.toString().trim());
    }
}
