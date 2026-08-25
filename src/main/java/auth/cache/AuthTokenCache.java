package auth.cache;

import config.ConfigReader;
import enums.Environment;
import enums.UserRole;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class AuthTokenCache {

    private record CacheKey(Environment env, String module, UserRole role, String userType, int userSlot) {}

    private record CachedAuth(
            String authToken,
            String companyId,
            String userId,
            String userName,
            String userEmail,
            String userMobile,
            Instant expiresAt
    ) {}

    private static final Map<CacheKey, CachedAuth> CACHE = new ConcurrentHashMap<>();

    private final ConfigReader configReader;

    public AuthTokenCache(ConfigReader configReader) {
        this.configReader = configReader;
    }

    public boolean isEnabled() {
        return configReader.isAuthTokenCacheEnabled();
    }

    public CachedSession getIfValid(Environment env, String module, UserRole role, String userType, int userSlot) {
        if (!isEnabled()) {
            return null;
        }
        CachedAuth cached = CACHE.get(new CacheKey(env, module, role, userType, userSlot));
        if (cached == null || Instant.now().isAfter(cached.expiresAt())) {
            return null;
        }
        return new CachedSession(
                cached.authToken(),
                cached.companyId(),
                cached.userId(),
                cached.userName(),
                cached.userEmail(),
                cached.userMobile()
        );
    }

    public void put(
            Environment env,
            String module,
            UserRole role,
            String userType,
            int userSlot,
            String authToken,
            String companyId
    ) {
        put(env, module, role, userType, userSlot, authToken, companyId, null, null, null, null);
    }

    public void put(
            Environment env,
            String module,
            UserRole role,
            String userType,
            int userSlot,
            String authToken,
            String companyId,
            String userId,
            String userName,
            String userEmail,
            String userMobile
    ) {
        if (!isEnabled()) {
            return;
        }
        Instant expiresAt = Instant.now().plusSeconds(configReader.getAuthTokenCacheTtlMinutes() * 60L);
        CACHE.put(
                new CacheKey(env, module, role, userType, userSlot),
                new CachedAuth(authToken, companyId, userId, userName, userEmail, userMobile, expiresAt)
        );
    }

    public void invalidate(Environment env, String module, UserRole role, String userType, int userSlot) {
        CACHE.remove(new CacheKey(env, module, role, userType, userSlot));
    }

    public static void clearAll() {
        CACHE.clear();
    }

    public record CachedSession(
            String authToken,
            String companyId,
            String userId,
            String userName,
            String userEmail,
            String userMobile
    ) {}
}
