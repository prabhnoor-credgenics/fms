package stepdefinitions;

import static io.restassured.RestAssured.given;
import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchema;
import static org.hamcrest.Matchers.equalTo;

import java.io.File;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.Assert;

import auth.manager.AuthManager;
import base.RestAssuredBase;
import config.ConfigReader;
import context.ContextKeys;
import context.ScenarioTestDataResolver;
import context.TestContext;
import enums.HttpMethod;
import helpers.AssertionHelper;
import helpers.FileHelper;
import helpers.JsonHelper;
import helpers.LoggingHelper;
import helpers.PayloadHelper;
import helpers.ResponseHelper;
import helpers.SchemaHelper;
import helpers.ValueExpressionHelper;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.http.ContentType;
import io.restassured.http.Header;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import utils.JsonUtils;
import utils.ResponseValidator;

public class ApiStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ApiStepDefinitions.class);

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final RestAssuredBase restAssuredBase;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final AuthManager authManager;

    private RequestSpecification request;
    private Response response;
    private final Set<String> headersToRemove = new HashSet<>();
    private final LinkedHashMap<String, String> storedHeaders = new LinkedHashMap<>();
    private final Map<String, String> storedPathParams = new HashMap<>();
    private final Map<String, String> storedQueryParams = new HashMap<>();
    private final List<MultipartFilePart> multipartFiles = new ArrayList<>();
    private final List<MultipartTextPart> multipartFields = new ArrayList<>();
    private File binaryBodyFile;
    private String binaryBodyContentType;

    private record MultipartFilePart(String controlName, File file, String mimeType) {}

    private record MultipartTextPart(String controlName, String value) {}

    public ApiStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            RestAssuredBase restAssuredBase,
            ScenarioTestDataResolver scenarioTestDataResolver,
            AuthManager authManager
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.restAssuredBase = restAssuredBase;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.authManager = authManager;
    }

    @When("I wait for {int} seconds")
    public void i_wait_for_seconds(int seconds) {
        try {
            Thread.sleep(seconds * 1000L);
            logger.info("Waited for {} seconds", seconds);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    @When("I poll a {string} request to {string} until the response body contains {string}")
    public void i_poll_until_body_contains(String httpMethod, String endpoint, String expected) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(expected);
        int maxAttempts = 3;
        int delaySeconds = 5;
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            i_send_a_request_to(httpMethod, endpoint);
            if (activeResponse().getBody().asString().contains(resolved)) {
                logger.info("Poll matched: body contains '{}' on attempt {}/{}", resolved, attempt, maxAttempts);
                return;
            }
            logger.info("Poll attempt {}/{}: '{}' not present yet", attempt, maxAttempts, resolved);
            if (attempt < maxAttempts) {
                i_wait_for_seconds(delaySeconds);
            }
        }
        logger.warn("Poll exhausted: '{}' never appeared after {} attempts", resolved, maxAttempts);
    }

    @When("I poll a {string} request to {string} until the response body does not contain {string}")
    public void i_poll_until_body_not_contains(String httpMethod, String endpoint, String unexpected) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(unexpected);
        int maxAttempts = 3;
        int delaySeconds = 5;
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            i_send_a_request_to(httpMethod, endpoint);
            if (!activeResponse().getBody().asString().contains(resolved)) {
                logger.info("Poll matched: body no longer contains '{}' on attempt {}/{}", resolved, attempt, maxAttempts);
                return;
            }
            logger.info("Poll attempt {}/{}: '{}' still present", attempt, maxAttempts, resolved);
            if (attempt < maxAttempts) {
                i_wait_for_seconds(delaySeconds);
            }
        }
        logger.warn("Poll exhausted: '{}' still present after {} attempts", resolved, maxAttempts);
    }

    @When("I poll a {string} request to {string} until the response body contains field {string} as {string} with value {string}")
    public void i_poll_until_body_contains_field_as_type_with_value(
            String httpMethod, String endpoint, String jsonPath, String type, String expectedValue) {
        String resolvedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(jsonPath);
        String resolvedType = scenarioTestDataResolver.replaceScenarioPlaceholders(type);
        String resolvedValue = scenarioTestDataResolver.replaceScenarioPlaceholders(expectedValue);
        int maxAttempts = 3;
        int delaySeconds = 5;
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            i_send_a_request_to(httpMethod, endpoint);
            if (ResponseValidator.matchesJsonFieldTyped(
                    activeResponse(), resolvedPath, resolvedType, resolvedValue)) {
                logger.info(
                        "Poll matched: field '{}' equals '{}' on attempt {}/{}",
                        resolvedPath, resolvedValue, attempt, maxAttempts);
                return;
            }
            logger.info(
                    "Poll attempt {}/{}: field '{}' != '{}' yet",
                    attempt, maxAttempts, resolvedPath, resolvedValue);
            if (attempt < maxAttempts) {
                i_wait_for_seconds(delaySeconds);
            }
        }
        logger.warn(
                "Poll exhausted: field '{}' never matched '{}' after {} attempts",
                resolvedPath, resolvedValue, maxAttempts);
    }

    @Given("I prepare a request")
    public void i_prepare_a_request() {
        request = restAssuredBase.getRequestSpec();
        storedHeaders.clear();
        storedQueryParams.clear();
        storedPathParams.clear();
        multipartFiles.clear();
        multipartFields.clear();
        clearBinaryBody();
        clearRequestBody();
        headersToRemove.clear();
        logger.info("Request specification prepared");
    }

    @Given("I set the request headers:")
    public void i_set_the_request_headers(DataTable dataTable) {
        ensureRequestPrepared();
        for (ParamRow row : parseParamRows(dataTable)) {
            String headerName = row.name();
            String headerNameLower = headerName.toLowerCase();

            if (headersToRemove.contains(headerNameLower)) {
                logger.info("Skipping header '{}' as it is marked for removal", headerName);
                continue;
            }

            String value = row.rawValue();
            if ("authenticationtoken".equals(headerNameLower) && ContextKeys.AUTH_TOKEN.equals(value)) {
                value = testContext.getAuthToken();
                logger.info("Using authenticationtoken from TestContext");
            } else if ("x-company-id".equals(headerNameLower) && ContextKeys.COMPANY_ID.equals(value)) {
                value = scenarioTestDataResolver.resolveCompanyId();
                logger.info("Using x-company-id from resolved company id");
            } else {
                value = scenarioTestDataResolver.replaceScenarioPlaceholders(value);
            }
            if (!"Referer".equals(headerName)) {
                storedHeaders.put(headerName, value);
                request.header(headerName, value);
                rememberTableValue(row.rememberAs(), value);
                logger.info("Added header: {} = {}", headerName, value);
            }
        }
    }

    private void ensureRequestPrepared() {
        if (request == null) {
            request = restAssuredBase.getRequestSpec();
            logger.info("Request specification auto-prepared");
        }
    }

    private String currentRequestBody() {
        return testContext.getRequestBody();
    }

    private void applyRequestBody(String body) {
        clearBinaryBody();
        testContext.setRequestBody(body);
        if (request != null && body != null) {
            request.body(body);
        }
    }

    private void clearRequestBody() {
        testContext.setRequestBody(null);
    }

    @Given("I set the request body:")
    public void i_set_the_request_body(String body) {
        ensureRequestPrepared();
        String processedBody = replacePlaceholdersInBody(body);
        applyRequestBody(processedBody);
        logger.info("Request body set: {}", processedBody);
    }

    @Given("I set the request body from file {string}")
    public void i_set_the_request_body_from_file(String filePath) {
        ensureRequestPrepared();
        String jsonBody = FileHelper.readResourceAsString(filePath);
        String processedBody = replacePlaceholdersInBody(jsonBody);
        SchemaHelper.autoValidateRequestSchema(filePath, processedBody);
        applyRequestBody(processedBody);
        logger.info("Request body loaded from file '{}' and placeholders replaced", filePath);
    }

    @Given("I attach file {string} as {string}")
    public void i_attach_file_as(String filePath, String controlName) {
        ensureRequestPrepared();
        String resolvedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(filePath);
        String resolvedControlName = scenarioTestDataResolver.replaceScenarioPlaceholders(controlName);
        if (resolvedControlName == null || resolvedControlName.isBlank()) {
            throw new IllegalArgumentException("Multipart control name must not be blank");
        }
        File file = FileHelper.resolveTestFile(resolvedPath);
        String mimeType = FileHelper.guessMimeType(file);
        multipartFiles.add(new MultipartFilePart(resolvedControlName, file, mimeType));
        logger.info("Attached file '{}' as multipart field '{}' (mimeType={}, size={} bytes)",
                file.getPath(), resolvedControlName, mimeType, file.length());
    }

    @Given("I attach file {string} as {string} with content type {string}")
    public void i_attach_file_as_with_content_type(String filePath, String controlName, String contentType) {
        ensureRequestPrepared();
        String resolvedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(filePath);
        String resolvedControlName = scenarioTestDataResolver.replaceScenarioPlaceholders(controlName);
        String resolvedContentType = scenarioTestDataResolver.replaceScenarioPlaceholders(contentType);
        if (resolvedControlName == null || resolvedControlName.isBlank()) {
            throw new IllegalArgumentException("Multipart control name must not be blank");
        }
        if (resolvedContentType == null || resolvedContentType.isBlank()) {
            throw new IllegalArgumentException("Multipart content type must not be blank");
        }
        File file = FileHelper.resolveTestFile(resolvedPath);
        multipartFiles.add(new MultipartFilePart(resolvedControlName, file, resolvedContentType));
        logger.info("Attached file '{}' as multipart field '{}' (mimeType={}, size={} bytes)",
                file.getPath(), resolvedControlName, resolvedContentType, file.length());
    }

    @Given("I set the multipart form fields:")
    public void i_set_the_multipart_form_fields(Map<String, String> fields) {
        ensureRequestPrepared();
        for (Map.Entry<String, String> field : fields.entrySet()) {
            String name = field.getKey();
            if (name == null || name.isBlank()) {
                throw new IllegalArgumentException("Multipart form field name must not be blank");
            }
            String value = scenarioTestDataResolver.replaceScenarioPlaceholders(field.getValue());
            multipartFields.add(new MultipartTextPart(name, value == null ? "" : value));
            logger.info("Added multipart form field: {} = {}", name, value);
        }
    }

    @Given("I set the request body from binary file {string}")
    public void i_set_the_request_body_from_binary_file(String filePath) {
        ensureRequestPrepared();
        String resolvedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(filePath);
        File file = FileHelper.resolveTestFile(resolvedPath);
        binaryBodyFile = file;
        binaryBodyContentType = FileHelper.guessMimeType(file);
        clearRequestBody();
        logger.info("Binary request body set from '{}' (mimeType={}, size={} bytes)",
                file.getPath(), binaryBodyContentType, file.length());
    }

    @Given("I set the request body from binary file {string} with content type {string}")
    public void i_set_the_request_body_from_binary_file_with_content_type(String filePath, String contentType) {
        ensureRequestPrepared();
        String resolvedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(filePath);
        String resolvedContentType = scenarioTestDataResolver.replaceScenarioPlaceholders(contentType);
        if (resolvedContentType == null || resolvedContentType.isBlank()) {
            throw new IllegalArgumentException("Binary body content type must not be blank");
        }
        File file = FileHelper.resolveTestFile(resolvedPath);
        binaryBodyFile = file;
        binaryBodyContentType = resolvedContentType;
        clearRequestBody();
        logger.info("Binary request body set from '{}' (mimeType={}, size={} bytes)",
                file.getPath(), binaryBodyContentType, file.length());
    }

    @Given("I set the query parameters:")
    public void i_set_the_query_parameters(DataTable dataTable) {
        ensureRequestPrepared();
        for (ParamRow row : parseParamRows(dataTable)) {
            String value = resolveQueryParamValue(row.name(), row.rawValue());
            storedQueryParams.put(row.name(), value);
            request.queryParam(row.name(), value);
            rememberTableValue(row.rememberAs(), value);
            logger.info("Added query parameter: {} = {}", row.name(), value);
        }
    }

    @Given("I set the path parameters:")
    public void i_set_the_path_parameters(DataTable dataTable) {
        ensureRequestPrepared();
        for (ParamRow row : parseParamRows(dataTable)) {
            String value = resolvePathParamValue(row.name(), row.rawValue());
            storedPathParams.put(row.name(), value);
            request.pathParam(row.name(), value);
            rememberTableValue(row.rememberAs(), value);
            logger.info("Added path parameter: {} = {}", row.name(), value);
        }
    }

