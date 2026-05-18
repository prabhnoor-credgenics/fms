package constants;

/**
 * Framework constants for common values
 */
public class FrameworkConstants {
    
    // HTTP Status Codes
    public static final int HTTP_OK = 200;
    public static final int HTTP_CREATED = 201;
    public static final int HTTP_NO_CONTENT = 204;
    public static final int HTTP_BAD_REQUEST = 400;
    public static final int HTTP_UNAUTHORIZED = 401;
    public static final int HTTP_FORBIDDEN = 403;
    public static final int HTTP_NOT_FOUND = 404;
    public static final int HTTP_INTERNAL_SERVER_ERROR = 500;

    // Content Types
    public static final String CONTENT_TYPE_JSON = "application/json";
    public static final String CONTENT_TYPE_XML = "application/xml";
    public static final String CONTENT_TYPE_FORM_URLENCODED = "application/x-www-form-urlencoded";
    public static final String CONTENT_TYPE_TEXT_PLAIN = "text/plain";

    // Common Headers
    public static final String HEADER_AUTHORIZATION = "Authorization";
    public static final String HEADER_CONTENT_TYPE = "Content-Type";
    public static final String HEADER_ACCEPT = "Accept";
    public static final String HEADER_USER_AGENT = "User-Agent";

    // Authentication Types
    public static final String AUTH_BEARER = "Bearer";
    public static final String AUTH_BASIC = "Basic";

    // Date/Time Formats
    public static final String DATE_FORMAT_ISO = "yyyy-MM-dd'T'HH:mm:ss";
    public static final String DATE_FORMAT_STANDARD = "yyyy-MM-dd HH:mm:ss";
    public static final String DATE_FORMAT_DATE_ONLY = "yyyy-MM-dd";

    // Test Data Paths
    public static final String TEST_DATA_PATH = "test-data";
    public static final String JSON_SCHEMAS_PATH = "schemas";

    // Property Keys
    public static final String PROP_ENVIRONMENT = "environment";
    public static final String PROP_AUTH_TOKEN = "auth.token";
    public static final String PROP_BASE_URL = ".base.url";

    // Log Messages
    public static final String LOG_REQUEST_SENT = "Request sent successfully";
    public static final String LOG_RESPONSE_RECEIVED = "Response received";
    public static final String LOG_VALIDATION_PASSED = "Validation passed";
    public static final String LOG_VALIDATION_FAILED = "Validation failed";

    private FrameworkConstants() {

        throw new UnsupportedOperationException("Cannot instantiate constants class");
    }
}