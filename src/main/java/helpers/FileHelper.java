package helpers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.JsonUtils;

/**
 * Thin facade over file/JSON read operations.
 *
 * <p>Currently delegates to {@link JsonUtils} so callers can prefer the {@code helpers.*} namespace
 * for discoverability; the implementation stays in one place.
 */
public final class FileHelper {

    private static final Logger LOGGER = LogManager.getLogger(FileHelper.class);

    private FileHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    /**
     * Reads a classpath resource (typically under {@code src/test/resources/} or
     * {@code src/main/resources/}) and returns its contents as a UTF-8 string.
     *
     * @param classpathLocation e.g. {@code "test-data/loan_recovery_request.json"}
     */
    public static String readResourceAsString(String classpathLocation) {
        LOGGER.debug("Reading classpath resource: {}", classpathLocation);
        return JsonUtils.readJsonFromFile(classpathLocation);
    }
}
