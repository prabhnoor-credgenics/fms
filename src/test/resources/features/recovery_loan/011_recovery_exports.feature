@api @recovery-exports @recovery
Feature: Recovery Exports API

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  @positive @smoke @chief-admin
  Scenario: List recovery exports for configured company_id
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                      |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response should match json schema "schemas/recovery/success/recovery_exports_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "message"
    And the response body should contain field "success"
    And the response time should be within configured limit

  @positive @performance @chief-admin
  Scenario: Recovery exports API response time should be within threshold
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                      |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @auth @creator
  Scenario: API should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                      |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_exports_error_schema.json"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                      |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_exports_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/error/recovery_exports_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | invalid-company-id                                |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_exports_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | 00000000-0000-0000-0000-000000000000              |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/recovery_exports_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 400
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "invalid company id"
  @negative @creator
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 422
    And the response should match json schema "schemas/invalid_schema.json"
     And the response body should contain field "message" as "auto" with value "one or more companies not found"
  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "Invalid company_id"
