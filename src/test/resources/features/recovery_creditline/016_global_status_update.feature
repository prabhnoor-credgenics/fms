@api @creditline @creditline-global-status-update @recovery
Feature: Credit-line Global Status Update — PATCH /recovery/global-status/update/<loan_id>
  # Shared endpoint in credit-line context; <loan_id> is the credit-line transaction id.
  # The happy path needs an existing transaction (staging credit-line company under-seeded) -> @env-blocked.
  # NOTE: path ids via "I set the path parameters:" (inline {LOAN_ID} in the URL does NOT resolve).

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: Status update without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | TXN_{LOAN_ID} |
    And I set the request body:
      """
      { "global_status_id": "1" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loan_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Status update with invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | TXN_{LOAN_ID} |
    And I set the request body:
      """
      { "global_status_id": "1" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Path / body validation ----------

  @negative @creditline
  Scenario: Status update with reserved loan_id "undefined" returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "global_status_id": "1" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/undefined"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creditline
  Scenario: Status update for a non-existent transaction returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | NOPE_{LOAN_ID} |
    And I set the request body:
      """
      { "global_status_id": "1" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  # ---------- Happy path (needs an existing credit-line transaction) ----------

  @positive @creditline @env-blocked
  Scenario: Update global status of an existing credit-line transaction returns 200
    # TODO: verify on staging — creditline company data/config dependent (needs an existing transaction).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | TXN_{LOAN_ID} |
    And I set the request body:
      """
      { "global_status_id": "1" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loan_id}"
    Then the response status code should be 200
    And the response body should not be empty
