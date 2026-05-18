package enums;


public enum Environment {
    DEV("dev"),
    UAT("uat"),
    STAG("stag"),
    PROD("prod");

    private final String value;

    Environment(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public static Environment fromString(String value) {
        for (Environment env : Environment.values()) {
            if (env.value.equalsIgnoreCase(value)) {
                return env;
            }
        }
        throw new IllegalArgumentException("Unknown environment: " + value);
    }
}