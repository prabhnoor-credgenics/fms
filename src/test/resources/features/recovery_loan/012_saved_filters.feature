@api @saved-filters @recovery
Feature: Saved Filter API

  @positive1
  Scenario: Verify get saved filter request
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
    When I send a "GET" request to "/recovery/saved/filters"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_saved_filter_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"
    And the response body should contain field "output[0].id"
    And the response body should contain field "output[0].filter_name"
    And the response body should contain field "output[0].created_by"
    And the response body should contain field "output[0].filters"
    And the response body should contain field "output[0].filters.loan_type"
    And the response body should contain field "output[0].filters.product_type"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/move-loan-restriction"
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
    When I send a "GET" request to "/recovery/move-loan-restriction"
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
    When I send a "GET" request to "/recovery/move-loan-restriction"
    Then the response status code should be 400
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "Invalid company_id"
