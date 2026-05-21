package config;


public final class ConfigKeys {

    public static final String ENVIRONMENT = "environment";
    public static final String USER_TYPE = "user_type";
    public static final String LOAN_ID = "loan.id";
    public static final String COMPANY_ID = "company.id";
    public static final String ALLOCATION_MONTH = "allocation.month";
    public static final String AUTH_TOKEN_CACHE_ENABLED = "auth.token.cache.enabled";
    public static final String AUTH_TOKEN_CACHE_TTL_MINUTES = "auth.token.cache.ttl.minutes";
    public static final String PARALLEL_USER_POOL_SIZE = "parallel.user.pool.size";
    public static final String PARALLEL_THREAD_COUNT = "parallel.thread.count";
    public static final String UNIQUE_LOAN_ID_PER_SCENARIO = "test.data.unique.loan.id.per.scenario";
    public static final String LOAN_ID_PREFIX = "test.data.loan.id.prefix";
    public static final String REQUEST_LOGGING_ENABLED = "request.logging.enabled";
    public static final String RESPONSE_LOGGING_ENABLED = "response.logging.enabled";
    public static final String CI_MODE = "ci.mode";

    private ConfigKeys() {
        throw new UnsupportedOperationException("Constants class");
    }

    public static String baseUrlKey(String envValue) {
        return envValue + ".base.url";
    }
}
