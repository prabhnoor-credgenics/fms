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
    private static final DateTimeFormatter ALLOCATION_MONTH_OFFSET_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-M-dd");

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

    public String currentTime(String format) {
        return formatEpochMillis(System.currentTimeMillis(), format);
    }

    public Map<String, String> allTimeFormats(long epochMillis) {
        Map<String, String> out = new LinkedHashMap<>();
        for (String format : TIME_FORMATS) {
            out.put(format, formatEpochMillis(epochMillis, format));
        }
        return out;
    }

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
            String[] parts = inner.split(":");
            if (parts.length == 2) {
                String key = parts[0].trim();
                String format = parts[1].trim();
                Long epochMillis = testContext.getCapturedTime(key);
                if (epochMillis == null) {
                    throw new IllegalStateException(
                            "No time captured as '" + key + "'. Use the step "
                                    + "'I capture the current time as \"" + key + "\"' before referencing it.");
                }
                result = result.replace(placeholder, formatEpochMillis(epochMillis, format));
                continue;
            }
            if (parts.length == 4) {
                String key = parts[0].trim();
                long amount = Long.parseLong(parts[1].trim());
                String unit = parts[2].trim();
                String format = parts[3].trim();
                Long epochMillis = testContext.getCapturedTime(key);
                if (epochMillis == null) {
                    throw new IllegalStateException(
                            "No time captured as '" + key + "'. Use the step "
                                    + "'I capture the current time as \"" + key + "\"' before referencing it.");
                }
                long adjustedEpochMillis = applyCapturedTimeOffset(epochMillis, amount, unit, placeholder);
                result = result.replace(placeholder, formatEpochMillis(adjustedEpochMillis, format));
                continue;
            }
            throw new IllegalArgumentException(
                    "Malformed placeholder '" + placeholder
                            + "'. Expected {CAPTURED_TIME:<key>:<format>} or "
                            + "{CAPTURED_TIME_OFFSET:<key>:<amount>:<unit>:<format>}.");
        }
        return result;
    }

    private long applyCapturedTimeOffset(long epochMillis, long amount, String unit, String placeholder) {
        switch (unit.toLowerCase()) {
            case "second":
            case "seconds":
                return epochMillis + amount * 1000L;
            case "minute":
            case "minutes":
                return epochMillis + amount * 60_000L;
            case "hour":
            case "hours":
                return epochMillis + amount * 3_600_000L;
            case "day":
            case "days":
                return epochMillis + amount * 86_400_000L;
            default:
                throw new IllegalArgumentException(
                        "Unsupported offset unit in '" + placeholder + "'. Use seconds, minutes, hours, or days.");
        }
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
                    .format(ALLOCATION_MONTH_OFFSET_FORMAT);
            result = result.replace(placeholder, allocationMonth);
        }
        return result;
    }
}
