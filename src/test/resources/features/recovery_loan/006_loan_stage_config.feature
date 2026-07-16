@api @loan-stage-config @recovery
Feature: Loan Stage Config API

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  @positive @smoke @chief-admin
  Scenario: Get loan stage config for configured company_id
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 200
    And the response content type should be "text/html; charset=utf-8"
    And the response should match json schema "schemas/recovery/success/loan_stage_config_success_schema.json"
    And the response body should contain field "id"
    And the response body should contain field "company_id"
    And the response body should contain field "stage_variable_name"
    And the response body should contain field "message"
    #And loan stage config response mandatory fields should be valid
   # And loan stage config company_id should match requested company
    And the response time should be within configured limit

  @positive @performance @chief-admin
  Scenario: Loan stage config API response time should be within threshold
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @auth @creator
  Scenario: API should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/loan_stage_config_error_schema.json"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/loan_stage_config_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/error/loan_stage_config_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/loan_stage_config_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/loan_stage_config_error_schema.json"
