package enums;

public enum UserRole {
    CREATOR,
    APPROVER,
    CHIEF_ADMIN;

    public static UserRole fromString(String roleName) {
        String normalized = roleName == null ? "" : roleName.trim().toLowerCase();
        return switch (normalized) {
            case "creator" -> CREATOR;
            case "approver" -> APPROVER;
            case "chief-admin", "chief_admin", "chiefadmin" -> CHIEF_ADMIN;
            default -> throw new IllegalArgumentException(
                    "Unknown role '" + roleName + "'. Expected: creator | approver | chief-admin");
        };
    }
}
