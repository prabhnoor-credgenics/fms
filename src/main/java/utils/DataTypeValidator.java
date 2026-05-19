package utils;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.math.BigDecimal;
import java.util.regex.Pattern;


public class DataTypeValidator {
    private static final Logger logger = LogManager.getLogger(DataTypeValidator.class);
    
    // Regex patterns
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    );
    
    private static final Pattern URL_PATTERN = Pattern.compile(
        "^(https?://)([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*/?$"
    );
    
    private static final Pattern DATE_PATTERN = Pattern.compile(
        "^\\d{4}-\\d{2}-\\d{2}$"
    );
    
    private static final Pattern MOBILE_PATTERN = Pattern.compile(
        "^\\d{5,15}$"
    );
    
    private static final Pattern PINCODE_PATTERN = Pattern.compile(
        "^\\d{5,8}$"
    );


    public static boolean isValidText(String value, int maxLength) {
        if (value == null) {
            logger.warn("Text validation failed: value is null");
            return false;
        }
        
        // Trim and check length
        String trimmed = value.trim();
        if (trimmed.length() > maxLength) {
            logger.warn("Text validation failed: exceeds max length of {}", maxLength);
            return false;
        }
        
        // Check if it's a pure number (should be rejected for text fields)
        if (trimmed.matches("^\\d+$")) {
            logger.warn("Text validation failed: numeric-only value not allowed");
            return false;
        }
        
        return true;
    }


    public static boolean isValidBoolean(String value) {
        if (value == null) {
            return false;
        }
        String normalized = value.trim().toUpperCase();
        return normalized.equals("TRUE") || normalized.equals("FALSE") || 
               normalized.equals("YES") || normalized.equals("NO");
    }


    public static boolean isValidInteger(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        try {
            int intValue = Integer.parseInt(value.trim());
            return intValue >= 0; // Allow zero and positive
        } catch (NumberFormatException e) {
            logger.warn("Integer validation failed: {}", e.getMessage());
            return false;
        }
    }


    public static boolean isValidIntegerInRange(String value, int min, int max) {
        if (!isValidInteger(value)) {
            return false;
        }
        try {
            int intValue = Integer.parseInt(value.trim());
            return intValue >= min && intValue <= max;
        } catch (NumberFormatException e) {
            return false;
        }
    }


    public static boolean isValidDecimal(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        try {
            BigDecimal decimal = new BigDecimal(value.trim());
            if (decimal.compareTo(BigDecimal.ZERO) < 0) {
                return false;
            }
            // Check decimal places
            int scale = decimal.scale();
            if (scale > 2) {
                return false;
            }
            return true;
        } catch (NumberFormatException e) {
            logger.warn("Decimal validation failed: {}", e.getMessage());
            return false;
        }
    }


    public static boolean isValidAmount(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        
        // Reject scientific notation
        if (value.toUpperCase().contains("E")) {
            logger.warn("Amount validation failed: scientific notation not allowed");
            return false;
        }
        
        // Reject currency symbols
        if (value.contains("$") || value.contains("₹") || value.contains("€") || value.contains("£")) {
            logger.warn("Amount validation failed: currency symbols not allowed");
            return false;
        }
        
        return isValidDecimal(value);
    }


    public static boolean isValidPercentage(String value) {
        if (!isValidDecimal(value)) {
            return false;
        }
        try {
            BigDecimal percentage = new BigDecimal(value.trim());
            return percentage.compareTo(BigDecimal.ZERO) >= 0 && 
                   percentage.compareTo(new BigDecimal("100")) <= 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }


    public static boolean isValidMobileNumber(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        return MOBILE_PATTERN.matcher(value.trim()).matches();
    }


    public static boolean isValidEmail(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        String email = value.trim();
        
        // Check for multiple '@'
        long atCount = email.chars().filter(ch -> ch == '@').count();
        if (atCount != 1) {
            logger.warn("Email validation failed: multiple '@' symbols");
            return false;
        }
        
        // Check for consecutive dots
        if (email.contains("..")) {
            logger.warn("Email validation failed: consecutive dots");
            return false;
        }
        
        return EMAIL_PATTERN.matcher(email).matches();
    }


    public static boolean isValidPincode(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        return PINCODE_PATTERN.matcher(value.trim()).matches();
    }


    public static boolean isValidUrl(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        String url = value.trim();
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
            logger.warn("URL validation failed: must start with http:// or https://");
            return false;
        }
        return URL_PATTERN.matcher(url).matches();
    }


    public static boolean isValidDate(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        String date = value.trim();
        
        // Must match YYYY-MM-DD pattern
        if (!DATE_PATTERN.matcher(date).matches()) {
            logger.warn("Date validation failed: must be in YYYY-MM-DD format");
            return false;
        }
        
        // Basic date validation (year, month, day ranges)
        try {
            String[] parts = date.split("-");
            int year = Integer.parseInt(parts[0]);
            int month = Integer.parseInt(parts[1]);
            int day = Integer.parseInt(parts[2]);
            
            if (month < 1 || month > 12) {
                return false;
            }
            if (day < 1 || day > 31) {
                return false;
            }
            if (year < 1900 || year > 2100) {
                return false;
            }
            
            return true;
        } catch (Exception e) {
            return false;
        }
    }


    public static boolean isValidCibilScore(String value) {
        return isValidIntegerInRange(value, 300, 900);
    }
}