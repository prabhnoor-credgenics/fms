package auth.resolver;

import auth.model.UserCredentials;

import config.ConfigReader;
import enums.Environment;
import enums.UserRole;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.ArrayList;
import java.util.List;


/**
 * Resolves the email/password for a login from {@code secrets/crypto.properties}.
 *
 * <p>Credentials are keyed by {@code (env, module, role, slot)}. The optional <b>module</b>
 * (a.k.a. product line — e.g. {@code lending}, {@code creditline}, {@code notice}) is a free-form
 * segment placed right after the env prefix: {@code <env>_<module>_<suffix>}. Resolution tries the
 * module-scoped key first, then falls back to the legacy non-scoped key {@code <env>_<suffix>} so
 * accounts that are not module-specific (e.g. a shared chief-admin) keep working.
 *
 * <p>All credential values live in {@code secrets/crypto.properties} (never the plain env
 * {@code *.properties} files) so they can later be sourced from a secrets manager.
 */
public class UserCredentialsResolver {

    private static final Logger logger = LogManager.getLogger(UserCredentialsResolver.class);

    private final ConfigReader configReader;

    public UserCredentialsResolver(ConfigReader configReader) {
        this.configReader = configReader;
    }

    /** Module-less entry point (legacy callers); resolves with no module scope. */
    public UserCredentials resolve(Environment env, UserRole role, int slot) {
        return resolve(env, null, role, slot);
    }

    /**
     * Resolves credentials for {@code (env, module, role, slot)}. A blank/null {@code module}
     * skips the module-scoped lookup and uses only the legacy non-scoped keys.
     */
    public UserCredentials resolve(Environment env, String module, UserRole role, int slot) {
        String mod = normalizeModule(module);
        String email = lookup(env, mod, role, slot, "email");
        String password = lookup(env, mod, role, slot, "password");

        validatePresent(email, password, env, mod, role, slot);
        logger.info("Using credentials for env={}, module={}, role={}, slot={} (email={})",
                env, mod == null ? "-" : mod, role, slot, maskEmail(email));
        return new UserCredentials(email, password, slot);
    }

    /**
     * Probes candidate crypto keys for a field ({@code email}/{@code password}): module-scoped
     * keys first (if a module is given), then the legacy non-scoped keys.
     */
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

    /**
     * Candidate key suffixes for a role/slot, in preference order. {@code field} is
     * {@code email} or {@code password}.
     */
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
        } else { // CREATOR
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

    /** Trim + lowercase; null/blank collapses to {@code null} (no module scope). */
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