@Given("I update JSON field {string} as {string} to {string}")
public void i_update_json_field_as_type_to(
        String jsonPath,
        String type,
        String value) {

    updateJsonFieldTypedInternal(jsonPath, type, value, null);
}

@Given("I update JSON field {string} as {string} to {string} and remember as {string}")
public void i_update_json_field_as_type_to_and_remember_as(
        String jsonPath,
        String type,
        String value,
        String rememberAs) {

    updateJsonFieldTypedInternal(jsonPath, type, value, rememberAs);
}

    @Given("I update JSON field {string} as {string} to:")
    public void i_update_json_field_as_type_to_docstring(String jsonPath, String type, String docString) {
        updateJsonFieldTypedInternal(jsonPath, type, docString, null);
    }

    @Given("I update JSON field {string} from captured {string}")
    public void i_update_json_field_from_captured(String jsonPath, String key) {
        String existingBody = currentRequestBody();
        if (existingBody == null || existingBody.isEmpty()) {
            throw new IllegalStateException(
                    "Request body must be set before updating JSON field from captured value.");
        }
        if (!testContext.hasCapturedPath(key)) {
            throw new IllegalStateException(
                    "Nothing captured at '" + key + "'. Store/capture a root key first "
                            + "(use mapKey.field or listKey[0] for nested access).");
        }
        Object value = testContext.getCapturedObject(key);
        String processedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(jsonPath);
        applyRequestBody(JsonHelper.updateField(existingBody, processedPath, value));
        logger.info("Updated JSON field '{}' from captured '{}' ({}) [thread={}]",
                processedPath, key,
                value == null ? "null" : value.getClass().getSimpleName(),
                Thread.currentThread().getName());
    }

    @When("I send a {string} request to {string}")
