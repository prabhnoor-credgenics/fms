package utils;

import context.ContextKeys;
import context.TestContext;
import helpers.RandomDataHelper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;
import java.util.UUID;
import java.util.regex.Matcher;


public class TestDataHelper {
    private static final Logger logger = LogManager.getLogger(TestDataHelper.class);
    private static final Random RANDOM = new Random();
    private static final String ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    private static final String NUMBERS = "0123456789";
    private static final String ALPHANUMERIC = ALPHABET + NUMBERS;

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

        logger.debug("Replaced placeholders in template");
        return result;
    }
}
