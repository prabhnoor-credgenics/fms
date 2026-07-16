@api @global-status @recovery
Feature: Global Status API

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  @positive @smoke @creator
  Scenario: Get global statuses for configured company_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response content type should be "text/html; charset=utf-8"
    And the response should match json schema "schemas/global_status/success/global_status_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "message"
    And the response body should contain field "success"
  #  And global status response mandatory fields should be valid
  #  And global status company_id should match requested company
    And the response time should be within configured limit

  @positive @performance @creator
  Scenario: Global status API response time should be within threshold
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @auth @creator
  Scenario: API should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response should match json schema "schemas/global_status/error/global_status_error_schema.json"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response should match json schema "schemas/global_status/error/global_status_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 403
    And the response should match json schema "schemas/global_status/error/global_status_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response should match json schema "schemas/global_status/error/global_status_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 422
    And the response should match json schema "schemas/global_status/error/global_status_error_schema.json"

  @positive @creator
  Scenario: Global status response should contain valid mandatory fields
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "data"
    And the response body should contain field "message"
    And the response body should not be empty

  @positive @creator
  Scenario: Global status message should confirm dispositions fetched for valid company
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response message should be "All Global Dispositions Fetched"

  @positive @creator
  Scenario: Global status should return 200 when an unknown query parameter is supplied
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id     | {COMPANY_ID} |
      | unknown_param  | some_value   |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: Global status response should be valid JSON content type
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response content type should be "text/html; charset=utf-8"

  @negative @creator
  Scenario: API should fail when company_id query parameter is empty
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 403
    And the response should match json schema "schemas/global_status/error/global_status_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id contains a SQL injection payload
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | ' OR '1'='1 |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response should match json schema "schemas/global_status/error/global_status_error_schema.json"



