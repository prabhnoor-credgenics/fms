@api @creditline @creditline-all-loans @recovery
Feature: Credit-line Portfolio Listing — GET /recovery/all-loans
  # Shared endpoint run in credit-line company context (company_type == "credit line").
  # Returns the credit-line portfolio (customers/transactions). Empty portfolio still returns 200.

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path ----------

  @positive @smoke @creditline @env-blocked
  # TODO: verify on staging — creditline company data/config dependent (portfolio read returns 403)
  Scenario: GET all-loans for the credit-line company returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty
    And the response time should be within configured limit

  @positive @creditline @env-blocked
  # TODO: verify on staging — creditline company data/config dependent (portfolio read returns 403)
  Scenario Outline: GET all-loans paginated returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}  |
      | page_number | <page_number> |
      | page_size   | <page_size>   |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

    Examples:
      | page_number | page_size |
      | 1           | 5         |
      | 2           | 10        |
      | 1           | 50        |
