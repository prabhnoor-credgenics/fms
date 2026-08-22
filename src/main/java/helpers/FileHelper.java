package helpers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.JsonUtils;

import java.io.File;
import java.util.Locale;

public final class FileHelper {

    private static final Logger LOGGER = LogManager.getLogger(FileHelper.class);
    private static final String TEST_RESOURCES_PATH = "src/test/resources/";

    private FileHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static String readResourceAsString(String classpathLocation) {
        LOGGER.debug("Reading classpath resource: {}", classpathLocation);
        return JsonUtils.readJsonFromFile(classpathLocation);
    }

    /**
     * Resolves a test file for multipart upload in this order:
     * 1) {@code src/test/resources/<path>}
     * 2) project-relative {@code <path>}
     * 3) absolute {@code <path>} if it already exists
     */
    public static File resolveTestFile(String path) {
        if (path == null || path.isBlank()) {
            throw new IllegalArgumentException("File path must not be blank");
        }
        String trimmed = path.trim();
        if (trimmed.startsWith("src/test/resources/")) {
            trimmed = trimmed.substring("src/test/resources/".length());
        } else if (trimmed.startsWith("src/test/resources\\")) {
            trimmed = trimmed.substring("src/test/resources\\".length());
        }
        File fromResources = new File(TEST_RESOURCES_PATH + trimmed);
        if (fromResources.isFile()) {
            LOGGER.debug("Resolved test file from resources: {}", fromResources.getPath());
            return fromResources;
        }
        File fromProject = new File(path.trim());
        if (fromProject.isFile()) {
            LOGGER.debug("Resolved test file from project path: {}", fromProject.getPath());
            return fromProject;
        }
        throw new IllegalArgumentException(
                "File not found: '" + path + "'. Tried '" + fromResources.getPath()
                        + "' and '" + fromProject.getAbsolutePath() + "'.");
    }

    public static String guessMimeType(File file) {
        String name = file.getName().toLowerCase(Locale.ROOT);
        if (name.endsWith(".pdf")) {
            return "application/pdf";
        }
        if (name.endsWith(".png")) {
            return "image/png";
        }
        if (name.endsWith(".jpg") || name.endsWith(".jpeg")) {
            return "image/jpeg";
        }
        if (name.endsWith(".gif")) {
            return "image/gif";
        }
        if (name.endsWith(".csv")) {
            return "text/csv";
        }
        if (name.endsWith(".txt")) {
            return "text/plain";
        }
        if (name.endsWith(".json")) {
            return "application/json";
        }
        if (name.endsWith(".xml")) {
            return "application/xml";
        }
        if (name.endsWith(".xlsx")) {
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        }
        if (name.endsWith(".xls")) {
            return "application/vnd.ms-excel";
        }
        if (name.endsWith(".doc")) {
            return "application/msword";
        }
        if (name.endsWith(".docx")) {
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        }
        if (name.endsWith(".zip")) {
            return "application/zip";
        }
        return "application/octet-stream";
    }

    public static long fileSizeBytes(String path) {
        return fileSizeBytes(resolveTestFile(path));
    }

    public static long fileSizeBytes(File file) {
        if (file == null) {
            throw new IllegalArgumentException("File must not be null");
        }
        if (!file.isFile()) {
            throw new IllegalArgumentException("Not a readable file: " + file.getPath());
        }
        long size = file.length();
        LOGGER.debug("File size for '{}': {} bytes", file.getPath(), size);
        return size;
    }

    public static String fileSizeBytesAsString(String path) {
        return Long.toString(fileSizeBytes(path));
    }

    /**
     * Last filename suffix without the leading dot (e.g. {@code users.csv} → {@code csv}).
     */
    public static String fileExtension(String path) {
        File file = resolveTestFile(path);
        return fileExtension(file);
    }

    public static String fileExtension(File file) {
        if (file == null) {
            throw new IllegalArgumentException("File must not be null");
        }
        String name = file.getName();
        int dot = name.lastIndexOf('.');
        if (dot < 0 || dot == name.length() - 1) {
            throw new IllegalArgumentException("File has no extension: " + file.getPath());
        }
        String extension = name.substring(dot + 1).toLowerCase(Locale.ROOT).trim();
        if (extension.isEmpty()) {
            throw new IllegalArgumentException("File has no extension: " + file.getPath());
        }
        LOGGER.debug("File extension for '{}': {}", file.getPath(), extension);
        return extension;
    }
}
