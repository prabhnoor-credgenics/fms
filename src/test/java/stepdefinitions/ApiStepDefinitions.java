package stepdefinitions;

import base.RestAssuredBase;
import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import enums.HttpMethod;
import io.cucumber.datatable.DataTable;
import org.testng.asserts.SoftAssert;
import utils.JsonUtils;
import utils.ResponseValidator;
import utils.TestDataHelper;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.hamcrest.Matchers;

import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;

/**
 * Step definitions for API testing
 */
public class ApiStepDefinitions {
    private static final Logger logger = LogManager.getLogger(ApiStepDefinitions.class);

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final RestAssuredBase restAssuredBase;
    private final TestDataHelper testDataHelper;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    private RequestSpecification request;
    private Response response;
    private String requestBody;
    private final java.util.Set<String> headersToRemove = new java.util.HashSet<>();
    /** Headers set via Gherkin (original name → resolved value), re-applied on send when some are removed. */
    private final java.util.LinkedHashMap<String, String> storedHeaders = new java.util.LinkedHashMap<>();
    private final java.util.Map<String, String> storedPathParams = new java.util.HashMap<>();
    private final java.util.Map<String, String> storedQueryParams = new java.util.HashMap<>();

    public ApiStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            RestAssuredBase restAssuredBase,
            TestDataHelper testDataHelper,
            ScenarioTestDataResolver scenarioTestDataResolver
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.restAssuredBase = restAssuredBase;
        this.testDataHelper = testDataHelper;
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
            
            // Skip if this header is marked for removal
            if (headersToRemove.contains(headerNameLower)) {
                logger.info("Skipping header '{}' as it is marked for removal", headerName);
                continue;
            }
            
