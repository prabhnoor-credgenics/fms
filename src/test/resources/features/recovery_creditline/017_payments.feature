@api @creditline @creditline-payments @recovery
Feature: Credit-line Payments — GET /recovery/payments/<loan_id>, POST /recovery/v1/payment-upload
  # Shared endpoints in credit-line context; <loan_id> is the credit-line transaction id.
  # Read/upload happy paths need an existing transaction (staging credit-line company under-seeded) -> @env-blocked.

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: GET payments without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/payments/{loan_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: GET payments with invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/payments/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: GET payments without company_id returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/payments/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Payment upload without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_id": "TXN_{LOAN_ID}", "amount_paid": 500 }
      """
    When I send a "POST" request to "/recovery/v1/payment-upload"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (needs an existing credit-line transaction) ----------

  @positive @creditline @env-blocked
  Scenario: GET payments for an existing credit-line transaction returns 200
    # TODO: verify on staging — creditline company data/config dependent (needs an existing transaction).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/payments/{loan_id}"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creditline @env-blocked
  Scenario: Upload a payment against an existing credit-line transaction returns 200
    # TODO: verify on staging — creditline company data/config dependent (needs an existing transaction).
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
      { "loan_id": "TXN_{LOAN_ID}", "amount_paid": 500, "payment_date": "{ALLOCATION_MONTH_OFFSET:0}" }
      """
    When I send a "POST" request to "/recovery/v1/payment-upload"
    Then the response status code should be 200
    And the response body should not be empty
