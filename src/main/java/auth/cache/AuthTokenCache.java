package auth.cache;

import config.ConfigReader;
import enums.Environment;
import enums.UserRole;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class AuthTokenCache {

    private record CacheKey(Environment env, String module, UserRole role, String userType, int userSlot) {}

    private record CachedAuth(String authToken, String companyId, Instant expiresAt) {}

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
        return new CachedSession(cached.authToken(), cached.companyId());
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
        if (!isEnabled()) {
            return;
        }
        Instant expiresAt = Instant.now().plusSeconds(configReader.getAuthTokenCacheTtlMinutes() * 60L);
        CACHE.put(
                new CacheKey(env, module, role, userType, userSlot),
                new CachedAuth(authToken, companyId, expiresAt)
        );
    }

    public void invalidate(Environment env, String module, UserRole role, String userType, int userSlot) {
        CACHE.remove(new CacheKey(env, module, role, userType, userSlot));
    }

    public static void clearAll() {
        CACHE.clear();
    }

    public record CachedSession(String authToken, String companyId) {}
}