public void i_send_a_request_to(String httpMethod, String endpoint) {

    HttpMethod method = HttpMethod.valueOf(httpMethod.toUpperCase());

    rebuildRequestIfHeadersRemoved();

    String referer = applyRefererHeader(endpoint);

    String resolvedEndpoint = LoggingHelper.resolveEndpointWithPathParams(
            endpoint,
            storedPathParams.isEmpty() ? null : storedPathParams
    );

    String fullUrl = configReader.getBaseUrl() + resolvedEndpoint;

    LoggingHelper.logRequestDetails(
            method.name(),
            configReader.getBaseUrl(),
            resolvedEndpoint,
            headersForLogging(referer),
            storedQueryParams.isEmpty() ? null : new LinkedHashMap<>(storedQueryParams),
            currentRequestBody()
    );

    String bodyForSend = currentRequestBody();
    boolean multipart = hasMultipartParts();
    boolean binary = hasBinaryBody();
    if (multipart) {
        // RestAssured accumulates multiPart() calls, so rebuild from stored state first.
        rebuildRequestFromStoredState(null);
        if (bodyForSend != null && !bodyForSend.isBlank()) {
            logger.warn("Multipart parts are present; JSON/text request body will be ignored for this request.");
        }
        testContext.setLastRequestBody(summarizeMultipartForLogging());
    } else if (binary) {
        rebuildRequestFromStoredState(null);
        if (binaryBodyContentType != null && !binaryBodyContentType.isBlank()) {
            request.contentType(binaryBodyContentType);
        }
        request.body(binaryBodyFile);
        testContext.setLastRequestBody("binary-file=" + binaryBodyFile.getPath()
                + " (" + binaryBodyContentType + ", " + binaryBodyFile.length() + " bytes)");
    } else if (bodyForSend != null && !bodyForSend.isBlank()) {
        request.body(bodyForSend);
        testContext.setLastRequestBody(bodyForSend);
    }

    logger.info("Sending {} request to endpoint: {}", method, endpoint);

    DateTimeFormatter formatter =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

    LocalDateTime requestTime = LocalDateTime.now();
    long startTime = System.currentTimeMillis();

    StringBuilder apiLogs = new StringBuilder();

    apiLogs.append("========== REQUEST ==========\n");

    apiLogs.append("REQUEST TIME: ")
            .append(requestTime.format(formatter))
            .append("\n");

    apiLogs.append("METHOD: ")
            .append(method)
            .append("\n");

    apiLogs.append("URL: ")
            .append(fullUrl)
            .append("\n\n");

    apiLogs.append("PATH PARAMETERS:\n");

    if (storedPathParams.isEmpty()) {
        apiLogs.append("None\n");
    } else {
        for (Map.Entry<String, String> entry : storedPathParams.entrySet()) {
            apiLogs.append(entry.getKey())
                    .append(": ")
                    .append(entry.getValue())
                    .append("\n");
        }
    }

    apiLogs.append("\nQUERY PARAMETERS:\n");

    if (storedQueryParams.isEmpty()) {
        apiLogs.append("None\n");
    } else {
        for (Map.Entry<String, String> entry : storedQueryParams.entrySet()) {
            apiLogs.append(entry.getKey())
                    .append(": ")
                    .append(entry.getValue())
                    .append("\n");
        }
    }

    apiLogs.append("\nHEADERS:\n");
    apiLogs.append("Referer: ")
            .append(fullUrl)
            .append("\n");

    if (multipart) {
        apiLogs.append("\nMULTIPART PARTS:\n");
        apiLogs.append(summarizeMultipartForLogging()).append("\n");
    } else if (bodyForSend != null && !bodyForSend.isEmpty()) {
        apiLogs.append("\nREQUEST BODY:\n");
        apiLogs.append(bodyForSend).append("\n");
    }

    switch (method) {

        case GET:
            response = request.get(endpoint);
            break;

        case POST:
            response = request.post(endpoint);
            break;

        case PUT:
            response = request.put(endpoint);
            break;

        case PATCH:
            response = request.patch(endpoint);
            break;

        case DELETE:
            response = request.delete(endpoint);
            break;

        default:
            throw new IllegalArgumentException("Unsupported HTTP method: " + method);
    }

    if (response.getStatusCode() == 401 && testContext.getUserRole() != null && usedRealAuthToken()) {
        logger.warn("Got 401 for '{}' - session expired. Re-authenticating and retrying once.", endpoint);
        authManager.reAuthenticate(testContext.getUserRole());
        rebuildRequestWithFreshAuth();
        applyRefererHeader(endpoint);
        response = executeHttp(method, endpoint);
        logger.info("Retry response status: {}", response.getStatusCode());
    }

    LocalDateTime responseTime = LocalDateTime.now();
    long endTime = System.currentTimeMillis();
    long duration = endTime - startTime;

    logger.info("Response received with status code: {}", response.getStatusCode());

    apiLogs.append("\n========== RESPONSE ==========\n");

    apiLogs.append("RESPONSE TIME: ")
            .append(responseTime.format(formatter))
            .append("\n");

    apiLogs.append("DURATION: ")
            .append(duration)
            .append(" ms\n");

    apiLogs.append("STATUS CODE: ")
            .append(response.getStatusCode())
            .append("\n");

    apiLogs.append("\nRESPONSE HEADERS:\n");

    for (Header header : response.getHeaders()) {
        apiLogs.append(header.getName())
                .append(": ")
                .append(header.getValue())
                .append("\n");
    }

    apiLogs.append("\nRESPONSE BODY:\n");
    apiLogs.append(response.getBody().asPrettyString());

    testContext.setApiLogs(apiLogs.toString());

    autoValidateResponseSchema(httpMethod, endpoint, response.getStatusCode());

    testContext.setResponse(response);

    logResponseDetails(response);
}

    @When("I send a {string} request to absolute url {string}")
    public void i_send_a_request_to_absolute_url(String httpMethod, String absoluteUrl) {
        HttpMethod method = HttpMethod.valueOf(httpMethod.toUpperCase());
        String resolvedUrl = scenarioTestDataResolver.replaceScenarioPlaceholders(absoluteUrl);
        if (resolvedUrl != null) {
            resolvedUrl = resolvedUrl.trim();
        }
        if (resolvedUrl == null || resolvedUrl.isBlank()) {
            throw new IllegalArgumentException("Absolute URL must not be blank");
        }
        if (!resolvedUrl.startsWith("http://") && !resolvedUrl.startsWith("https://")) {
            throw new IllegalArgumentException(
                    "Absolute URL must start with http:// or https://. Got: " + resolvedUrl);
        }

        RequestSpecification absoluteRequest = given();
        applyHeadersAndQueryParamsToAbsoluteRequest(absoluteRequest);
        String bodySummary = applyPayloadToAbsoluteRequest(absoluteRequest);

        logger.info("Sending {} request to absolute url (no framework baseUri/auto-Referer)", method);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
        LocalDateTime requestTime = LocalDateTime.now();
        long startTime = System.currentTimeMillis();

        StringBuilder apiLogs = new StringBuilder();
        apiLogs.append("========== ABSOLUTE REQUEST ==========\n");
        apiLogs.append("REQUEST TIME: ").append(requestTime.format(formatter)).append('\n');
        apiLogs.append("METHOD: ").append(method).append('\n');
        apiLogs.append("URL: ").append(resolvedUrl).append("\n\n");

        apiLogs.append("QUERY PARAMETERS:\n");
        if (storedQueryParams.isEmpty()) {
            apiLogs.append("None\n");
        } else {
            for (Map.Entry<String, String> entry : storedQueryParams.entrySet()) {
                apiLogs.append(entry.getKey()).append(": ").append(entry.getValue()).append('\n');
            }
        }

        apiLogs.append("\nHEADERS:\n");
        if (storedHeaders.isEmpty()) {
            apiLogs.append("None\n");
        } else {
            for (Map.Entry<String, String> entry : storedHeaders.entrySet()) {
                apiLogs.append(entry.getKey()).append(": ").append(entry.getValue()).append('\n');
            }
        }

        if (bodySummary != null && !bodySummary.isBlank()) {
            apiLogs.append("\nPAYLOAD:\n").append(bodySummary).append('\n');
        }

        response = executeHttp(absoluteRequest, method, resolvedUrl);

        LocalDateTime responseTime = LocalDateTime.now();
        long duration = System.currentTimeMillis() - startTime;
        logger.info("Absolute URL response status: {}", response.getStatusCode());

        apiLogs.append("\n========== RESPONSE ==========\n");
        apiLogs.append("RESPONSE TIME: ").append(responseTime.format(formatter)).append('\n');
        apiLogs.append("DURATION: ").append(duration).append(" ms\n");
        apiLogs.append("STATUS CODE: ").append(response.getStatusCode()).append('\n');
        apiLogs.append("\nRESPONSE HEADERS:\n");
        for (Header header : response.getHeaders()) {
            apiLogs.append(header.getName()).append(": ").append(header.getValue()).append('\n');
        }
        apiLogs.append("\nRESPONSE BODY:\n");
        apiLogs.append(response.getBody().asPrettyString());

        testContext.setApiLogs(apiLogs.toString());
        testContext.setResponse(response);
        logResponseDetails(response);
    }

        private void autoValidateResponseSchema(String httpMethod, String endpoint, int statusCode) {
        String schemaPath = null;
        boolean isSuccess = statusCode >= 200 && statusCode < 300;

        if (endpoint != null && endpoint.contains("/recovery/v1/loan")) {
            if (isSuccess) {
                schemaPath = "schemas/recovery/success/loan_recovery_success_schema.json";
            }

        } else if (endpoint != null && endpoint.contains("/recovery/company")
                && !endpoint.contains("company-table-names")) {
            if (isSuccess) {
                boolean isWrite = "PUT".equalsIgnoreCase(httpMethod) || "PATCH".equalsIgnoreCase(httpMethod) || "POST".equalsIgnoreCase(httpMethod);
                schemaPath = isWrite
                        ? "schemas/recovery/success/recovery_company_put_success_schema.json"
                        : "schemas/recovery/success/recovery_company_filtered_success_schema.json";
            }
        }

        if (schemaPath != null) {
            response.then().assertThat().body(matchesJsonSchema(new File("src/test/resources/" + schemaPath)));
            logger.info("Auto schema validation passed for endpoint '{}' using '{}'", endpoint, schemaPath);
        } else {
            logger.info("No auto schema mapping configured for endpoint '{}'", endpoint);
        }
    }

    private void logResponseDetails(Response response) {
        logger.info("=== API Response Details ===");
        logger.info("Status Code: {}", response.getStatusCode());
        logger.info("Status Line: {}", response.getStatusLine());

        logger.info("Response Headers:");
        response.getHeaders().forEach(header ->
            logger.info("  {}: {}", header.getName(), header.getValue())
        );

        String responseBody = response.getBody().asString();
        if (responseBody != null && !responseBody.isEmpty()) {
            logger.info("Response Body:");
        
            if (response.getContentType() != null && response.getContentType().contains("json")) {
                try {
                    String prettyJson = JsonUtils.prettyPrint(responseBody);
                    logger.info(prettyJson);
                } catch (Exception e) {
                    logger.info(responseBody);
                }
            } else {
                logger.info(responseBody);
            }
        } else {
            logger.info("Response Body: (empty)");
        }
        logger.info("=== End Response Details ===");
    }

    @Then("the response status code should be {int}")
    public void the_response_status_code_should_be(int statusCode) {
        ResponseValidator.validateStatusCode(activeResponse(), statusCode);
    }

    @Then("the response message should be {string}")
    public void verifyResponseMessage(String expectedMessage) {

        Response response = activeResponse();

        String responseBody = response.getBody().asString();

        if (responseBody.startsWith("<html>")) {
            responseBody = responseBody
                    .replace("<html>", "")
                    .replace("</html>", "")
                    .replace("<body>", "")
                    .replace("</body>", "")
                    .trim();
        }

        JsonPath jsonPath = new JsonPath(responseBody);

        Assert.assertEquals(
                jsonPath.getString("message"),
                expectedMessage,
                "Response message mismatch"
        );
    }

    @Then("the response status code should be one of {string}")
    public void the_response_status_code_should_be_one_of(String statusCodes) {
        AssertionHelper.assertStatusCodeOneOf(activeResponse(), statusCodes);
    }
