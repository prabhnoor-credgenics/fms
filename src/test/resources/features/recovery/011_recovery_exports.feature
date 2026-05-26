@api @recovery-exports @recovery
Feature: Recovery Exports API

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  @positive @smoke @creator
  Scenario: List recovery exports for configured company_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                      |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response should match json schema "schemas/recovery_exports_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "message"
    And the response body should contain field "success"
    #And recovery exports response mandatory fields should be valid
   # And recovery exports should match requested company
   # And recovery exports page should respect page size 10
    And the response time should be within configured limit

  @positive @performance @creator
  Scenario: Recovery exports API response time should be within threshold
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
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
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                      |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery_exports_error_schema.json"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                      |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery_exports_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery_exports_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | invalid-company-id                |
    And I set the query parameters:
      | company_id       | invalid-company-id                                |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery_exports_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | 00000000-0000-0000-0000-000000000000 |
    And I set the query parameters:
      | company_id       | 00000000-0000-0000-0000-000000000000              |
      | page_number      | 1                                                 |
      | page_size        | 10                                                |
      | export_category  | loan,portfolio_data,portfolio_allocated_users     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery_exports_error_schema.json"
