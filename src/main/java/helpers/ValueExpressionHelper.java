package helpers;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class ValueExpressionHelper {

    private static final Pattern BARE_RANDOM_STRING =
            Pattern.compile("(?<!\\{)RANDOM_STRING:(\\d+)(?!\\})");

    private ValueExpressionHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static String resolve(String raw, Function<String, String> placeholderResolver) {
        if (raw == null) {
            return null;
        }
        if (!looksLikeConcatExpression(raw)) {
            return placeholderResolver.apply(raw);
        }
        String expression = unwrapOuterBraces(raw);
        expression = normalizeBareRandomStringTokens(expression);
        List<String> parts = splitConcatParts(expression);
        StringBuilder out = new StringBuilder();
        for (String part : parts) {
            out.append(resolvePart(part, placeholderResolver));
        }
        return out.toString();
    }

    public static boolean looksLikeConcatExpression(String raw) {
        String expression = unwrapOuterBraces(raw).trim();
        if (!expression.contains("+")) {
            return false;
        }
        return expression.contains("\"")
                || expression.contains("'")
                || expression.contains("{")
                || BARE_RANDOM_STRING.matcher(expression).find();
    }

    static String unwrapOuterBraces(String raw) {
        String trimmed = raw.trim();
        if (trimmed.length() >= 2 && trimmed.startsWith("{") && trimmed.endsWith("}")
                && looksLikeConcatInside(trimmed.substring(1, trimmed.length() - 1))) {
            return trimmed.substring(1, trimmed.length() - 1);
        }
        return raw;
    }

    private static boolean looksLikeConcatInside(String inner) {
        return inner.contains("+")
                && (inner.contains("\"") || inner.contains("'") || inner.contains("{")
                || BARE_RANDOM_STRING.matcher(inner).find());
    }

    static String normalizeBareRandomStringTokens(String expression) {
        Matcher matcher = BARE_RANDOM_STRING.matcher(expression);
        StringBuffer sb = new StringBuffer();
        while (matcher.find()) {
            matcher.appendReplacement(sb, Matcher.quoteReplacement("{RANDOM_STRING:" + matcher.group(1) + "}"));
        }
        matcher.appendTail(sb);
        return sb.toString();
    }

    static List<String> splitConcatParts(String expression) {
        List<String> parts = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean inDouble = false;
        boolean inSingle = false;
        for (int i = 0; i < expression.length(); i++) {
            char c = expression.charAt(i);
            if (c == '"' && !inSingle) {
                inDouble = !inDouble;
                current.append(c);
                continue;
            }
            if (c == '\'' && !inDouble) {
                inSingle = !inSingle;
                current.append(c);
                continue;
            }
            if (c == '+' && !inDouble && !inSingle) {
                parts.add(current.toString());
                current.setLength(0);
                continue;
            }
            current.append(c);
        }
        parts.add(current.toString());
        return parts;
    }

    static String resolvePart(String rawPart, Function<String, String> placeholderResolver) {
        String part = rawPart;
        if (part.isEmpty()) {
            return "";
        }
        String trimmedEdges = trimOnlyOutsideQuotes(part);
        if (isQuoted(trimmedEdges, '"')) {
            return trimmedEdges.substring(1, trimmedEdges.length() - 1);
        }
        if (isQuoted(trimmedEdges, '\'')) {
            return trimmedEdges.substring(1, trimmedEdges.length() - 1);
        }
        return placeholderResolver.apply(trimmedEdges.trim());
    }

    private static String trimOnlyOutsideQuotes(String part) {
        int start = 0;
        int end = part.length();
        while (start < end && Character.isWhitespace(part.charAt(start))) {
            start++;
        }
        while (end > start && Character.isWhitespace(part.charAt(end - 1))) {
            end--;
        }
        return part.substring(start, end);
    }

    private static boolean isQuoted(String value, char quote) {
        return value.length() >= 2 && value.charAt(0) == quote && value.charAt(value.length() - 1) == quote;
    }
}