//

@Then("the response body field {string} should be captured value {string} {string} by {int}")
public void the_response_body_field_should_be_captured_value_increased_by(
        String jsonPath,
        String capturedKey,
        String operation,
        int increment) {

    String resolvedPath =
            scenarioTestDataResolver.replaceScenarioPlaceholders(jsonPath);

    String capturedValue =
            testContext.getCapturedValue(capturedKey);

    if (capturedValue == null || capturedValue.isBlank()) {
        throw new AssertionError(
                "No captured value found for '" + capturedKey + "'.");
    }

    int captured;

    try {
        captured = Integer.parseInt(capturedValue);
    } catch (NumberFormatException e) {
        throw new AssertionError(
                "Captured value '" + capturedValue
                        + "' for key '" + capturedKey
                        + "' is not a valid integer.");
    }

    String resolvedOperation =
            scenarioTestDataResolver
                    .replaceScenarioPlaceholders(operation)
                    .trim()
                    .toLowerCase();

    int expectedValue;

    switch (resolvedOperation) {
        case "increase":
            expectedValue = captured + increment;
            break;

        case "decrease":
            expectedValue = captured - increment;
            break;

        default:
            throw new IllegalArgumentException(
                    "Unsupported operation '" + operation
                            + "'. Expected 'increase' or 'decrease'.");
    }

    Object actualValue =
            activeResponse().jsonPath().get(resolvedPath);

    if (actualValue == null) {
        throw new AssertionError(
                "Response field '" + resolvedPath
                        + "' was not found. Body: "
                        + activeResponse().getBody().asString());
    }

    int actual;

    try {
        actual = Integer.parseInt(String.valueOf(actualValue));
    } catch (NumberFormatException e) {
        throw new AssertionError(
                "Response field '" + resolvedPath
                        + "' is not numeric. Actual value: "
                        + actualValue);
    }

    Assert.assertEquals(
            actual,
            expectedValue,
            "Response field '" + resolvedPath
                    + "' mismatch. Operation: "
                    + resolvedOperation
                    + ", captured value: "
                    + captured
                    + ", increment: "
                    + increment
                    + ", expected: "
                    + expectedValue
                    + ", actual: "
                    + actual);
}

    @Then("the response body should contain field {string} as {string} with value {string}")
    public void the_response_body_should_contain_field_as_type_with_value(
            String jsonPath, String type, String expectedValue) {
        String resolvedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(jsonPath);
        String resolvedType = scenarioTestDataResolver.replaceScenarioPlaceholders(type);
        String resolvedValue = scenarioTestDataResolver.replaceScenarioPlaceholders(expectedValue);
        ResponseValidator.validateJsonFieldTyped(activeResponse(), resolvedPath, resolvedType, resolvedValue);
    }

    @Then("the response body should contain field {string} as {string} with value:")
    public void the_response_body_should_contain_field_as_type_with_value_docstring(
            String jsonPath, String type, String docString) {
        the_response_body_should_contain_field_as_type_with_value(jsonPath, type, docString);
    }

    @Then("the response body should contain field {string}")
    public void the_response_body_should_contain_field(String jsonPath) {
        AssertionHelper.assertFieldExists(activeResponse(), jsonPath);
    }

    @Then("the response body should not contain field {string}")
    public void the_response_body_should_not_contain_field(String jsonPath) {
        String resolvedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(jsonPath);
        AssertionHelper.assertFieldAbsent(activeResponse(), resolvedPath);
    }

    @Then("the response body should contain text {string}")
    public void the_response_body_should_contain_text(String expected) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(expected);
        String body = activeResponse().getBody().asString();
        Assert.assertTrue(body.contains(resolved),
                "Expected response body to contain '" + resolved + "' but it did not. Body: " + body);
    }

    @Then("the response body should not contain text {string}")
    public void the_response_body_should_not_contain_text(String unexpected) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(unexpected);
        String body = activeResponse().getBody().asString();
        Assert.assertFalse(body.contains(resolved),
                "Expected response body NOT to contain '" + resolved + "' but it did. Body: " + body);
    }

    @Then("the response content type should be {string}")
    public void the_response_content_type_should_be(String contentType) {
        ResponseValidator.validateContentType(activeResponse(), contentType);
    }

    @Then("the response body should not be empty")
    public void the_response_body_should_not_be_empty() {
        ResponseValidator.validateResponseBodyNotEmpty(activeResponse());
    }

    @Then("the response time should be less than {int} milliseconds")
    public void the_response_time_should_be_less_than_milliseconds(int maxMillis) {
        Response active = activeResponse();
        long elapsed = active.time();
        org.testng.Assert.assertTrue(
                elapsed < maxMillis,
                "Response time " + elapsed + "ms exceeded limit of " + maxMillis + "ms"
        );
        logger.info("Response time {}ms is within limit {}ms", elapsed, maxMillis);
    }

    @Then("the response time should be within configured limit")
    public void the_response_time_should_be_within_configured_limit() {
        long maxMillis = configReader.getMaxResponseTimeMs();
        the_response_time_should_be_less_than_milliseconds((int) maxMillis);
    }

    @Then("the response should match json schema {string}")
    public void the_response_should_match_json_schema(String schemaPath) {
        activeResponse().then().assertThat().body(matchesJsonSchema(new File("src/test/resources/" + schemaPath)));
        logger.info("Response schema validation passed for: {}", schemaPath);
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(response, testContext);
    }

    private String replacePlaceholdersInBody(String body) {
        return PayloadHelper.convertBooleansToStrings(
                scenarioTestDataResolver.replaceScenarioPlaceholders(body)
        );
    }

