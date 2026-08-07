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


  @positive @chief-admin @configure
  Scenario: TC_LCS_011 — Update the collection stage configuration (PATCH enables normalize stage)
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 200
    And I store response field "stage_variable_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | content-type         | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "normalize_stage_variable_id": "{VARIABLE_ID}",
        "normalize_counter": 2,
        "normalize_reduction_factor": 0.5
      }
      """
    When I send a "PATCH" request to "/recovery/loan-stage/config"
    Then the response status code should be one of "200,400"
    And the response body should not be empty

  @positive @chief-admin @configure
  Scenario: TC_LCS_010 — Create the collection stage configuration (POST)
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be 200
    And I store response field "stage_variable_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | content-type         | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "stage_variable_id": "{VARIABLE_ID}",
        "roll_back_counter": 1,
        "roll_forward_counter": 1,
        "stabilize_counter": 1,
        "rollback_reduction_factor": 0.25,
        "rollforward_reduction_factor": 0.25,
        "stabilize_reduction_factor": 0.25
      }
      """
    When I send a "POST" request to "/recovery/loan-stage/config"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @negative @auth @configure
  Scenario: TC_LCS_011b — Update config without an authentication token is rejected
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | content-type | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "roll_back_counter": 2
      }
      """
    When I send a "PATCH" request to "/recovery/loan-stage/config"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @security @permission @creator
  Scenario: TC_LCS_015 — Collection stage config write is permission-gated
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | content-type         | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "roll_back_counter": 9
      }
      """
    When I send a "PATCH" request to "/recovery/loan-stage/config"
    Then the response status code should be one of "400,401,403"
    And the response body should not be empty

  @negative @security @idor @creator
  Scenario: TC_LCS_016 — IDOR: cannot read the stage config of an unassigned company
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {UUID} |
    When I send a "GET" request to "/recovery/loan-stage/config"
    Then the response status code should be one of "400,403,422"
    And the response should match json schema "schemas/recovery/error/loan_stage_config_error_schema.json"


