package config;

import enums.Environment;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigReader {
    private static final Logger logger = LogManager.getLogger(ConfigReader.class);
    private static final String PROPERTIES_FILE = "global.properties";
    private static final String CRYPTO_PROPERTIES_FILE = "secrets/crypto.properties";

    private final Properties properties = new Properties();
    private final Properties cryptoProperties = new Properties();

    public ConfigReader() {
        loadProperties();
        loadCryptoProperties();
    }

    private void loadCryptoProperties() {
        try (InputStream inputStream = getClass()
                .getClassLoader()
                .getResourceAsStream(CRYPTO_PROPERTIES_FILE)) {

            if (inputStream == null) {
                logger.error("Crypto properties file '{}' not found", CRYPTO_PROPERTIES_FILE);
                throw new RuntimeException("Crypto properties file not found: " + CRYPTO_PROPERTIES_FILE);
            }

            cryptoProperties.load(inputStream);
            logger.info("Successfully loaded crypto properties");

        } catch (IOException e) {
            logger.error("Error loading crypto properties file", e);
            throw new RuntimeException("Failed to load crypto properties file", e);
        }
    }

    private void loadProperties() {
        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream(PROPERTIES_FILE)) {
            if (inputStream == null) {
                logger.error("Properties file '{}' not found in classpath", PROPERTIES_FILE);
                throw new RuntimeException("Properties file not found: " + PROPERTIES_FILE);
            }
            properties.load(inputStream);
            logger.info("Successfully loaded properties from {}", PROPERTIES_FILE);
        } catch (IOException e) {
            logger.error("Error loading properties file: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to load properties file", e);
        }
    }

    public String getCryptoProperty(String key) {
        String value = cryptoProperties.getProperty(key);
        if (value == null || value.isBlank()) {
            logger.error("Crypto property '{}' not found", key);
            throw new RuntimeException("Crypto property not found: " + key);
        }
        return value;
    }

    public String getPublicKey() {
        Environment env = getEnvironment();
        String publicKey = resolvePublicKey(env);
        logger.info("Loaded RSA public key for environment {}", env.name());
        return publicKey;
    }

    /**
     * Resolves RSA public key from secrets/crypto.properties.
     * Primary: {@code {env}.public.key} (e.g. stag.public.key, dev.public.key).
     * Legacy: PROD_PUBLIC_KEY / DEV_PUBLIC_KEY.
     * Fallback: STAG and UAT use dev.public.key when env-specific key is absent.
     */
    private String resolvePublicKey(Environment env) {
        String envKey = env.getValue() + ".public.key";
        String publicKey = cryptoProperties.getProperty(envKey);

        if (isBlank(publicKey)) {
            String legacyKey = env == Environment.PROD ? "PROD_PUBLIC_KEY" : "DEV_PUBLIC_KEY";
            publicKey = cryptoProperties.getProperty(legacyKey);
        }

        if (isBlank(publicKey) && (env == Environment.STAG || env == Environment.UAT)) {
            publicKey = cryptoProperties.getProperty("dev.public.key");
            if (!isBlank(publicKey)) {
                logger.warn("{}.public.key not found; using dev.public.key for {}", envKey, env.name());
            }
        }

        if (isBlank(publicKey)) {
            throw new RuntimeException(
                    "RSA public key not found for environment " + env.name()
                            + ". Add '" + envKey + "' to src/main/resources/secrets/crypto.properties "
                            + "(see dev.public.key / prod.public.key)."
            );
        }
        return publicKey.trim();
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    public String getDbUrl() {
        Environment env = getEnvironment();
        String dbUrlKey = switch (env) {
            case PROD -> "prod.recovery.db.url";
            case STAG -> "stag.recovery.db.url";
            default -> "dev.recovery.db.url";
        };
        String dbURL = getCryptoProperty(dbUrlKey);
        logger.info("Using DB URL for environment {}", env.name());
        return dbURL;
    }

    public String getDbUsername() {
        Environment env = getEnvironment();
        String dbUsernameKey = switch (env) {
            case PROD -> "prod.recovery.db.username";
            case STAG -> "stag.recovery.db.username";
            default -> "dev.recovery.db.username";
        };
        return getCryptoProperty(dbUsernameKey);
    }

    public String getDbPassword() {
        Environment env = getEnvironment();
        String dbPasswordKey = switch (env) {
            case PROD -> "prod.recovery.db.password";
            case STAG -> "stag.recovery.db.password";
            default -> "dev.recovery.db.password";
        };
        return getCryptoProperty(dbPasswordKey);
    }

    public String getProperty(String key) {
        String value = properties.getProperty(key);
        if (value == null) {
            logger.warn("Property '{}' not found in properties file", key);
        }
        return value;
    }

    public String getProperty(String key, String defaultValue) {
        return properties.getProperty(key, defaultValue);
    }

    public Environment getEnvironment() {
        String env = getProperty("environment");
        return Environment.valueOf(env.toUpperCase());
    }

    public String getBaseUrl() {
        Environment env = getEnvironment();
        String envKey = env.getValue() + ".base.url";
        String baseUrl = getProperty(envKey);

        if (baseUrl == null || baseUrl.isEmpty()) {
            logger.error("Base URL not configured for environment: {}", env.getValue());
            throw new RuntimeException("Base URL not configured for environment: " + env.getValue());
        }

        logger.info("Using base URL for {} environment: {}", env.getValue(), baseUrl);
        return baseUrl;
    }

    public String getAuthToken() {
        return getProperty("auth.token", "");
    }

    public int getConnectionTimeout() {
        return Integer.parseInt(getProperty("api.connection.timeout", "30000"));
    }

    public int getReadTimeout() {
        return Integer.parseInt(getProperty("api.read.timeout", "60000"));
    }

    public boolean isRequestLoggingEnabled() {
        return Boolean.parseBoolean(getProperty("request.logging.enabled", "true"));
    }

    public boolean isResponseLoggingEnabled() {
        return Boolean.parseBoolean(getProperty("response.logging.enabled", "true"));
    }

    public String getDefaultContentType() {
        return getProperty("default.content.type", "application/json");
    }

    public String getDefaultAcceptType() {
        return getProperty("default.accept.type", "application/json");
    }

    public String getLoanId() {
        return getProperty("loan.id", "");
    }

    public String getCompanyId() {
        return getProperty("company.id", "");
    }

    public String getAllocationMonth() {
        return getProperty("allocation.month", "");
    }

    public String getReplacePreviousData() {
        return getProperty("replace.previous.data", "false");
    }

    public String getReplaceGivenData() {
        return getProperty("replace.given.data", "false");
    }

    public boolean isUniqueLoanIdPerScenarioEnabled() {
        return Boolean.parseBoolean(getProperty("test.data.unique.loan.id.per.scenario", "true"));
    }

    public String getLoanIdPrefix() {
        return getProperty("test.data.loan.id.prefix", "api_auto");
    }

    public boolean isAuthTokenCacheEnabled() {
        return Boolean.parseBoolean(getProperty("auth.token.cache.enabled", "true"));
    }

    public int getAuthTokenCacheTtlMinutes() {
        return Integer.parseInt(getProperty("auth.token.cache.ttl.minutes", "30"));
    }

    public int getParallelThreadCount() {
        String override = System.getProperty("parallel.thread.count");
        if (override != null && !override.isBlank()) {
            return Integer.parseInt(override.trim());
        }
        return Integer.parseInt(getProperty("parallel.thread.count", "2"));
    }

    /**
     * Number of distinct user accounts for parallel threads (slot 0 .. poolSize-1).
     * Defaults to {@link #getParallelThreadCount()} so it stays in sync with testng thread-count.
     * Override with {@code -Dparallel.user.pool.size=N}.
     */
    public int getParallelUserPoolSize() {
        String override = System.getProperty("parallel.user.pool.size");
        if (override != null && !override.isBlank()) {
            return Integer.parseInt(override.trim());
        }
        String fromFile = getProperty("parallel.user.pool.size");
        if (fromFile != null && !fromFile.isBlank()) {
            return Integer.parseInt(fromFile.trim());
        }
        return getParallelThreadCount();
    }

    public boolean isParallelExecutionEnabled() {
        return Boolean.parseBoolean(getProperty("parallel.execution.enabled", "false"));
    }

    /**
     * When true, request/response RestAssured filters are not attached (recommended for CI parallel runs).
     */
    public boolean isCiMode() {
        return Boolean.parseBoolean(System.getProperty("ci.mode", getProperty("ci.mode", "false")));
    }
}
