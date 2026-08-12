@api @payment-variables @recovery
Feature: Payment Variables API

  Background:
    Given scenario company id is from configuration
    And I prepare a request


  @positive @smoke @chief-admin
  Scenario: Get payment variables configuration for configured company_id
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/payment_variables_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @chief-admin
  Scenario: Get payment variables with variables_required true
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id         | {COMPANY_ID} |
      | variables_required | true         |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/payment_variables_success_schema.json"
    And the response body should contain field "output"

  @positive @performance @chief-admin
  Scenario: Payment variables GET response time should be within threshold
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @auth @creator
  Scenario: GET payment variables should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @creator
  Scenario: GET payment variables should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: GET payment variables should fail when company_id is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: GET payment variables should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/payment/variables"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"


  @positive @update @chief-admin
  Scenario: Update payment variable configuration via PATCH
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_amount_variable": "principal_amount",
        "interest_amount_variable": "interest_amount"
      }
      """
    When I send a "PATCH" request to "/recovery/payment/variables"
    Then the response status code should be one of "200,400"
    And the response body should contain field "message"

  @negative @update @chief-admin
  Scenario: PATCH payment variables should fail when company_id is missing from body
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_amount_variable": "principal_amount"
      }
      """
    When I send a "PATCH" request to "/recovery/payment/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @update @creator
  Scenario: PATCH payment variables should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_amount_variable": "principal_amount"
      }
      """
    When I send a "PATCH" request to "/recovery/payment/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"
