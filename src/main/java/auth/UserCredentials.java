package auth;

/**
 * Email/password pair for a single parallel user slot.
 */
public record UserCredentials(String email, String password, int slot) {}
