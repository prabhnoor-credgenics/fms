@api @payment-variables @recovery
Feature: Payment Variables API

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  # =====================================================================
  # GET /payment/variables
  # =====================================================================

  @positive @smoke @creator
  Scenario: Get payment variables configuration for configured company_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/payment_variables_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: Get payment variables with variables_required true
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id         | {COMPANY_ID} |
      | variables_required | true         |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/payment_variables_success_schema.json"
    And the response body should contain field "output"

  @positive @performance @creator
  Scenario: Payment variables GET response time should be within threshold
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @auth @creator
  Scenario: GET payment variables should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @creator
  Scenario: GET payment variables should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: GET payment variables should fail when company_id is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: GET payment variables should fail when company_id does not exist
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | 00000000-0000-0000-0000-000000000000 |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  # =====================================================================
  # PATCH /payment/variables
  # =====================================================================

  @positive @update @chief-admin
  Scenario: Update payment variable configuration via PATCH
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_amount_variable": "principal_amount",
        "interest_amount_variable": "interest_amount"
      }
      """
    When I send a "PATCH" request to "/recovery/payment/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/payment_variables_write_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @update @chief-admin
  Scenario: PATCH payment variables should fail when company_id is missing from body
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "principal_amount_variable": "principal_amount"
      }
      """
    When I send a "PATCH" request to "/recovery/payment/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @update @creator
  Scenario: PATCH payment variables should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_amount_variable": "principal_amount"
      }
      """
    When I send a "PATCH" request to "/recovery/payment/variables"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @update @creator
  Scenario: PATCH payment variables should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_amount_variable": "principal_amount"
      }
      """
    When I send a "PATCH" request to "/recovery/payment/variables"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"
