package auth.resolver;

import auth.model.UserCredentials;

import config.ConfigReader;
import enums.Environment;
import enums.UserRole;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;


public class UserCredentialsResolver {

    private static final Logger logger = LogManager.getLogger(UserCredentialsResolver.class);

    private final ConfigReader configReader;

    public UserCredentialsResolver(ConfigReader configReader) {
        this.configReader = configReader;
    }

    public UserCredentials resolve(Environment env, UserRole role, int slot) {
        String email;
        String password;

        if (role == UserRole.CHIEF_ADMIN) {
            email = configReader.getProperty(envKey(env, "cheif.admin.email"));
            password = configReader.getProperty(envKey(env, "cheif.admin.password"));
        } else if (role == UserRole.APPROVER) {
            if (slot == 0) {
                email = firstNonBlank(
                        configReader.getProperty(envKey(env, "approver.email")),
                        configReader.getProperty(envKey(env, "approver.user.0.email"))
                );
                password = firstNonBlank(
                        configReader.getProperty(envKey(env, "approver.password")),
                        configReader.getProperty(envKey(env, "approver.user.0.password"))
                );
            } else {
                email = configReader.getProperty(envKey(env, "approver.user." + slot + ".email"));
                password = configReader.getProperty(envKey(env, "approver.user." + slot + ".password"));
            }
        } else {

            if (slot == 0) {

                email = firstNonBlank(
                        configReader.getProperty(envKey(env, "user.email")),
                        configReader.getProperty(envKey(env, "email"))
                );
                password = firstNonBlank(
                        configReader.getProperty(envKey(env, "user.password")),
                        configReader.getProperty(envKey(env, "password"))
                );
            } else {
                email = configReader.getProperty(envKey(env, "user." + slot + ".email"));
                password = configReader.getProperty(envKey(env, "user." + slot + ".password"));
            }
        }

        validatePresent(email, password, env, role, slot);
        logger.info("Using credentials for env={}, role={}, slot={} (email={})",
                env, role, slot, maskEmail(email));
        return new UserCredentials(email, password, slot);
    }

    private static String envKey(Environment env, String suffix) {
        return env.name().toLowerCase() + "." + suffix;
    }

    private static String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value.trim();
            }
        }
        return null;
    }

    private void validatePresent(String email, String password, Environment env, UserRole role, int slot) {
        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            String hint = credentialPropertyHint(env, role, slot);
            String envFile = env.name().toLowerCase() + ".properties";
            throw new IllegalStateException(
                    "Missing credentials for env=" + env + ", role=" + role + ". "
                            + "Configure " + hint + " in src/main/resources/" + envFile + "."
            );
        }
    }

    public static String credentialPropertyHint(Environment env, UserRole role, int slot) {
        String envPrefix = env.name().toLowerCase();
        if (role == UserRole.CHIEF_ADMIN) {
            return envPrefix + ".cheif.admin.email / " + envPrefix + ".cheif.admin.password";
        }
        if (role == UserRole.APPROVER) {
            if (slot == 0) {
                return envPrefix + ".approver.email / " + envPrefix + ".approver.password "
                        + "(or " + envPrefix + ".approver.user.0.email)";
            }
            return envPrefix + ".approver.user." + slot + ".email / " + envPrefix + ".approver.user." + slot + ".password";
        }
        if (slot == 0) {
            return envPrefix + ".user.email / " + envPrefix + ".user.password "
                    + "(or " + envPrefix + ".email / " + envPrefix + ".password)";
        }
        return envPrefix + ".user." + slot + ".email / " + envPrefix + ".user." + slot + ".password";
    }

    private static String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 1) {
            return "***";
        }
        return email.charAt(0) + "***" + email.substring(at);
    }
}
