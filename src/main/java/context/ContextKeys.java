package context;

public final class ContextKeys {

    public static final String AUTH_TOKEN = "{AUTH_TOKEN}";
    public static final String COMPANY_ID = "{COMPANY_ID}";
    public static final String LOAN_ID = "{LOAN_ID}";
    public static final String VARIABLE_NAME = "{VARIABLE_NAME}";
    public static final String ALLOCATION_MONTH = "{ALLOCATION_MONTH}";
    public static final String UUID = "{UUID}";
    public static final String EMAIL = "{EMAIL}";
    public static final String TIMESTAMP = "{TIMESTAMP}";
    public static final String RANDOM_NAME = "{RANDOM_NAME}";
    public static final String VARIABLE_ID = "{VARIABLE_ID}";
    public static final String MAPPING_ID  = "{MAPPING_ID}";
    public static final String CREATOR_USER_ID = "{CREATOR_USER_ID}";
    public static final String USER_NAME = "{USER_NAME}";
    public static final String USER_EMAIL = "{USER_EMAIL}";
    public static final String USER_MOBILE = "{USER_MOBILE}";
    public static final String CLIENT_ID = "{CLIENT_ID}";
    public static final String CLIENT_SECRET = "{CLIENT_SECRET}";

    public static final String FMS_USER_ID = "{FMS_USER_ID}";
    public static final String FMS_API_KEY = "{FMS_API_KEY}";
    public static final String FMS_IMEI = "{FMS_IMEI}";
    public static final String FMS_APP_VERSION = "{FMS_APP_VERSION}";
    public static final String FMS_TOKEN_V2 = "{FMS_TOKEN_V2}";

    public static final String AUTH_TOKEN_FOR_PREFIX = "{AUTH_TOKEN:";
    public static final String COMPANY_ID_FOR_PREFIX = "{COMPANY_ID:";
    public static final String USER_ID_FOR_PREFIX = "{USER_ID:";
    public static final String USER_NAME_FOR_PREFIX = "{USER_NAME:";
    public static final String USER_EMAIL_FOR_PREFIX = "{USER_EMAIL:";
    public static final String USER_MOBILE_FOR_PREFIX = "{USER_MOBILE:";
    public static final String FMS_USER_ID_FOR_PREFIX = "{FMS_USER_ID:";
    public static final String FMS_API_KEY_FOR_PREFIX = "{FMS_API_KEY:";

    /** Capture keys populated from verify/user during Before-hook auth. */
    public static final String CAPTURE_KEY_USER_NAME = "user_name";
    public static final String CAPTURE_KEY_USER_EMAIL = "user_email";
    public static final String CAPTURE_KEY_USER_MOBILE = "user_mobile";

    public static final String NOW_PREFIX = "{NOW:";
    public static final String NOW_OFFSET_PREFIX = "{NOW_OFFSET:";
    public static final String CAPTURED_TIME_PREFIX = "{CAPTURED_TIME:";
    public static final String CAPTURED_PREFIX = "{CAPTURED:";

    private ContextKeys() {
        throw new UnsupportedOperationException("Constants class");
    }
}
