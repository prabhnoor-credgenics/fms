package auth.resolver;

import auth.model.UserCredentials;

import config.ConfigReader;
import enums.Environment;
import enums.UserRole;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.ArrayList;
import java.util.List;

public class UserCredentialsResolver {

    private static final Logger logger = LogManager.getLogger(UserCredentialsResolver.class);

    private final ConfigReader configReader;

    public UserCredentialsResolver(ConfigReader configReader) {
        this.configReader = configReader;
    }

    public UserCredentials resolve(Environment env, UserRole role, int slot) {
        return resolve(env, null, role, slot);
    }

    public UserCredentials resolve(Environment env, String module, UserRole role, int slot) {
        String mod = normalizeModule(module);
        String email = lookup(env, mod, role, slot, "email");
        String password = lookup(env, mod, role, slot, "password");

        validatePresent(email, password, env, mod, role, slot);
        logger.info("Using credentials for env={}, module={}, role={}, slot={} (email={})",
                env, mod == null ? "-" : mod, role, slot, maskEmail(email));
        return new UserCredentials(email, password, slot);
    }

    private String lookup(Environment env, String module, UserRole role, int slot, String field) {
        if (module != null) {
            for (String suffix : candidateSuffixes(role, slot, field)) {
                String value = configReader.getCryptoPropertyOrNull(cryptoKey(env, module, suffix));
                if (value != null) {
                    return value;
                }
            }
        }
        for (String suffix : candidateSuffixes(role, slot, field)) {
            String value = configReader.getCryptoPropertyOrNull(cryptoKey(env, null, suffix));
            if (value != null) {
                return value;
            }
        }
        return null;
    }

    private static List<String> candidateSuffixes(UserRole role, int slot, String field) {
        List<String> suffixes = new ArrayList<>();
        if (role == UserRole.CHIEF_ADMIN) {
            suffixes.add("cheif_admin_" + field);
        } else if (role == UserRole.APPROVER) {
            if (slot == 0) {
                suffixes.add("approver_" + field);
                suffixes.add("approver_user_0_" + field);
            } else {
                suffixes.add("approver_user_" + slot + "_" + field);
            }
        } else { 
            if (slot == 0) {
                suffixes.add("user_" + field);
                suffixes.add(field);
            } else {
                suffixes.add("user_" + slot + "_" + field);
            }
        }
        return suffixes;
    }

    private static String cryptoKey(Environment env, String module, String suffix) {
        String base = env.getValue() + "_";
        if (module != null) {
            base += module + "_";
        }
        return base + suffix;
    }

    private static String normalizeModule(String module) {
        if (module == null || module.isBlank()) {
            return null;
        }
        return module.trim().toLowerCase();
    }

    private static String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value.trim();
            }
        }
        return null;
    }

    private void validatePresent(String email, String password, Environment env, String module,
                                 UserRole role, int slot) {
        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            String hint = credentialPropertyHint(env, module, role, slot);
            throw new IllegalStateException(
                    "Missing credentials for env=" + env + ", module=" + (module == null ? "-" : module)
                            + ", role=" + role + ", slot=" + slot + ". "
                            + "Configure " + hint + " in src/main/resources/secrets/crypto.properties."
            );
        }
    }

    public static String credentialPropertyHint(Environment env, UserRole role, int slot) {
        return credentialPropertyHint(env, null, role, slot);
    }

    public static String credentialPropertyHint(Environment env, String module, UserRole role, int slot) {
        String mod = normalizeModule(module);
        String scoped = firstNonBlank(candidateSuffixes(role, slot, "email").toArray(new String[0]));
        String scopedPwd = firstNonBlank(candidateSuffixes(role, slot, "password").toArray(new String[0]));
        String moduleKey = cryptoKey(env, mod, scoped) + " / " + cryptoKey(env, mod, scopedPwd);
        if (mod == null) {
            return moduleKey;
        }
        String legacyKey = cryptoKey(env, null, scoped) + " / " + cryptoKey(env, null, scopedPwd);
        return moduleKey + " (or legacy " + legacyKey + ")";
    }

    private static String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 1) {
            return "***";
        }
        return email.charAt(0) + "***" + email.substring(at);
    }
}
