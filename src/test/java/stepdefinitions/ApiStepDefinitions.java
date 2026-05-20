package stepdefinitions;

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
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.http.Header;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import utils.JsonUtils;
import utils.ResponseValidator;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;

/**
 * Core HTTP step definitions — orchestrates request building, execution, and assertions.
 * Business logic is delegated to {@code helpers.*} and {@link ScenarioTestDataResolver}.
 */
public class ApiStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ApiStepDefinitions.class);

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final RestAssuredBase restAssuredBase;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    private RequestSpecification request;
    private Response response;
    private String requestBody;
    private final Set<String> headersToRemove = new HashSet<>();
    private final LinkedHashMap<String, String> storedHeaders = new LinkedHashMap<>();
    private final Map<String, String> storedPathParams = new HashMap<>();
    private final Map<String, String> storedQueryParams = new HashMap<>();

    public ApiStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            RestAssuredBase restAssuredBase,
            ScenarioTestDataResolver scenarioTestDataResolver
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.restAssuredBase = restAssuredBase;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    @Given("I prepare a request")
    public void i_prepare_a_request() {
        request = restAssuredBase.getRequestSpec();
        logger.info("Request specification prepared");
    }

    @Given("I set the request headers:")
    public void i_set_the_request_headers(Map<String, String> headers) {
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
            if (!"Referer".equals(headerName)) {
                storedHeaders.put(headerName, value);
                request.header(headerName, value);
                logger.info("Added header: {} = {}", headerName, value);
            }
        }
    }

    @Given("I remove header {string}")
    public void i_remove_header(String headerName) {
        headersToRemove.add(headerName.toLowerCase());
        logger.info("Marked header '{}' for removal on send", headerName);
    }

    @Given("I set the request body:")
    public void i_set_the_request_body(String body) {
        String processedBody = replacePlaceholdersInBody(body);
        this.requestBody = processedBody;
        request.body(processedBody);
        logger.info("Request body set: {}", processedBody);
    }

    @Given("I set the request body from file {string}")
    public void i_set_the_request_body_from_file(String filePath) {
        String jsonBody = FileHelper.readResourceAsString(filePath);
        String processedBody = replacePlaceholdersInBody(jsonBody);
        SchemaHelper.autoValidateRequestSchema(filePath, processedBody);
        this.requestBody = processedBody;
        request.body(processedBody);
        logger.info("Request body loaded from file '{}' and placeholders replaced", filePath);
    }

    @Given("I set the query parameters:")
    public void i_set_the_query_parameters(Map<String, String> queryParams) {
        if (!queryParams.containsKey("replace_previous_data")) {
            String replacePreviousData = configReader.getReplacePreviousData();
            storedQueryParams.put("replace_previous_data", replacePreviousData);
            request.queryParam("replace_previous_data", replacePreviousData);
            logger.info("Added default query parameter: replace_previous_data = {}", replacePreviousData);
        }
        if (!queryParams.containsKey("replace_given_data")) {
            String replaceGivenData = configReader.getReplaceGivenData();
            storedQueryParams.put("replace_given_data", replaceGivenData);
            request.queryParam("replace_given_data", replaceGivenData);
            logger.info("Added default query parameter: replace_given_data = {}", replaceGivenData);
        }

        for (Map.Entry<String, String> param : queryParams.entrySet()) {
            String paramName = param.getKey();
            String paramNameLower = paramName == null ? "" : paramName.toLowerCase();
            String value = param.getValue();
            if ("company_id".equals(paramNameLower) && ContextKeys.COMPANY_ID.equals(value)) {
                value = scenarioTestDataResolver.resolveCompanyId();
            }
            storedQueryParams.put(param.getKey(), value);
            request.queryParam(param.getKey(), value);
            logger.info("Added query parameter: {} = {}", param.getKey(), value);
        }
    }

    @Given("I set the path parameters:")
    public void i_set_the_path_parameters(Map<String, String> pathParams) {
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

    @Given("I update JSON field {string} to {string}")
    public void i_update_json_field_to(String jsonPath, String value) {
        updateJsonFieldInternal(jsonPath, value);
    }

    @Given("I update JSON field {string} to null")
    public void i_update_json_field_to_null(String jsonPath) {
        updateJsonFieldInternal(jsonPath, null);
    }

    @When("I send a {string} request to {string}")
    public void i_send_a_request_to(String httpMethod, String endpoint) {

        HttpMethod method = HttpMethod.valueOf(httpMethod.toUpperCase());

        if (!headersToRemove.isEmpty()) {

            RequestSpecification baseSpec;

            if (headersToRemove.contains("authenticationtoken")
                    || headersToRemove.contains("authorization")) {

                baseSpec = io.restassured.RestAssured.given()
                        .baseUri(configReader.getBaseUrl())
                        .contentType(configReader.getDefaultContentType())
                        .accept(configReader.getDefaultAcceptType());

            } else {
                baseSpec = restAssuredBase.getRequestSpec();
            }

            request = baseSpec;

            for (Map.Entry<String, String> pathParam : storedPathParams.entrySet()) {
                request.pathParam(pathParam.getKey(), pathParam.getValue());
            }

           
            for (Map.Entry<String, String> queryParam : storedQueryParams.entrySet()) {
                request.queryParam(queryParam.getKey(), queryParam.getValue());
            }

         
            if (requestBody != null && !requestBody.isEmpty()) {
                request.body(requestBody);
            }

            logger.info("Rebuilt request specification excluding headers: {}", headersToRemove);
            headersToRemove.clear();
        }

        String baseUri = configReader.getBaseUrl();
        String resolvedEndpoint = endpoint;

        try {
            String loanId = scenarioTestDataResolver.resolveLoanId();
            resolvedEndpoint = resolvedEndpoint
                    .replace("{loanId}", loanId)
                    .replace("{loan_id}", loanId);
        } catch (IllegalStateException ignored) {
           
        }

        String fullUrl = baseUri + resolvedEndpoint;

        request.header("Referer", fullUrl);

        logger.info("Set Referer header to: {}", fullUrl);
        logger.info("Sending {} request to endpoint: {}", method, endpoint);

        DateTimeFormatter formatter =
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

        LocalDateTime requestTime = LocalDateTime.now();
        long startTime = System.currentTimeMillis();

        StringBuilder apiLogs = new StringBuilder();

        // REQUEST LOGGING
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

        if (requestBody != null && !requestBody.isEmpty()) {
            apiLogs.append("\nREQUEST BODY:\n");
            apiLogs.append(requestBody).append("\n");
        }

        // EXECUTE REQUEST
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

        LocalDateTime responseTime = LocalDateTime.now();
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;

        logger.info("Response received with status code: {}", response.getStatusCode());

        // RESPONSE LOGGING
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

        
        autoValidateResponseSchema(endpoint, response.getStatusCode());

        testContext.setResponse(response);

        logResponseDetails(response);
    }

    
        private void autoValidateResponseSchema(String endpoint, int statusCode) {
        String schemaPath = null;
        boolean isSuccess = statusCode >= 200 && statusCode < 300;

        if (endpoint != null && endpoint.contains("/recovery/v1/loan")) {
            if (isSuccess) {
                schemaPath = "schemas/loan_recovery_success_schema.json";
            }
            
        } else if (endpoint != null && endpoint.contains("/recovery/company")) {
            if (isSuccess) {
                schemaPath = "schemas/recovery_company_success_schema.json";
            }
        }

        if (schemaPath != null) {
            response.then().assertThat().body(matchesJsonSchemaInClasspath(schemaPath));
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
    @Then("the validation error should contain")
    public void the_validation_error_should_contain(DataTable table) {
        SoftAssert softAssert = new SoftAssert();
        Map<String, String> expected = table.asMap(String.class, String.class);
        Map<String, String> actual = activeResponse().jsonPath().getMap("error");

        softAssert.assertNotNull(actual, "Error data is null in response");
        expected.forEach((key, value) -> {
            softAssert.assertTrue(actual.containsKey(key), "Missing error key: " + key);
            if (actual.containsKey(key)) {
                softAssert.assertEquals(actual.get(key), value, "Mismatch for error key: " + key);
            }
        });
        softAssert.assertAll();
    }

    @Then("the response status code should be {int}")
    public void the_response_status_code_should_be(int statusCode) {
        ResponseValidator.validateStatusCode(activeResponse(), statusCode);
    }

    @Then("the response message should be {string}")
    public void verifyResponseMessage(String expectedMessage) {
        activeResponse().then().body("message", equalTo(expectedMessage));
    }

    @Then("the response status code should be one of {string}")
    public void the_response_status_code_should_be_one_of(String statusCodes) {
        AssertionHelper.assertStatusCodeOneOf(activeResponse(), statusCodes);
    }

    @Then("the response body should contain field {string} with value {string}")
    public void the_response_body_should_contain_field_with_value(String jsonPath, String expectedValue) {
        ResponseValidator.validateJsonField(activeResponse(), jsonPath, expectedValue);
    }

    @Then("the response body should contain field {string}")
    public void the_response_body_should_contain_field(String jsonPath) {
        AssertionHelper.assertFieldExists(activeResponse(), jsonPath);
    }

    @Then("the response header {string} should be {string}")
    public void the_response_header_should_be(String headerName, String expectedValue) {
        ResponseValidator.validateHeader(activeResponse(), headerName, expectedValue);
    }

    @Then("the response content type should be {string}")
    public void the_response_content_type_should_be(String contentType) {
        ResponseValidator.validateContentType(activeResponse(), contentType);
    }

    @Then("the response body should not be empty")
    public void the_response_body_should_not_be_empty() {
        ResponseValidator.validateResponseBodyNotEmpty(activeResponse());
    }

    @Then("the response should match json schema {string}")
    public void the_response_should_match_json_schema(String schemaPath) {
        activeResponse().then().assertThat().body(matchesJsonSchemaInClasspath(schemaPath));
        logger.info("Response schema validation passed for: {}", schemaPath);
    }

    @Then("the request body should match json schema {string}")
    public void the_request_body_should_match_json_schema(String schemaPath) {
        if (requestBody == null || requestBody.isEmpty()) {
            throw new IllegalStateException(
                    "Request body must be set before schema validation. "
                            + "Use 'I set the request body' or 'I set the request body from file' first."
            );
        }
        assertThat("Request body failed schema validation against " + schemaPath,
                requestBody, matchesJsonSchemaInClasspath(schemaPath));
        logger.info("Request body schema validation passed for: {}", schemaPath);
    }

    @Then("I store the response for later use")
    public void i_store_the_response_for_later_use() {
        logger.info("Response stored for later use. Status code: {}", activeResponse().getStatusCode());
    }

    public Response getResponse() {
        return activeResponse();
    }

    public RequestSpecification getRequest() {
        return request;
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(response, testContext);
    }

    private String replacePlaceholdersInBody(String body) {
        return PayloadHelper.convertBooleansToStrings(
                scenarioTestDataResolver.replaceScenarioPlaceholders(body)
        );
    }

    private void updateJsonFieldInternal(String jsonPath, String value) {
        if (requestBody == null || requestBody.isEmpty()) {
            throw new IllegalStateException(
                    "Request body must be set before updating JSON field. "
                            + "Use 'I set the request body' or 'I set the request body from file' first."
            );
        }
        String processedValue = value;
        if (processedValue != null) {
            processedValue = scenarioTestDataResolver.replaceScenarioPlaceholders(processedValue);
            if (PayloadHelper.isNullToken(processedValue)) {
                processedValue = null;
            } else {
                processedValue = PayloadHelper.stripSurroundingQuotes(processedValue);
            }
        }
        String updatedBody = JsonHelper.updateField(requestBody, jsonPath, processedValue);
        this.requestBody = updatedBody;
        request.body(updatedBody);
        logger.info("Updated JSON field '{}' to '{}'", jsonPath, processedValue);
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
        if (requestBody != null && !requestBody.isEmpty()) {
            request.body(requestBody);
        }
        logger.info("Rebuilt request excluding headers: {}", headersToRemove);
        headersToRemove.clear();
    }

    private void applyRefererHeader(String endpoint) {
        String baseUri = configReader.getBaseUrl();
        String resolvedEndpoint = endpoint;
        try {
            String loanId = scenarioTestDataResolver.resolveLoanId();
            resolvedEndpoint = resolvedEndpoint.replace("{loanId}", loanId).replace("{loan_id}", loanId);
        } catch (IllegalStateException ignored) {
            // Referer may not need loan id for all endpoints
        }
        String fullUrl = baseUri + resolvedEndpoint;
        request.header("Referer", fullUrl);
        logger.info("Set Referer header to: {}", fullUrl);
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
