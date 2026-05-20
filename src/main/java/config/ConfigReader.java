package config;

import enums.Environment;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigReader {
    private static final Logger logger = LogManager.getLogger(ConfigReader.class);
    private static final String GLOBAL_PROPERTIES_FILE = "global.properties";
    private static final String CRYPTO_PROPERTIES_FILE = "secrets/crypto.properties";
    private static final String ENVIRONMENT_KEY = "environment";

    
    private final Properties properties = new Properties();
    private final Properties cryptoProperties = new Properties();

    private String activeEnvironment;

    public ConfigReader() {
        loadGlobalProperties();
        loadEnvironmentProperties();
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

    private void loadGlobalProperties() {
        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream(GLOBAL_PROPERTIES_FILE)) {
            if (inputStream == null) {
                logger.error("Properties file '{}' not found in classpath", GLOBAL_PROPERTIES_FILE);
                throw new RuntimeException("Properties file not found: " + GLOBAL_PROPERTIES_FILE);
            }
            properties.load(inputStream);
            logger.info("Successfully loaded properties from {}", GLOBAL_PROPERTIES_FILE);
        } catch (IOException e) {
            logger.error("Error loading properties file: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to load properties file", e);
        }
    }

    
    private void loadEnvironmentProperties() {
        String envOverride = System.getProperty(ENVIRONMENT_KEY);
        String envName = (envOverride != null && !envOverride.isBlank())
                ? envOverride.trim()
                : properties.getProperty(ENVIRONMENT_KEY);

        if (envName == null || envName.isBlank()) {
            throw new RuntimeException(
                    "'environment' key is missing from " + GLOBAL_PROPERTIES_FILE
                            + " and no -Denvironment=... was provided."
            );
        }

        activeEnvironment = envName.trim().toLowerCase();
        properties.setProperty(ENVIRONMENT_KEY, activeEnvironment);

        String envFile = activeEnvironment + ".properties";
        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream(envFile)) {
            if (inputStream == null) {
                logger.error("Environment properties file '{}' not found in classpath", envFile);
                throw new RuntimeException(
                        "Environment properties file not found: " + envFile
                                + ". Create src/main/resources/" + envFile
                                + " with env-specific keys (base url, emails, passwords, api key company id, …)."
                );
            }
            Properties envProperties = new Properties();
            envProperties.load(inputStream);
            properties.putAll(envProperties);
            logger.info("Successfully loaded environment properties from {} ({} keys)",
                    envFile, envProperties.size());
        } catch (IOException e) {
            logger.error("Error loading environment properties file '{}': {}", envFile, e.getMessage(), e);
            throw new RuntimeException("Failed to load environment properties file: " + envFile, e);
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
        return Environment.valueOf(activeEnvironment.toUpperCase());
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

    public String getApiKeyGlobalCompanyId() {
        Environment env = getEnvironment();
        return getProperty(env.getValue() + ".api.key.global.company.id", "");
    }

    public long getMaxResponseTimeMs() {
        return Long.parseLong(getProperty("api.max.response.time.ms", "5000"));
    }

    public String getAllocationMonth() {
        return getProperty("allocation.month", "");
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


    public boolean isCiMode() {
        return Boolean.parseBoolean(System.getProperty("ci.mode", getProperty("ci.mode", "false")));
    }

    public String getCompanyCreationAliasProfileId() {
        return getProperty("company.creation.alias_profile_id", "icoPMIUXyTzl");
    }

    public String getCompanyCreationCountryIsdCode() {
        return getProperty("company.creation.country_isd_code", "+91");
    }

    public String getCompanyCreationGstNumber() {
        return getProperty("company.creation.gst_number", "24AAACC1206D1ZM");
    }

    public String getCompanyCreationWhitelistedIps() {
        return getProperty(
                "company.creation.whitelisted_ips",
                "103.55.60.250,103.55.60.251"
        );
    }
}
