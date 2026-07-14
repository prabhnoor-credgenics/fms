package utils;

import context.ContextKeys;
import context.TestContext;
import helpers.RandomDataHelper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.UUID;
import java.util.regex.Matcher;


public class TestDataHelper {
    private static final Logger logger = LogManager.getLogger(TestDataHelper.class);
    private static final Random RANDOM = new Random();
    private static final String ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    private static final String NUMBERS = "0123456789";
    private static final String ALPHANUMERIC = ALPHABET + NUMBERS;


    public static final List<String> TIME_FORMATS = List.of(
            "epoch_seconds",
            "epoch_millis",
            "iso_date",
            "iso_datetime",
            "iso_instant",
            "date_time",
            "year_month",
            "month_first_day"
    );

    private final TestContext testContext;

    public TestDataHelper(TestContext testContext) {
        this.testContext = testContext;
    }

    public String generateUUID() {
        String uuid = UUID.randomUUID().toString();
        logger.debug("Generated UUID: {}", uuid);
        return uuid;
    }

    public int generateRandomInt(int min, int max) {
        if (min > max) {
            throw new IllegalArgumentException("Min value cannot be greater than max value");
        }
        return RANDOM.nextInt(max - min + 1) + min;
    }

    public String generateRandomString(int length) {
        return generateRandomString(length, ALPHANUMERIC);
    }

