package auth.manager;

import auth.cache.AuthTokenCache;
import auth.service.ApiKeyService;
import auth.service.UserLoginService;
import config.ConfigReader;
import context.TestContext;
import enums.Environment;
import enums.UserRole;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.concurrent.ConcurrentHashMap;

public class AuthManager {

    private static final Logger logger = LogManager.getLogger(AuthManager.class);

    private static final ConcurrentHashMap<String, Object> LOGIN_LOCKS = new ConcurrentHashMap<>();

    private final ConfigReader configReader;
    private final TestContext testContext;
    private final UserLoginService userLoginService;
    private final ApiKeyService apiKeyService;
    private final AuthTokenCache authTokenCache;

    public AuthManager(
            ConfigReader configReader,
            TestContext testContext,
            UserLoginService userLoginService,
            ApiKeyService apiKeyService,
            AuthTokenCache authTokenCache
    ) {
        this.configReader = configReader;
        this.testContext = testContext;
        this.userLoginService = userLoginService;
        this.apiKeyService = apiKeyService;
        this.authTokenCache = authTokenCache;
    }

    public void initializeAuthentication(UserRole role, int slot) {
        initializeAuthentication(role, null, slot);
    }

    public void initializeAuthentication(UserRole role, String module, int slot) {
        testContext.setUserSlot(slot);
        initializeAuthentication(role, module);
    }

    public void initializeAuthentication(UserRole role) {
        initializeAuthentication(role, (String) null);
    }

    public void initializeAuthentication(UserRole role, String module) {
        String effectiveModule = resolveModule(module);
        testContext.setActiveModule(effectiveModule);
        String userType = configReader.getProperty("user_type");
        Environment env = configReader.getEnvironment();
        int userSlot = testContext.getUserSlot();

        AuthTokenCache.CachedSession cached = authTokenCache.getIfValid(env, effectiveModule, role, userType, userSlot);
        if (cached != null) {
            testContext.setAuthToken(cached.authToken());
            if (cached.companyId() != null) {
                testContext.setCompanyId(cached.companyId());
            }
            return;
        }

        String lockKey = env + ":" + effectiveModule + ":" + role + ":" + userType + ":" + userSlot;
        Object lock = LOGIN_LOCKS.computeIfAbsent(lockKey, k -> new Object());
        synchronized (lock) {
            cached = authTokenCache.getIfValid(env, effectiveModule, role, userType, userSlot);
            if (cached != null) {
                testContext.setAuthToken(cached.authToken());
                if (cached.companyId() != null) {
                    testContext.setCompanyId(cached.companyId());
                }
                return;
            }

            switch (userType.toLowerCase()) {
                case "user" -> userLoginService.performUserLogin(env, effectiveModule, role, userSlot);
                case "api_key_single_company" -> apiKeyService.generateSingleCompanyApiKey(env);
                case "api_key_multiple_companies" -> apiKeyService.loadMultiCompanyApiKey(env);
                default -> throw new RuntimeException(
                        "Invalid user_type in global.properties (expected: user | api_key_single_company | api_key_multiple_companies)"
                );
            }

            authTokenCache.put(env, effectiveModule, role, userType, userSlot,
                    testContext.getAuthToken(), testContext.getCompanyId());
        }
    }

    private String resolveModule(String module) {
        String candidate = (module == null || module.isBlank())
                ? configReader.getDefaultModule()
                : module;
        return (candidate == null || candidate.isBlank()) ? null : candidate.trim().toLowerCase();
    }

    public void initializeApiKeyAuthentication() {
        Environment env = configReader.getEnvironment();
        apiKeyService.loadMultiCompanyApiKey(env);
        logger.info("Authenticated via API key for env={} (company id={})",
                env, testContext.getCompanyId());
    }

    public void reAuthenticate(UserRole role) {
        Environment env = configReader.getEnvironment();
        String userType = configReader.getProperty("user_type");
        int userSlot = testContext.getUserSlot();
        String module = testContext.getActiveModule();
        logger.warn("Session expired for module={}, role={}, slot={}. Invalidating cache and re-authenticating.",
                module == null ? "-" : module, role, userSlot);
        authTokenCache.invalidate(env, module, role, userType, userSlot);
        initializeAuthentication(role, module);
    }
}
