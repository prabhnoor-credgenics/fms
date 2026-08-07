package stepdefinitions;

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
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.http.Header;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import utils.JsonUtils;
import utils.ResponseValidator;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import java.io.File;
import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchema;
import static org.hamcrest.Matchers.equalTo;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.testng.Assert;

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

    @Given("I prepare a request")
    public void i_prepare_a_request() {
        request = restAssuredBase.getRequestSpec();
        storedHeaders.clear();
        storedQueryParams.clear();
        storedPathParams.clear();
        clearRequestBody();
        headersToRemove.clear();
        logger.info("Request specification prepared");
    }

    @Given("I set the request headers:")
    public void i_set_the_request_headers(Map<String, String> headers) {
        ensureRequestPrepared();
        for (Map.Entry<String, String> header : headers.entrySet()) {
            String headerName = header.getKey();
            String headerNameLower = headerName.toLowerCase();

            if (headersToRemove.contains(headerNameLower)) {
                logger.info("Skipping header '{}' as it is marked for removal", headerName);
                continue;
            }

            String value = header.getValue();
            if ("authenticationtoken".equals(headerNameLower) && ContextKeys.AUTH_TOKEN.equals(value)) {
                value = testContext.getAuthToken();
                logger.info("Using authenticationtoken from TestContext");
            }
            if ("x-company-id".equals(headerNameLower) && ContextKeys.COMPANY_ID.equals(value)) {
                value = scenarioTestDataResolver.resolveCompanyId();
                logger.info("Using x-company-id from resolved company id");
            }
            value = scenarioTestDataResolver.resolveNamedSessionPlaceholders(value);
            if (!"Referer".equals(headerName)) {
                storedHeaders.put(headerName, value);
                request.header(headerName, value);
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

    @Given("I set the query parameters:")
    public void i_set_the_query_parameters(Map<String, String> queryParams) {
        ensureRequestPrepared();
        for (Map.Entry<String, String> param : queryParams.entrySet()) {
            String paramName = param.getKey();
            String paramNameLower = paramName == null ? "" : paramName.toLowerCase();
            String value = param.getValue();
            if ("company_id".equals(paramNameLower) && ContextKeys.COMPANY_ID.equals(value)) {
                value = scenarioTestDataResolver.resolveCompanyId();
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
            if (value != null && value.contains("{ALLOCATION_MONTH_OFFSET:")) {
                value = scenarioTestDataResolver.resolveAllocationMonthOffset(value);
            }
            if (value != null && (value.contains(ContextKeys.NOW_PREFIX)
                    || value.contains(ContextKeys.CAPTURED_TIME_PREFIX))) {
                value = scenarioTestDataResolver.resolveTimePlaceholders(value);
            }
            value = scenarioTestDataResolver.resolveNamedSessionPlaceholders(value);
            storedQueryParams.put(param.getKey(), value);
            request.queryParam(param.getKey(), value);
            logger.info("Added query parameter: {} = {}", param.getKey(), value);
        }
    }

    @Given("I set the path parameters:")
    public void i_set_the_path_parameters(Map<String, String> pathParams) {
        ensureRequestPrepared();
        for (Map.Entry<String, String> param : pathParams.entrySet()) {
            String value = param.getValue();
            if (("loanId".equals(param.getKey()) || "loan_id".equals(param.getKey()))
                    && ContextKeys.LOAN_ID.equals(value)) {
                value = scenarioTestDataResolver.resolveLoanId();
                logger.info("Using scenario loan id: {}", value);
            } else {
                value = scenarioTestDataResolver.replaceScenarioPlaceholders(value);
            }
            storedPathParams.put(param.getKey(), value);
            request.pathParam(param.getKey(), value);
            logger.info("Added path parameter: {} = {}", param.getKey(), value);
        }
    }

    @Given("I update JSON field {string} as {string} to {string}")
    public void i_update_json_field_as_type_to(String jsonPath, String type, String value) {
        updateJsonFieldTypedInternal(jsonPath, type, value);
    }

    @Given("I update JSON field {string} as {string} to:")
    public void i_update_json_field_as_type_to_docstring(String jsonPath, String type, String docString) {
        updateJsonFieldTypedInternal(jsonPath, type, docString);
    }

    @Given("I update JSON field {string} from captured {string}")
    public void i_update_json_field_from_captured(String jsonPath, String key) {
        String existingBody = currentRequestBody();
        if (existingBody == null || existingBody.isEmpty()) {
            throw new IllegalStateException(
                    "Request body must be set before updating JSON field from captured value.");
        }
        if (!testContext.hasCapturedValue(key)) {
            throw new IllegalStateException(
                    "Nothing captured as '" + key + "'. Store/capture it earlier in the scenario.");
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
    if (bodyForSend != null && !bodyForSend.isBlank()) {
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

    if (bodyForSend != null && !bodyForSend.isEmpty()) {
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

    private void updateJsonFieldTypedInternal(String jsonPath, String type, String value) {
        String existingBody = currentRequestBody();
        if (existingBody == null || existingBody.isEmpty()) {
            throw new IllegalStateException(
                    "Request body must be set before updating JSON field. "
                            + "Use 'I set the request body' or 'I set the request body from file' first."
            );
        }
        String processedType = scenarioTestDataResolver.replaceScenarioPlaceholders(type).trim();
        String processedPath = scenarioTestDataResolver.replaceScenarioPlaceholders(jsonPath);
        String processedValue = value;
        if (processedValue != null) {
            processedValue = ValueExpressionHelper.resolve(
                    processedValue,
                    scenarioTestDataResolver::replaceScenarioPlaceholders
            );
            if (PayloadHelper.isNullToken(processedValue) || "null".equalsIgnoreCase(processedType)) {
                processedValue = null;
                processedType = "null";
            } else if (!ValueExpressionHelper.looksLikeConcatExpression(value)) {
                processedValue = PayloadHelper.stripSurroundingQuotes(processedValue);
            }
        } else if (!"null".equalsIgnoreCase(processedType)) {
            processedType = "null";
        }
        applyRequestBody(JsonHelper.updateFieldTyped(existingBody, processedPath, processedType, processedValue));
        logger.info("Updated JSON field '{}' as {} to '{}' [thread={}]",
                processedPath, processedType, processedValue, Thread.currentThread().getName());
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
        request = restAssuredBase.getRequestSpec();
        storedHeaders.replaceAll((k, v) -> "authenticationtoken".equalsIgnoreCase(k) ? freshToken : v);
        storedHeaders.forEach((k, v) -> request.header(k, v));
        storedPathParams.forEach((k, v) -> request.pathParam(k, v));
        storedQueryParams.forEach((k, v) -> request.queryParam(k, v));
        String body = currentRequestBody();
        if (body != null && !body.isBlank()) {
            request.body(body);
        }
        logger.info("Rebuilt request with fresh auth token after 401");
    }

    private void rebuildRequestIfHeadersRemoved() {
        if (headersToRemove.isEmpty()) {
            return;
        }
        request = restAssuredBase.getRequestSpec();
        for (Map.Entry<String, String> header : storedHeaders.entrySet()) {
            if (!headersToRemove.contains(header.getKey().toLowerCase())) {
                request.header(header.getKey(), header.getValue());
            }
        }
        storedPathParams.forEach((k, v) -> request.pathParam(k, v));
        storedQueryParams.forEach((k, v) -> request.queryParam(k, v));
        String body = currentRequestBody();
        if (body != null && !body.isEmpty()) {
            request.body(body);
        }
        logger.info("Rebuilt request excluding headers: {}", headersToRemove);
        headersToRemove.clear();
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
        return switch (method) {
            case GET -> request.get(endpoint);
            case POST -> request.post(endpoint);
            case PUT -> request.put(endpoint);
            case PATCH -> request.patch(endpoint);
            case DELETE -> request.delete(endpoint);
            default -> throw new IllegalArgumentException("Unsupported HTTP method: " + method);
        };
    }
}
