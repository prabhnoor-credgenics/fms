package helpers;

import java.security.SecureRandom;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Thread-safe random data generators for ad-hoc payload values.
 *
 * <p>Unlike {@link utils.TestDataHelper}, these methods are static and do not require a
 * {@code TestContext}. Use them for values that don't need to be cached per scenario.
 *
 * <p><strong>Uniqueness:</strong> {@link #uniqueLoanId()} and {@link #uniqueCompanyName()} maintain
 * JVM-wide thread-safe registries of already-issued values and will not return a duplicate within
 * the same test run. With a 6-digit random suffix each registry supports up to 999,999 values.
 *
 * <p><strong>Person names:</strong> {@link #randomName()}, {@link #randomFirstName()} and
 * {@link #randomLastName()} return values from curated first/last name lists. They are
 * randomized but not uniqueness-guaranteed - the {@code 30 × 30 = 900} combination space is
 * sufficient for typical scenario volumes; duplicates are tolerated by design.
 */
public final class RandomDataHelper {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String ALPHANUMERIC =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    private static final int SIX_DIGIT_BOUND = 1_000_000;
    private static final int MAX_UNIQUE_ATTEMPTS = 100;

    private static final String LOAN_ID_PREFIX = "Loan";
    private static final String COMPANY_NAME_PREFIX = "Company";

    private static final Set<String> ISSUED_LOAN_IDS = ConcurrentHashMap.newKeySet();
    private static final Set<String> ISSUED_COMPANY_NAMES = ConcurrentHashMap.newKeySet();

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

    private RandomDataHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static String uuid() {
        return UUID.randomUUID().toString();
    }

    public static String shortUuid() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 12);
    }

    public static String alphanumeric(int length) {
        if (length <= 0) {
            throw new IllegalArgumentException("length must be > 0");
        }
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(ALPHANUMERIC.charAt(RANDOM.nextInt(ALPHANUMERIC.length())));
        }
        return sb.toString();
    }

    /**
     * Returns a JVM-unique loan identifier of the form {@code "Loan" + 6 random digits}
     * (e.g. {@code "Loan123456"}). Intended for {@code loan_id} in loan upload scenarios.
     *
     * @return a unique loan id string, never previously returned in this JVM
     */
    public static String uniqueLoanId() {
        return uniqueWithPrefix(LOAN_ID_PREFIX, ISSUED_LOAN_IDS);
    }

    /**
     * Returns a JVM-unique company name of the form {@code "Company" + 6 random digits}
     * (e.g. {@code "Company123456"}). Intended for {@code company_name} / {@code trademark}
     * in recovery company / company-creation scenarios.
     *
     * @return a unique company name string, never previously returned in this JVM
     */
    public static String uniqueCompanyName() {
        return uniqueWithPrefix(COMPANY_NAME_PREFIX, ISSUED_COMPANY_NAMES);
    }

    /**
     * Returns a random first name from the curated first-name pool.
     */
    public static String randomFirstName() {
        return FIRST_NAMES[RANDOM.nextInt(FIRST_NAMES.length)];
    }

    /**
     * Returns a random last name from the curated last-name pool.
     */
    public static String randomLastName() {
        return LAST_NAMES[RANDOM.nextInt(LAST_NAMES.length)];
    }

    /**
     * Returns a random full name as {@code "FirstName LastName"} drawn from the curated
     * first/last name pools. Intended for {@code applicant_name}, {@code co_applicant_name},
     * {@code reference.name}, {@code loan_guarantor_name},
     * {@code loan_regional_manager_name}, {@code authorized_representative_name},
     * and company admin name fields.
     *
     * @return a random full name, e.g. {@code "Aarav Sharma"}
     */
    public static String randomName() {
        return randomFirstName() + " " + randomLastName();
    }

    /**
     * Resets the JVM-wide uniqueness registries. Intended for test harness use only.
     */
    public static void resetUniqueRegistries() {
        ISSUED_LOAN_IDS.clear();
        ISSUED_COMPANY_NAMES.clear();
    }

    private static String uniqueWithPrefix(String prefix, Set<String> registry) {
        for (int attempt = 0; attempt < MAX_UNIQUE_ATTEMPTS; attempt++) {
            String candidate = prefix + sixDigitString();
            if (registry.add(candidate)) {
                return candidate;
            }
        }
        // Extremely unlikely: registry near exhaustion. Append nano timestamp to guarantee uniqueness.
        String fallback = prefix + sixDigitString() + System.nanoTime();
        registry.add(fallback);
        return fallback;
    }

    private static String sixDigitString() {
        return String.format("%06d", RANDOM.nextInt(SIX_DIGIT_BOUND));
    }
}