            String value = header.getValue();
            // Replace {AUTH_TOKEN} placeholder with config value
            if ("authenticationtoken".equals(headerNameLower) && "{AUTH_TOKEN}".equals(value)) {
                value = testContext.getAuthToken();
                logger.info("Using authenticationtoken from TestContext");
            }
            // Don't set Referer here - it will be set automatically based on request URI
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
        // Replace placeholders in the body
        String processedBody = replacePlaceholdersInBody(body);
        this.requestBody = processedBody;
        request.body(processedBody);
        logger.info("Request body set: {}", processedBody);
    }

    @Given("I set the request body from file {string}")
    public void i_set_the_request_body_from_file(String filePath) {
        // Read JSON from file
        String jsonBody = JsonUtils.readJsonFromFile(filePath);
        // Replace placeholders with generated test data and config values
        String processedBody = replacePlaceholdersInBody(jsonBody);
        this.requestBody = processedBody;
        request.body(processedBody);
        logger.info("Request body loaded from file '{}' and placeholders replaced", filePath);
    }

    /**
     * Replace all placeholders including {LOAN_ID} and {ALLOCATION_MONTH} from config
     * Also converts boolean values to strings for API compatibility
     */
    private String replacePlaceholdersInBody(String body) {
        String processedBody = scenarioTestDataResolver.replaceScenarioPlaceholders(body);
        processedBody = convertBooleansToStrings(processedBody);
        return processedBody;
    }
    
    /**
     * Convert boolean JSON values (true/false) to string values ("TRUE"/"FALSE")
     * for fields that API expects as strings
     */
    private String convertBooleansToStrings(String jsonBody) {
        // Fields that should be converted from boolean to string
        String[] booleanFields = {
            "tenure_finished",
            "backed_by_security",
            "backed_by_surety"
        };
        
        String result = jsonBody;
        for (String field : booleanFields) {
            // Pattern to match: "field": true or "field": false (with optional whitespace)
            // Replace with: "field": "TRUE" or "field": "FALSE"
            String truePattern = "\"" + field + "\"\\s*:\\s*true\\b";
            String falsePattern = "\"" + field + "\"\\s*:\\s*false\\b";
            
            result = result.replaceAll(truePattern, "\"" + field + "\": \"TRUE\"");
            result = result.replaceAll(falsePattern, "\"" + field + "\": \"FALSE\"");
        }
        
        return result;
    }

    @Given("I set the query parameters:")
    public void i_set_the_query_parameters(Map<String, String> queryParams) {
        // Add default query parameters first (if not explicitly provided)
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
            // Replace {COMPANY_ID} placeholder with config value
            if ("company_id".equals(paramNameLower) && "{COMPANY_ID}".equals(value)) {
                value = scenarioTestDataResolver.resolveCompanyId();
            }
            // Store query param for potential rebuilding
            storedQueryParams.put(param.getKey(), value);
            request.queryParam(param.getKey(), value);
            logger.info("Added query parameter: {} = {}", param.getKey(), value);
        }
    }

    @Given("I set the path parameters:")
    public void i_set_the_path_parameters(Map<String, String> pathParams) {
        for (Map.Entry<String, String> param : pathParams.entrySet()) {
            String value = param.getValue();
            // Replace {LOAN_ID} placeholder with config value (support both loanId and loan_id keys)
            if (("loanId".equals(param.getKey()) || "loan_id".equals(param.getKey())) && "{LOAN_ID}".equals(value)) {
                value = scenarioTestDataResolver.resolveLoanId();
                logger.info("Using scenario loan id: {}", value);
            } else {
                value = scenarioTestDataResolver.replaceScenarioPlaceholders(value);
            }
            // Store path param for potential rebuilding
            storedPathParams.put(param.getKey(), value);
            request.pathParam(param.getKey(), value);
            logger.info("Added path parameter: {} = {}", param.getKey(), value);
        }
    }

    @Then("the validation error should contain")
    public void the_validation_error_should_contain(DataTable table) {

        SoftAssert softAssert = new SoftAssert();

        Map<String, String> expected =
                table.asMap(String.class, String.class);

        Map<String, String> actual =
                response.jsonPath()
                        .getMap("error");

        softAssert.assertNotNull(
                actual,
                "Error data is null in response"
        );

        expected.forEach((key, value) -> {

            softAssert.assertTrue(
                    actual.containsKey(key),
                    "Missing error key: " + key
            );

            if (actual.containsKey(key)) {
                softAssert.assertEquals(
                        actual.get(key),
                        value,
                        "Mismatch for error key: " + key
                );
            }
        });


        softAssert.assertAll();
    }



    @Given("I update JSON field {string} to {string}")
    public void i_update_json_field_to(String jsonPath, String value) {
        updateJsonFieldInternal(jsonPath, value);
    }

    @Given("I update JSON field {string} to null")
    public void i_update_json_field_to_null(String jsonPath) {
        updateJsonFieldInternal(jsonPath, null);
    }
    
    /**
     * Internal method to update JSON field
     */
    private void updateJsonFieldInternal(String jsonPath, String value) {
        if (this.requestBody == null || this.requestBody.isEmpty()) {
            throw new IllegalStateException("Request body must be set before updating JSON field. Use 'I set the request body' or 'I set the request body from file' first.");
        }
        
        String processedValue = value;
        
        if (processedValue != null) {
            // Replace placeholders in the value
            processedValue = scenarioTestDataResolver.replaceScenarioPlaceholders(processedValue);
            
            // Handle null values (case-insensitive check)
            if ("null".equalsIgnoreCase(processedValue.trim())) {
                processedValue = null;
            } else {
                // Remove surrounding quotes if the value is wrapped in quotes (handles cases like "yes", "no", etc.)
                String trimmed = processedValue.trim();
                if (trimmed.length() >= 2 && trimmed.startsWith("\"") && trimmed.endsWith("\"")) {
                    processedValue = trimmed.substring(1, trimmed.length() - 1);
                }
            }
        }
        
        // Update JSON using JsonUtils
        String updatedBody = JsonUtils.updateJsonField(this.requestBody, jsonPath, processedValue);
        this.requestBody = updatedBody;
        request.body(updatedBody);
        logger.info("Updated JSON field '{}' to '{}'", jsonPath, processedValue);
    }

    @When("I send a {string} request to {string}")
    public void i_send_a_request_to(String httpMethod, String endpoint) {
        HttpMethod method = HttpMethod.valueOf(httpMethod.toUpperCase());
        
        // Rebuild request without headers marked for removal (keeps role, Content-Type, etc.)
        if (!headersToRemove.isEmpty()) {
            request = restAssuredBase.getRequestSpec();

            for (Map.Entry<String, String> header : storedHeaders.entrySet()) {
                if (!headersToRemove.contains(header.getKey().toLowerCase())) {
                    request.header(header.getKey(), header.getValue());
                }
            }

            for (Map.Entry<String, String> pathParam : storedPathParams.entrySet()) {
                request.pathParam(pathParam.getKey(), pathParam.getValue());
            }

            for (Map.Entry<String, String> queryParam : storedQueryParams.entrySet()) {
                request.queryParam(queryParam.getKey(), queryParam.getValue());
            }

            if (requestBody != null && !requestBody.isEmpty()) {
                request.body(requestBody);
            }

            logger.info("Rebuilt request excluding headers: {}", headersToRemove);
            headersToRemove.clear();
        }
        
        // Build full URI for Referer header
        String baseUri = configReader.getBaseUrl();
        // Replace {loanId} or {loan_id} placeholder in endpoint with actual loan_id from config for Referer
        String resolvedEndpoint = endpoint;
        try {
            String loanId = scenarioTestDataResolver.resolveLoanId();
            resolvedEndpoint = resolvedEndpoint.replace("{loanId}", loanId)
                    .replace("{loan_id}", loanId);
        } catch (IllegalStateException ignored) {
            // Referer may not need loan id for all endpoints
        }
        String fullUrl = baseUri + resolvedEndpoint;
        // Set Referer header to the full URI
        request.header("Referer", fullUrl);
        logger.info("Set Referer header to: {}", fullUrl);
        
        logger.info("Sending {} request to endpoint: {}", method, endpoint);

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

        logger.info("Response received with status code: {}", response.getStatusCode());

        // Auto-validate response contract schema per API endpoint
        autoValidateResponseSchema(endpoint, response.getStatusCode());
        
        testContext.setResponse(response);
        
        // Log complete response details
        logResponseDetails(response);
    }

    /**
     * Applies endpoint-specific schema validation automatically for every API hit.
     */
    private void autoValidateResponseSchema(String endpoint, int statusCode) {
        String schemaPath = null;
        boolean isSuccess = statusCode >= 200 && statusCode < 300;

        if (endpoint != null && endpoint.contains("/recovery/v1/loan")) {
            if (isSuccess) {
                schemaPath = "schemas/loan_recovery_success_schema.json";
            }
            // Error payloads vary by status (401 message-only, 403, HTML-wrapped 400, etc.);
            // scenarios assert error schema explicitly when needed.
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
    
    /**
     * Log detailed response information
     */
    private void logResponseDetails(Response response) {
        logger.info("=== API Response Details ===");
        logger.info("Status Code: {}", response.getStatusCode());
        logger.info("Status Line: {}", response.getStatusLine());
        
        // Log Response Headers
        logger.info("Response Headers:");
        response.getHeaders().forEach(header -> 
            logger.info("  {}: {}", header.getName(), header.getValue())
        );
        
        // Log Response Body
        String responseBody = response.getBody().asString();
        if (responseBody != null && !responseBody.isEmpty()) {
            logger.info("Response Body:");
            // If body is JSON, try to pretty print it
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
        ResponseValidator.validateStatusCode(response, statusCode);
    }

    @Then("the response message should be {string}")
    public void verifyResponseMessage(String expectedMessage) {
        response.then()
                .body("message", equalTo(expectedMessage));
    }

    @Then("the response status code should be one of {string}")
    public void the_response_status_code_should_be_one_of(String statusCodes) {
        String[] codes = statusCodes.split(",");
        int actualStatusCode = response.getStatusCode();
        boolean matches = false;
        for (String code : codes) {
            if (actualStatusCode == Integer.parseInt(code.trim())) {
                matches = true;
                break;
            }
        }
        assertThat("Status code " + actualStatusCode + " should be one of: " + statusCodes, matches, Matchers.is(true));
        logger.info("Status code {} is valid (one of: {})", actualStatusCode, statusCodes);
    }

    @Then("the response body should contain field {string} with value {string}")
    public void the_response_body_should_contain_field_with_value(String jsonPath, String expectedValue) {
        ResponseValidator.validateJsonField(response, jsonPath, expectedValue);
    }

    @Then("the response body should contain field {string}")
    public void the_response_body_should_contain_field(String jsonPath) {
        Object value = response.jsonPath().get(jsonPath);
        assertThat("Field " + jsonPath + " should exist", value, Matchers.notNullValue());
        logger.info("Field '{}' exists in response with value: {}", jsonPath, value);
    }

    @Then("the response header {string} should be {string}")
    public void the_response_header_should_be(String headerName, String expectedValue) {
        ResponseValidator.validateHeader(response, headerName, expectedValue);
    }

    @Then("the response content type should be {string}")
    public void the_response_content_type_should_be(String contentType) {
        ResponseValidator.validateContentType(response, contentType);
    }

    @Then("the response body should not be empty")
    public void the_response_body_should_not_be_empty() {
        ResponseValidator.validateResponseBodyNotEmpty(response);
    }

    @Then("the response should match json schema {string}")
    public void the_response_should_match_json_schema(String schemaPath) {
        response.then().assertThat().body(matchesJsonSchemaInClasspath(schemaPath));
        logger.info("Response schema validation passed for: {}", schemaPath);
    }

    @Then("I store the response for later use")
    public void i_store_the_response_for_later_use() {
        logger.info("Response stored for later use. Status code: {}", response.getStatusCode());
    }

    public Response getResponse() {
        return response;
    }

    public RequestSpecification getRequest() {
        return request;
    }}



