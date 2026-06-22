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
}