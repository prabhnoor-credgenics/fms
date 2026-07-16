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
            email = configReader.getProperty(envKey(env, "cheif_admin_email"));
            password = configReader.getProperty(envKey(env, "cheif_admin_password"));
        } else if (role == UserRole.APPROVER) {
            if (slot == 0) {
                email = firstNonBlank(
                        configReader.getProperty(envKey(env, "approver_email")),
                        configReader.getProperty(envKey(env, "approver_user_0_email"))
                );
                password = firstNonBlank(
                        configReader.getProperty(envKey(env, "approver_password")),
                        configReader.getProperty(envKey(env, "approver_user_0_password"))
                );
            } else {
                email = configReader.getProperty(envKey(env, "approver_user_" + slot + "_email"));
                password = configReader.getProperty(envKey(env, "approver_user_" + slot + "_password"));
            }
        } else {

            if (slot == 0) {

                email = firstNonBlank(
                        configReader.getProperty(envKey(env, "user_email")),
                        configReader.getProperty(envKey(env, "email"))
                );
                password = firstNonBlank(
                        configReader.getProperty(envKey(env, "user_password")),
                        configReader.getProperty(envKey(env, "password"))
                );
            } else {
                email = configReader.getProperty(envKey(env, "user_" + slot + "_email"));
                password = configReader.getProperty(envKey(env, "user_" + slot + "_password"));
            }
        }

        validatePresent(email, password, env, role, slot);
        logger.info("Using credentials for env={}, role={}, slot={} (email={})",
                env, role, slot, maskEmail(email));
        return new UserCredentials(email, password, slot);
    }

    private static String envKey(Environment env, String suffix) {
        return env.name().toLowerCase() + "_" + suffix;
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
            return envPrefix + "_cheif_admin_email / " + envPrefix + "_cheif_admin_password";
        }
        if (role == UserRole.APPROVER) {
            if (slot == 0) {
                return envPrefix + "_approver_email / " + envPrefix + "_approver_password "
                        + "(or " + envPrefix + "_approver_user_0_email)";
            }
            return envPrefix + "_approver_user_" + slot + "_email / " + envPrefix + "_approver_user_" + slot + "_password";
        }
        if (slot == 0) {
            return envPrefix + "_user_email / " + envPrefix + "_user_password "
                    + "(or " + envPrefix + "_email / " + envPrefix + "_password)";
        }
        return envPrefix + "_user_" + slot + "_email / " + envPrefix + "_user_" + slot + "_password";
    }

    private static String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 1) {
            return "***";
        }
        return email.charAt(0) + "***" + email.substring(at);
    }
}
