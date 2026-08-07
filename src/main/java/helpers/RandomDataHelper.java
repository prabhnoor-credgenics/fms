package helpers;

import java.security.SecureRandom;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public final class RandomDataHelper {

    private static final SecureRandom RANDOM = new SecureRandom();

    private static final int SIX_DIGIT_BOUND = 1_000_000;
    private static final int MAX_UNIQUE_ATTEMPTS = 100;

    private static final String LOAN_ID_PREFIX = "Loan";
    private static final String COMPANY_NAME_PREFIX = "Company";
    private static final String VARIABLE_NAME_PREFIX = "variable";

    private static final Set<String> ISSUED_LOAN_IDS = ConcurrentHashMap.newKeySet();
    private static final Set<String> ISSUED_COMPANY_NAMES = ConcurrentHashMap.newKeySet();
    private static final Set<String> ISSUED_VARIABLE_NAMES = ConcurrentHashMap.newKeySet();

    private static final String[] FIRST_NAMES = {
            "Aarav", "Vihaan", "Aditya", "Vivaan", "Arjun", "Sai", "Reyansh", "Krishna",
            "Ishaan", "Shaurya", "Rohan", "Karthik", "Rahul", "Manish", "Aniket",
            "Ananya", "Aanya", "Diya", "Saanvi", "Ira", "Myra", "Anika", "Riya", "Pari",
            "Aadhya", "Pooja", "Sneha", "Priya", "Neha", "Kavya"
    };

    private static final String[] LAST_NAMES = {
            "Sharma", "Verma", "Gupta", "Patel", "Singh", "Kumar", "Reddy", "Iyer", "Khan",
            "Mehta", "Jain", "Shah", "Bose", "Nair", "Pillai", "Rao", "Mishra", "Joshi",
            "Kapoor", "Das", "Chopra", "Malhotra", "Bhatia", "Sinha", "Tiwari", "Yadav",
            "Roy", "Saxena", "Chatterjee", "Banerjee"
    };

    public static String generateRandomEmail() {
        String firstName = FIRST_NAMES[RANDOM.nextInt(FIRST_NAMES.length)].toLowerCase();
        return firstName + shortUuid() + "@yopmail.com";
    }

    private RandomDataHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static String shortUuid() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 12);
    }

    public static String uniqueLoanId() {
        return uniqueWithPrefix(LOAN_ID_PREFIX, ISSUED_LOAN_IDS);
    }

    public static String uniqueCompanyName() {
        return uniqueWithPrefix(COMPANY_NAME_PREFIX, ISSUED_COMPANY_NAMES);
    }

    public static String uniqueVariableName() {
        return uniqueWithPrefix(VARIABLE_NAME_PREFIX, ISSUED_VARIABLE_NAMES);
    }

    public static String randomFirstName() {
        return FIRST_NAMES[RANDOM.nextInt(FIRST_NAMES.length)];
    }

    public static String randomLastName() {
        return LAST_NAMES[RANDOM.nextInt(LAST_NAMES.length)];
    }

    public static String randomName() {
        return randomFirstName() + " " + randomLastName();
    }

    private static String uniqueWithPrefix(String prefix, Set<String> registry) {
        for (int attempt = 0; attempt < MAX_UNIQUE_ATTEMPTS; attempt++) {
            String candidate = prefix + sixDigitString();
            if (registry.add(candidate)) {
                return candidate;
            }
        }
        
        String fallback = prefix + sixDigitString() + System.nanoTime();
        registry.add(fallback);
        return fallback;
    }

    private static String sixDigitString() {
        return String.format("%06d", RANDOM.nextInt(SIX_DIGIT_BOUND));
    }

}
