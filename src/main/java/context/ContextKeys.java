package context;


public final class ContextKeys {

    public static final String AUTH_TOKEN = "{AUTH_TOKEN}";
    public static final String COMPANY_ID = "{COMPANY_ID}";
    public static final String LOAN_ID = "{LOAN_ID}";
    public static final String ALLOCATION_MONTH = "{ALLOCATION_MONTH}";
    public static final String UUID = "{UUID}";
    public static final String EMAIL = "{EMAIL}";
    public static final String TIMESTAMP = "{TIMESTAMP}";
    public static final String RANDOM_NAME = "{RANDOM_NAME}";
    public static final String VARIABLE_ID = "{VARIABLE_ID}";

    private ContextKeys() {
        throw new UnsupportedOperationException("Constants class");
    }
}