    public String generateRandomString(int length, String charset) {
        if (length <= 0) {
            throw new IllegalArgumentException("Length must be greater than 0");
        }
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(charset.charAt(RANDOM.nextInt(charset.length())));
        }
        return sb.toString();
    }

    public String generateRandomEmail() {
        return "test_" + generateRandomString(8, ALPHANUMERIC).toLowerCase() + "@example.com";
    }

    public String getCurrentTimestamp() {
        return LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }

    /**
     * Renders a single instant (given as milliseconds since the Unix epoch) into a String
     * using one of the supported {@code format} keys.
     *
     * <p>Every format returns a {@link String}; the table documents the <b>shape / type</b>
     * of that string so a caller knows exactly what a given input produces. Date/time keys
     * (all except {@code iso_instant}) are rendered in the JVM's default time zone;
     * {@code iso_instant} is rendered in UTC.</p>
     *
     * <pre>
     * Input (format)     | Example return value    | Meaning &amp; underlying type of the string
     * -------------------|-------------------------|-----------------------------------------------------
     * "epoch_seconds"    | "1767225600"            | Unix time in SECONDS      — 10-digit numeric string
     * "epoch_millis"     | "1767225600000"         | Unix time in MILLISECONDS — 13-digit numeric string
     * "iso_date"         | "2026-07-12"            | Local calendar date, yyyy-MM-dd
     * "iso_datetime"     | "2026-07-12T14:30:00"   | Local date-time, ISO_LOCAL_DATE_TIME (no zone)
     * "iso_instant"      | "2026-07-12T09:00:00Z"  | UTC instant, ISO-8601 with trailing 'Z'
     * "date_time"        | "2026-07-12 14:30:00"   | Local date-time, space separator
     * "year_month"       | "2026-07"               | Local year-month, yyyy-MM
     * "month_first_day"  | "2026-07-01"            | First day of the instant's local month, yyyy-MM-dd
     * </pre>
     *
     * @param epochMillis the instant to format, in milliseconds since 1970-01-01T00:00:00Z
     * @param format      one of the keys above (case-insensitive, surrounding spaces ignored)
     * @return the instant rendered as a String in the requested format (never {@code null})
     * @throws IllegalArgumentException if {@code format} is not one of {@link #TIME_FORMATS}
     */
    public String formatEpochMillis(long epochMillis, String format) {
        Instant instant = Instant.ofEpochMilli(epochMillis);
        ZoneId zone = ZoneId.systemDefault();
        String key = format == null ? "" : format.trim().toLowerCase();
        switch (key) {
            case "epoch_seconds":
                return String.valueOf(epochMillis / 1000L);
            case "epoch_millis":
                return String.valueOf(epochMillis);
            case "iso_date":
                return instant.atZone(zone).toLocalDate()
                        .format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            case "iso_datetime":
                return instant.atZone(zone).toLocalDateTime()
                        .format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            case "iso_instant":
                return instant.atZone(ZoneOffset.UTC)
                        .format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'"));
            case "date_time":
                return instant.atZone(zone)
                        .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            case "year_month":
                return instant.atZone(zone)
                        .format(DateTimeFormatter.ofPattern("yyyy-MM"));
            case "month_first_day":
                return instant.atZone(zone).toLocalDate().withDayOfMonth(1)
                        .format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            default:
                throw new IllegalArgumentException(
                        "Unsupported time format '" + format + "'. Supported keys: " + TIME_FORMATS);
        }
    }

    /**
     * Convenience wrapper for {@link #formatEpochMillis(long, String)} that uses the current
     * wall-clock time ({@code System.currentTimeMillis()}). See that method for the full
     * input/return-type table.
     *
     * @param format one of {@link #TIME_FORMATS}
     * @return the current time rendered in the requested format
     */
    public String currentTime(String format) {
        return formatEpochMillis(System.currentTimeMillis(), format);
    }

    /**
     * Renders the same instant in every supported format at once.
     *
     * @param epochMillis the instant to format, in milliseconds since the Unix epoch
     * @return an ordered map of {@code format key -> rendered value}, in {@link #TIME_FORMATS} order
     */
    public Map<String, String> allTimeFormats(long epochMillis) {
        Map<String, String> out = new LinkedHashMap<>();
        for (String format : TIME_FORMATS) {
            out.put(format, formatEpochMillis(epochMillis, format));
        }
        return out;
    }

    /**
     * Replaces inline {@code {NOW:<format>}} placeholders with the current time in that format.
     * Example: {@code {NOW:epoch_seconds}} -> {@code "1767225600"}. Each occurrence is evaluated
     * independently against {@code System.currentTimeMillis()}, so two placeholders in the same
     * template may differ by a few milliseconds. Use {@code {CAPTURED_TIME:...}} when you need a
     * stable value captured at an earlier point in the scenario.
     *
     * @param template text possibly containing {@code {NOW:<format>}} tokens (may be {@code null})
     * @return the template with every {@code {NOW:...}} token resolved
     */
    public String replaceNowPlaceholders(String template) {
        if (template == null) {
            return null;
        }
        String result = template;
        String prefix = "{NOW:";
        while (result.contains(prefix)) {
            int start = result.indexOf(prefix);
            int end = result.indexOf("}", start);
            if (end <= start) {
                break;
            }
            String placeholder = result.substring(start, end + 1);
            String format = placeholder.substring(prefix.length(), placeholder.length() - 1).trim();
            result = result.replace(placeholder, currentTime(format));
        }
        return result;
    }

    /**
     * Replaces {@code {CAPTURED_TIME:<key>:<format>}} placeholders with a previously captured
     * instant, rendered in the requested format. The instant is stored via the Cucumber step
     * {@code I capture the current time as "<key>"} (see ScenarioDataStepDefinitions), which
     * records {@code System.currentTimeMillis()} under {@code key} on the TestContext.
     * Example: {@code {CAPTURED_TIME:uploadTime:epoch_seconds}} -> {@code "1767225600"}.
     *
     * @param template text possibly containing {@code {CAPTURED_TIME:<key>:<format>}} tokens
     * @return the template with every captured-time token resolved
     * @throws IllegalArgumentException if a placeholder is missing the {@code <key>:<format>} pair
     * @throws IllegalStateException    if no time was captured under the referenced key
     */
    public String replaceCapturedTimePlaceholders(String template) {
        if (template == null) {
            return null;
        }
        String result = template;
        String prefix = "{CAPTURED_TIME:";
        while (result.contains(prefix)) {
            int start = result.indexOf(prefix);
            int end = result.indexOf("}", start);
            if (end <= start) {
                break;
            }
            String placeholder = result.substring(start, end + 1);
            String inner = placeholder.substring(prefix.length(), placeholder.length() - 1).trim();
            int sep = inner.indexOf(':');
            if (sep < 0) {
                throw new IllegalArgumentException(
                        "Malformed placeholder '" + placeholder
                                + "'. Expected {CAPTURED_TIME:<key>:<format>}.");
            }
            String key = inner.substring(0, sep).trim();
            String format = inner.substring(sep + 1).trim();
            Long epochMillis = testContext.getCapturedTime(key);
            if (epochMillis == null) {
                throw new IllegalStateException(
                        "No time captured as '" + key + "'. Use the step "
                                + "'I capture the current time as \"" + key + "\"' before referencing it.");
            }
            result = result.replace(placeholder, formatEpochMillis(epochMillis, format));
        }
        return result;
    }

    public String replacePlaceholders(String template) {
        String result = template;
        result = result.replace(ContextKeys.UUID, generateUUID());
        result = result.replace(ContextKeys.EMAIL, generateRandomEmail());
        result = result.replace(ContextKeys.TIMESTAMP, getCurrentTimestamp());

        
        
        while (result.contains(ContextKeys.RANDOM_NAME)) {
            String name = RandomDataHelper.randomName();
            result = result.replaceFirst(
                    java.util.regex.Pattern.quote(ContextKeys.RANDOM_NAME),
                    Matcher.quoteReplacement(name)
            );
        }

        while (result.contains("{RANDOM_INT:")) {
            int start = result.indexOf("{RANDOM_INT:");
            int end = result.indexOf("}", start);
            if (end > start) {
                String placeholder = result.substring(start, end + 1);
                String[] parts = placeholder.substring(12, placeholder.length() - 1).split(":");
                if (parts.length == 2) {
                    int min = Integer.parseInt(parts[0]);
                    int max = Integer.parseInt(parts[1]);
                    result = result.replace(placeholder, String.valueOf(generateRandomInt(min, max)));
                }
            }
        }

        while (result.contains("{RANDOM_STRING:")) {
            int start = result.indexOf("{RANDOM_STRING:");
            int end = result.indexOf("}", start);
            if (end > start) {
                String placeholder = result.substring(start, end + 1);
                int length = Integer.parseInt(
                        placeholder.substring(15, placeholder.length() - 1)
                );
                String cacheKey = "RANDOM_STRING:" + length;
                String randomValue = testContext.getRandomStringCache().computeIfAbsent(
                        cacheKey,
                        k -> generateRandomString(length)
                );
                result = result.replace(placeholder, randomValue);
            }
        }

        result = replaceAllocationMonthOffset(result);
        result = replaceCapturedTimePlaceholders(result);
        result = replaceNowPlaceholders(result);

        logger.debug("Replaced placeholders in template");
        return result;
    }


    public String replaceAllocationMonthOffset(String template) {
        if (template == null) {
            return null;
        }
        String result = template;
        String prefix = "{ALLOCATION_MONTH_OFFSET:";
        while (result.contains(prefix)) {
            int start = result.indexOf(prefix);
            int end = result.indexOf("}", start);
            if (end <= start) {
                break;
            }
            String placeholder = result.substring(start, end + 1);
            String inner = placeholder.substring(prefix.length(), placeholder.length() - 1).trim();
            int offset = Integer.parseInt(inner);
            String allocationMonth = LocalDate.now()
                    .plusMonths(offset)
                    .withDayOfMonth(1)
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            result = result.replace(placeholder, allocationMonth);
        }
        return result;
    }
}
