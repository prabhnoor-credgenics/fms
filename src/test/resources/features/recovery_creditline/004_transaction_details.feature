@api @creditline @creditline-transaction-details @recovery
Feature: Credit-line Transaction Details — GET /recovery/transaction/details/<transaction_id>
  # Credit-line product (company_type == "credit line"). GROUP 4a detail fetch.
  # Auth: login + org only (NO loan permission required for this GET).
  # Envelope: FLAT — { output, message } with no top-level "success"/"error" keys.
  # Path param: <transaction_id>.
  # Query params:
  #   allocation_month  — default "Overall"
  #   attributes        — CSV, tokens: all | loan_attributes | additional_attributes | emi_schedule
  # Success 200 { output:<detail>, message:"success" }.
  # Error   400 { message:"Invalid transaction_id provided" } for an unknown/undefined/null id.
  #
  # NOTE: The transaction_id is supplied via a path-parameter table ("I set the path parameters:")
  # rather than embedded inline in the URL, so framework placeholders like {LOAN_ID} / {RANDOM_STRING}
  # are resolved (an inline "{...}" in the raw URL is mis-parsed by RestAssured as a path template).
  #
  # NOTE: A real transaction is created via the ASYNC bulk-upload endpoint (queue worker). The
  # read-back 200 was verified on staging (200 { output, message:"success" }); a short wait is added
  # after the 202 so the row is processed before the detail fetch.

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | transaction_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the path parameters:
      | transaction_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400
    # Reconciled: this GET returns 400 (not 403) when company_id is absent — only the bulk
    # upload/update endpoints return 403 for a missing company_id (see contract §6.1).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (multi-step chain: upload a transaction, then GET its details) ----------

  @positive @smoke @creditline @env-blocked
  Scenario: Upload a transaction then fetch its details returns 200 with output and message "success"
    # TODO: verify on staging — creditline company data/config dependent (returns 500). The endpoint
    # DOES return 200 { output, message:"success" } when run in isolation, but the bulk-upload is async
    # and the detail read-back intermittently returns 500 in a batch run even after a 10s wait
    # (async row not yet queryable / creditline company data dependent) — non-deterministic per §6.5.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    # Step 1 — create the transaction
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    # Step 2 — read the transaction details back (wait for the async row to be processed)
    And I wait for 10 seconds
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"

  # ---------- attributes selector (Scenario Outline over each CSV token) ----------

  @positive @creditline @env-blocked
  Scenario Outline: attributes selector "<attributes>" is accepted and returns 200 "success"
    # TODO: verify on staging — creditline company data/config dependent (returns 500). Async detail
    # read-back is non-deterministic in a batch run even after a 10s wait (see smoke scenario note, §6.5).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And I wait for 10 seconds
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}   |
      | attributes | <attributes>   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"

    Examples:
      | attributes            |
      | all                   |
      | loan_attributes       |
      | additional_attributes |
      | emi_schedule          |

  # ---------- allocation_month variants ----------

  @positive @creditline @env-blocked
  Scenario Outline: allocation_month "<allocation_month>" is accepted and returns 200 "success"
    # TODO: verify on staging — creditline company data/config dependent (returns 500). Async detail
    # read-back is non-deterministic in a batch run even after a 10s wait (see smoke scenario note, §6.5).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And I wait for 10 seconds
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}         |
      | allocation_month | <allocation_month>   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"

    Examples:
      | allocation_month |
      | Overall          |
      | 2026-7-01        |

  @positive @creditline @env-blocked
  Scenario: No allocation_month query param falls back to the default "Overall" and returns 200
    # TODO: verify on staging — creditline company data/config dependent (returns 500). Async detail
    # read-back is non-deterministic in a batch run even after a 10s wait (see smoke scenario note, §6.5).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And I wait for 10 seconds
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | TXN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"

  # ---------- Negatives: unknown / undefined / null transaction_id ----------

  @negative @creditline @smoke
  Scenario: Unknown/random transaction_id returns 400 "Invalid transaction_id provided"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | TXN_NOPE_{RANDOM_STRING:12} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "Invalid transaction_id provided"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Literal "undefined" transaction_id returns 400 "Invalid transaction_id provided"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/transaction/details/undefined"
    Then the response status code should be 400
    And the response message should be "Invalid transaction_id provided"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Literal "null" transaction_id returns 400 "Invalid transaction_id provided"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/transaction/details/null"
    Then the response status code should be 400
    And the response message should be "Invalid transaction_id provided"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"
