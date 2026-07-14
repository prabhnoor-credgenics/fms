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
    public static final String MAPPING_ID  = "{MAPPING_ID}";
    public static final String CREATOR_USER_ID = "{CREATOR_USER_ID}";
    public static final String CLIENT_ID = "{CLIENT_ID}";
    public static final String CLIENT_SECRET = "{CLIENT_SECRET}";


    public static final String AUTH_TOKEN_FOR_PREFIX = "{AUTH_TOKEN:";
    public static final String COMPANY_ID_FOR_PREFIX = "{COMPANY_ID:";
    public static final String USER_ID_FOR_PREFIX = "{USER_ID:";

    public static final String NOW_PREFIX = "{NOW:";
    public static final String CAPTURED_TIME_PREFIX = "{CAPTURED_TIME:";

    private ContextKeys() {
        throw new UnsupportedOperationException("Constants class");
    }
}