private static final Pattern NAMED_RANDOM_STRING =
        Pattern.compile("\\{RANDOM_STRING:\\d+:([A-Za-z_][\\w.-]*)\\}");

private void updateJsonFieldTypedInternal(
        String jsonPath,
        String type,
        String value,
        String rememberAs) {

    String existingBody = currentRequestBody();

    if (existingBody == null || existingBody.isEmpty()) {
        throw new IllegalStateException(
                "Request body must be set before updating JSON field. "
                        + "Use 'I set the request body' or "
                        + "'I set the request body from file' first."
        );
    }

    String processedType =
            scenarioTestDataResolver
                    .replaceScenarioPlaceholders(type)
                    .trim();

    String processedPath =
            scenarioTestDataResolver
                    .replaceScenarioPlaceholders(jsonPath);

    String processedValue = value;

    if (processedValue != null) {

        processedValue = ValueExpressionHelper.resolve(
                processedValue,
                scenarioTestDataResolver::replaceScenarioPlaceholders
        );

        if (PayloadHelper.isNullToken(processedValue)
                || "null".equalsIgnoreCase(processedType)) {

            processedValue = null;
            processedType = "null";

        } else if (!ValueExpressionHelper
                .looksLikeConcatExpression(value)) {

            processedValue =
                    PayloadHelper.stripSurroundingQuotes(
                            processedValue
                    );
        }

    } else if (!"null".equalsIgnoreCase(processedType)) {

        processedType = "null";
    }

    // Update the request body
    applyRequestBody(
            JsonHelper.updateFieldTyped(
                    existingBody,
                    processedPath,
                    processedType,
                    processedValue
            )
    );

    // Named random aliases capture the FULL resolved field value
    captureNamedRandomFullValues(value, processedValue);

    // Remember the updated JSON field value if requested
    if (rememberAs != null && !rememberAs.isBlank()) {

        String key =
                scenarioTestDataResolver
                        .replaceScenarioPlaceholders(rememberAs)
                        .trim();

        if (key.isBlank()) {
            throw new IllegalArgumentException(
                    "Remember-as key must not be blank"
            );
        }

        testContext.captureValue(
                key,
                processedValue == null ? "null" : processedValue
        );

        logger.info(
                "Remembered updated JSON field '{}' value as {{CAPTURED:{}}} = '{}'",
                processedPath,
                key,
                processedValue
        );
    }

    logger.info(
            "Updated JSON field '{}' as {} to '{}' [thread={}]",
            processedPath,
            processedType,
            processedValue,
            Thread.currentThread().getName()
    );
}

