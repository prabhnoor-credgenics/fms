package helpers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.JsonUtils;


public final class FileHelper {

    private static final Logger LOGGER = LogManager.getLogger(FileHelper.class);

    private FileHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    
    public static String readResourceAsString(String classpathLocation) {
        LOGGER.debug("Reading classpath resource: {}", classpathLocation);
        return JsonUtils.readJsonFromFile(classpathLocation);
    }
}
