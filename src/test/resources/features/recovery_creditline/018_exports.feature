@api @creditline @creditline-exports @recovery
Feature: Credit-line Exports — POST /recovery/export/loans, /recovery/export/payments
  # Shared export endpoints in credit-line context. Empty portfolio still returns 200
  # ("no data found" or a presigned link). Requires export_loans:read permission for happy paths.

  Background:
    Given scenario company id is from configuration
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: Export loans without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "export_type": "customer", "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/loans"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Export loans with invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "export_type": "customer", "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path ----------

  @positive @smoke @creditline @env-blocked
  # TODO: verify on staging — creditline company data/config dependent (export returns 403)
  Scenario: Export credit-line portfolio (link) returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "export_type": "customer", "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creditline @env-blocked
  # TODO: verify on staging — creditline company data/config dependent (export returns 403)
  Scenario: Export credit-line payments returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/payments"
    Then the response status code should be 200
    And the response body should contain field "message"