private void captureNamedRandomFullValues(
        String originalTemplate,
        String resolvedValue) {

    if (originalTemplate == null || resolvedValue == null) {
        return;
    }

    Matcher matcher = NAMED_RANDOM_STRING.matcher(originalTemplate);
    Set<String> aliases = new LinkedHashSet<>();

    while (matcher.find()) {
        aliases.add(matcher.group(1));
    }

    for (String alias : aliases) {
        testContext.captureValue(alias, resolvedValue);

        logger.info(
                "Captured full resolved value as {{CAPTURED:{}}} = '{}'",
                alias,
                resolvedValue
        );
    }
}

private record ParamRow(
        String name,
        String rawValue,
        String rememberAs) {
}

private List<ParamRow> parseParamRows(DataTable dataTable) {
    List<ParamRow> rows = new ArrayList<>();

    for (List<String> row : dataTable.asLists()) {

        if (row == null || row.isEmpty()) {
            continue;
        }

        String name = row.get(0);

        if (name == null || name.isBlank()) {
            continue;
        }

        String rawValue = row.size() > 1 ? row.get(1) : "";
        String rememberAs = row.size() > 2 ? row.get(2) : null;

        if (rememberAs != null && rememberAs.isBlank()) {
            rememberAs = null;
        }

        rows.add(
                new ParamRow(
                        name.trim(),
                        rawValue,
                        rememberAs
                )
        );
    }

    return rows;
}

