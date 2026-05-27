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


public class AuthManager {

    private static final Logger logger = LogManager.getLogger(AuthManager.class);

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

    public void initializeAuthentication(UserRole role) {
        String userType = configReader.getProperty("user_type");
        Environment env = configReader.getEnvironment();
        int userSlot = testContext.getUserSlot();

        AuthTokenCache.CachedSession cached = authTokenCache.getIfValid(env, role, userType, userSlot);
        if (cached != null) {
            testContext.setAuthToken(cached.authToken());
            if (cached.companyId() != null) {
                testContext.setCompanyId(cached.companyId());
            }
            return;
        }

        switch (userType.toLowerCase()) {
            case "user" -> userLoginService.performUserLogin(env, role, userSlot);
            case "api_key_single_company" -> apiKeyService.generateSingleCompanyApiKey(env);
            case "api_key_multiple_companies" -> apiKeyService.loadMultiCompanyApiKey(env);
            default -> throw new RuntimeException(
                    "Invalid user_type in global.properties (expected: user | api_key_single_company | api_key_multiple_companies)"
            );
        }

        authTokenCache.put(
                env,
                role,
                userType,
                userSlot,
                testContext.getAuthToken(),
                testContext.getCompanyId()
        );
    }

    public void reAuthenticate(UserRole role) {
        Environment env = configReader.getEnvironment();
        String userType = configReader.getProperty("user_type");
        int userSlot = testContext.getUserSlot();
        logger.warn("Session expired for role={}, slot={}. Invalidating cache and re-authenticating.", role, userSlot);
        authTokenCache.invalidate(env, role, userType, userSlot);
        initializeAuthentication(role);
    }
}
