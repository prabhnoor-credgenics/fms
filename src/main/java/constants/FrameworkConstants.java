package constants;


public class FrameworkConstants {
    
    
    public static final int HTTP_OK = 200;
    public static final int HTTP_CREATED = 201;
    public static final int HTTP_NO_CONTENT = 204;
    public static final int HTTP_BAD_REQUEST = 400;
    public static final int HTTP_UNAUTHORIZED = 401;
    public static final int HTTP_FORBIDDEN = 403;
    public static final int HTTP_NOT_FOUND = 404;
    public static final int HTTP_INTERNAL_SERVER_ERROR = 500;

    
    public static final String CONTENT_TYPE_JSON = "application/json";
    public static final String CONTENT_TYPE_XML = "application/xml";
    public static final String CONTENT_TYPE_FORM_URLENCODED = "application/x-www-form-urlencoded";
    public static final String CONTENT_TYPE_TEXT_PLAIN = "text/plain";

    
    public static final String HEADER_AUTHORIZATION = "Authorization";
    public static final String HEADER_CONTENT_TYPE = "Content-Type";
    public static final String HEADER_ACCEPT = "Accept";
    public static final String HEADER_USER_AGENT = "User-Agent";

    
    public static final String AUTH_BEARER = "Bearer";
    public static final String AUTH_BASIC = "Basic";

    
    public static final String DATE_FORMAT_ISO = "yyyy-MM-dd'T'HH:mm:ss";
    public static final String DATE_FORMAT_STANDARD = "yyyy-MM-dd HH:mm:ss";
    public static final String DATE_FORMAT_DATE_ONLY = "yyyy-MM-dd";

    
    public static final String TEST_DATA_PATH = "test-data";
    public static final String JSON_SCHEMAS_PATH = "schemas";

    
    public static final String ENDPOINT_USER_COMPANY = "/user/company";
    public static final String ENDPOINT_RECOVERY_COMPANY = "/recovery/company";
    public static final String ENDPOINT_GLOBAL_STATUS = "/recovery/global-status";
    public static final String ENDPOINT_RECOVERY_VARIABLES = "/recovery/variables";

    public static final String SCHEMA_GLOBAL_STATUS_SUCCESS = "schemas/global_status_success_schema.json";
    public static final String SCHEMA_GLOBAL_STATUS_ERROR = "schemas/global_status_error_schema.json";
    public static final String SCHEMA_RECOVERY_VARIABLES_SUCCESS = "schemas/recovery_variables_success_schema.json";
    public static final String SCHEMA_RECOVERY_VARIABLES_ERROR = "schemas/recovery_variables_error_schema.json";

    
    public static final String COMPANY_STEP1_TEMPLATE = "test-data/company_creation_step1.json";
    public static final String COMPANY_STEP2_TEMPLATE = "test-data/company_creation_step2.json";
    public static final String COMPANY_STEP3_TEMPLATE = "test-data/company_creation_step3.json";

    
    public static final String SCHEMA_COMPANY_STEP1_SUCCESS = "schemas/company_creation_step1_success_schema.json";
    public static final String SCHEMA_COMPANY_STEP2_SUCCESS = "schemas/company_creation_step2_success_schema.json";
    public static final String SCHEMA_COMPANY_STEP3_SUCCESS = "schemas/company_creation_step3_success_schema.json";
    public static final String SCHEMA_COMPANY_STEP4_SUCCESS = "schemas/company_creation_step4_success_schema.json";
    public static final String SCHEMA_COMPANY_GET_SUCCESS = "schemas/company_creation_get_success_schema.json";
    public static final String SCHEMA_COMPANY_STEP1_REQUEST = "schemas/company_creation_step1_request_schema.json";
    public static final String SCHEMA_COMPANY_STEP2_REQUEST = "schemas/company_creation_step2_request_schema.json";
    public static final String SCHEMA_COMPANY_STEP3_REQUEST = "schemas/company_creation_step3_request_schema.json";
    public static final String SCHEMA_COMPANY_STEP4_REQUEST = "schemas/company_creation_step4_request_schema.json";
    public static final String SCHEMA_COMPANY_ERROR = "schemas/company_creation_error_schema.json";

    
    public static final String PROP_ENVIRONMENT = "environment";
    public static final String PROP_AUTH_TOKEN = "auth.token";
    public static final String PROP_BASE_URL = ".base.url";

    
    public static final String LOG_REQUEST_SENT = "Request sent successfully";
    public static final String LOG_RESPONSE_RECEIVED = "Response received";
    public static final String LOG_VALIDATION_PASSED = "Validation passed";
    public static final String LOG_VALIDATION_FAILED = "Validation failed";

    private FrameworkConstants() {

        throw new UnsupportedOperationException("Cannot instantiate constants class");
    }
}