private String resolvePathParamValue(
        String name,
        String rawValue) {

    String value = resolveParamPlaceholders(name, rawValue);

    if (("loanId".equals(name) || "loan_id".equals(name))
            && ContextKeys.LOAN_ID.equals(rawValue)) {

        logger.info("Using scenario loan id: {}", value);
    }

    return value;
}

private String resolveQueryParamValue(
        String name,
        String rawValue) {

    return resolveParamPlaceholders(name, rawValue);
}

private String resolveParamPlaceholders(
        String name,
        String rawValue) {

    String paramNameLower =
            name == null ? "" : name.toLowerCase();

    String value = rawValue;

    if ("company_id".equals(paramNameLower)
            && ContextKeys.COMPANY_ID.equals(value)) {

        value = scenarioTestDataResolver.resolveCompanyId();
    }

    if (("loanId".equals(name)
            || "loan_id".equals(name)
            || "loanid".equals(paramNameLower))
            && ContextKeys.LOAN_ID.equals(value)) {

        value = scenarioTestDataResolver.resolveLoanId();
    }

    if (ContextKeys.AUTH_TOKEN.equals(value)) {
        value = testContext.getAuthToken();
    }

    if (ContextKeys.LOAN_ID.equals(value)) {
        value = scenarioTestDataResolver.resolveLoanId();
    }

    if (ContextKeys.CREATOR_USER_ID.equals(value)) {
        value = scenarioTestDataResolver.resolveCreatorUserId();
    }

    if (ContextKeys.ALLOCATION_MONTH.equals(value)) {
        value = scenarioTestDataResolver.resolveAllocationMonth();
    }

    if (value != null
            && value.contains("{ALLOCATION_MONTH_OFFSET:")) {

        value =
                scenarioTestDataResolver
                        .resolveAllocationMonthOffset(value);
    }

    if (value != null
            && (value.contains(ContextKeys.NOW_PREFIX)
            || value.contains(ContextKeys.CAPTURED_TIME_PREFIX))) {

        value =
                scenarioTestDataResolver
                        .resolveTimePlaceholders(value);
    }

    value =
            scenarioTestDataResolver
                    .resolveNamedSessionPlaceholders(value);

    if (value != null && value.contains("{")) {
        value =
                scenarioTestDataResolver
                        .replaceScenarioPlaceholders(value);
    }

    return value;
}

private void rememberTableValue(
        String rememberAs,
        String resolvedValue) {

    if (rememberAs == null || rememberAs.isBlank()) {
        return;
    }

    String key =
            scenarioTestDataResolver
                    .replaceScenarioPlaceholders(rememberAs)
                    .trim();

    if (key.isBlank()) {
        throw new IllegalArgumentException(
                "Remember-as key must not be blank"
        );
    }

    testContext.captureValue(
            key,
            resolvedValue == null ? "null" : resolvedValue
    );

    logger.info(
            "Remembered table value as {{CAPTURED:{}}} = '{}'",
            key,
            resolvedValue
    );
}

    private boolean usedRealAuthToken() {
        String realToken = testContext.getAuthToken();
        if (realToken == null) return false;
        return storedHeaders.entrySet().stream()
                .filter(e -> "authenticationtoken".equalsIgnoreCase(e.getKey()))
                .map(Map.Entry::getValue)
                .anyMatch(realToken::equals);
    }

    private void rebuildRequestWithFreshAuth() {
        String freshToken = testContext.getAuthToken();
        LinkedHashMap<String, String> headers = new LinkedHashMap<>(storedHeaders);
        headers.replaceAll((k, v) -> "authenticationtoken".equalsIgnoreCase(k) ? freshToken : v);
        storedHeaders.clear();
        storedHeaders.putAll(headers);
        rebuildRequestFromStoredState(null);
        logger.info("Rebuilt request with fresh auth token after 401");
    }

    private void rebuildRequestIfHeadersRemoved() {
        if (headersToRemove.isEmpty()) {
            return;
        }
        rebuildRequestFromStoredState(headersToRemove);
        logger.info("Rebuilt request excluding headers: {}", headersToRemove);
        headersToRemove.clear();
    }

    private void rebuildRequestFromStoredState(Set<String> excludedHeaderNamesLower) {
        request = restAssuredBase.getRequestSpec();
        for (Map.Entry<String, String> header : storedHeaders.entrySet()) {
            if (excludedHeaderNamesLower != null
                    && excludedHeaderNamesLower.contains(header.getKey().toLowerCase())) {
                continue;
            }
            request.header(header.getKey(), header.getValue());
        }
        storedPathParams.forEach((k, v) -> request.pathParam(k, v));
        storedQueryParams.forEach((k, v) -> request.queryParam(k, v));
        if (hasMultipartParts()) {
            applyMultipartParts();
        } else if (hasBinaryBody()) {
            if (binaryBodyContentType != null && !binaryBodyContentType.isBlank()) {
                request.contentType(binaryBodyContentType);
            }
            request.body(binaryBodyFile);
        } else {
            String body = currentRequestBody();
            if (body != null && !body.isBlank()) {
                request.body(body);
            }
        }
    }

    private boolean hasMultipartParts() {
        return !multipartFiles.isEmpty() || !multipartFields.isEmpty();
    }

    private void applyMultipartParts() {
        ensureRequestPrepared();
        if (!hasMultipartParts()) {
            return;
        }
        request.contentType(ContentType.MULTIPART);
        for (MultipartTextPart field : multipartFields) {
            request.multiPart(field.controlName(), field.value());
        }
        for (MultipartFilePart part : multipartFiles) {
            request.multiPart(part.controlName(), part.file(), part.mimeType());
        }
    }

    private String summarizeMultipartForLogging() {
        StringBuilder sb = new StringBuilder();
        for (MultipartTextPart field : multipartFields) {
            sb.append("field ").append(field.controlName())
                    .append("=").append(field.value()).append('\n');
        }
        for (MultipartFilePart part : multipartFiles) {
            sb.append("file ").append(part.controlName())
                    .append("=").append(part.file().getPath())
                    .append(" (").append(part.mimeType()).append(", ")
                    .append(part.file().length()).append(" bytes)\n");
        }
        return sb.toString().trim();
    }

    private String applyRefererHeader(String endpoint) {
        String baseUri = configReader.getBaseUrl();
        String resolvedEndpoint = endpoint;
        try {
            String loanId = scenarioTestDataResolver.resolveLoanId();
            resolvedEndpoint = resolvedEndpoint.replace("{loanId}", loanId).replace("{loan_id}", loanId);
        } catch (IllegalStateException ignored) {

        }
        String fullUrl = baseUri + resolvedEndpoint;
        request.header("Referer", fullUrl);
        logger.info("Set Referer header to: {}", fullUrl);
        return fullUrl;
    }

    private Map<String, String> headersForLogging(String referer) {
        Map<String, String> headers = new LinkedHashMap<>(storedHeaders);
        if (referer != null && !referer.isBlank()) {
            headers.put("Referer", referer);
        }
        return headers;
    }

    private Response executeHttp(HttpMethod method, String endpoint) {
        return executeHttp(request, method, endpoint);
    }

    private Response executeHttp(RequestSpecification spec, HttpMethod method, String endpointOrUrl) {
        return switch (method) {
            case GET -> spec.get(endpointOrUrl);
            case POST -> spec.post(endpointOrUrl);
            case PUT -> spec.put(endpointOrUrl);
            case PATCH -> spec.patch(endpointOrUrl);
            case DELETE -> spec.delete(endpointOrUrl);
            default -> throw new IllegalArgumentException("Unsupported HTTP method: " + method);
        };
    }
@And("I remove JSON field {string}")
public void i_remove_json_field(String jsonPath) {
    removeJsonFieldInternal(jsonPath);
}

private void removeJsonFieldInternal(String jsonPath) {

    String existingBody = currentRequestBody();

    if (existingBody == null || existingBody.isEmpty()) {
        throw new IllegalStateException(
                "Request body must be set before removing JSON field. "
                        + "Use 'I set the request body' or "
                        + "'I set the request body from file' first."
        );
    }

    String processedPath =
            scenarioTestDataResolver.replaceScenarioPlaceholders(jsonPath);

    String updatedBody =
            JsonHelper.removeField(existingBody, processedPath);

    applyRequestBody(updatedBody);

    logger.info(
            "Removed JSON field '{}' [thread={}]",
            processedPath,
            Thread.currentThread().getName()
    );
}

@And("I add JSON field {string} as {string} with value {string}")
public void i_add_json_field(String jsonPath, String type, String value) {
    addJsonFieldInternal(jsonPath, type, value);
}

private void addJsonFieldInternal(String jsonPath, String type, String value) {

    String existingBody = currentRequestBody();

    if (existingBody == null || existingBody.isEmpty()) {
        throw new IllegalStateException(
                "Request body must be set before adding JSON field. "
                        + "Use 'I set the request body' or "
                        + "'I set the request body from file' first."
        );
    }

    String processedType =
            scenarioTestDataResolver.replaceScenarioPlaceholders(type).trim();

    String processedPath =
            scenarioTestDataResolver.replaceScenarioPlaceholders(jsonPath);

    String processedValue = value;

    if (processedValue != null) {

        processedValue = ValueExpressionHelper.resolve(
                processedValue,
                scenarioTestDataResolver::replaceScenarioPlaceholders
        );

        if (PayloadHelper.isNullToken(processedValue)
                || "null".equalsIgnoreCase(processedType)) {

            processedValue = null;
            processedType = "null";

        } else if (!ValueExpressionHelper.looksLikeConcatExpression(value)) {

            processedValue =
                    PayloadHelper.stripSurroundingQuotes(processedValue);
        }

    } else if (!"null".equalsIgnoreCase(processedType)) {

        processedType = "null";
    }

    String updatedBody = JsonHelper.addField(
            existingBody,
            processedPath,
            processedType,
            processedValue
    );

    applyRequestBody(updatedBody);

    logger.info(
            "Added JSON field '{}' as {} with value '{}' [thread={}]",
            processedPath,
            processedType,
            processedValue,
            Thread.currentThread().getName()
    );
}

private void clearBinaryBody() {
    binaryBodyFile = null;
    binaryBodyContentType = null;
}

private boolean hasBinaryBody() {
    return binaryBodyFile != null;
}

private void applyHeadersAndQueryParamsToAbsoluteRequest(
        RequestSpecification absoluteRequest) {

    for (Map.Entry<String, String> header : storedHeaders.entrySet()) {
        absoluteRequest.header(header.getKey(), header.getValue());
    }

    for (Map.Entry<String, String> query : storedQueryParams.entrySet()) {
        absoluteRequest.queryParam(query.getKey(), query.getValue());
    }
}

private String applyPayloadToAbsoluteRequest(
        RequestSpecification absoluteRequest) {

    if (hasMultipartParts()) {
        absoluteRequest.contentType(ContentType.MULTIPART);

        for (MultipartTextPart field : multipartFields) {
            absoluteRequest.multiPart(field.controlName(), field.value());
        }

        for (MultipartFilePart part : multipartFiles) {
            absoluteRequest.multiPart(
                    part.controlName(),
                    part.file(),
                    part.mimeType()
            );
        }

        String summary = summarizeMultipartForLogging();
        testContext.setLastRequestBody(summary);
        return summary;
    }

    if (hasBinaryBody()) {
        if (binaryBodyContentType != null && !binaryBodyContentType.isBlank()) {
            absoluteRequest.contentType(binaryBodyContentType);
        }

        absoluteRequest.body(binaryBodyFile);

        String summary = "binary-file=" + binaryBodyFile.getPath()
                + " (" + binaryBodyContentType + ", "
                + binaryBodyFile.length() + " bytes)";

        testContext.setLastRequestBody(summary);
        return summary;
    }

    String body = currentRequestBody();

    if (body != null && !body.isBlank()) {
        absoluteRequest.body(body);
        testContext.setLastRequestBody(body);
        return body;
    }

    return null;
}
}
