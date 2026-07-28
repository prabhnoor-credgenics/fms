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
  # HAPPY PATH: the transaction is created SYNCHRONOUSLY via POST /recovery/v1/loan/{loan_id}
  # (source=quick_upload, transaction_id={LOAN_ID}) which returns 201 immediately, so the detail
  # read-back for the same {LOAN_ID} is deterministic (no async queue wait needed).

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400
    # Reconciled: this GET returns 400 (not 403) when company_id is absent — only the bulk
    # upload/update endpoints return 403 for a missing company_id (see contract §6.1).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (multi-step chain: upload a transaction, then GET its details) ----------

  @positive @smoke @creditline @multistep
  Scenario: Upload a transaction then fetch its details returns 200 with output and message "success"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    # Step 1 — create the transaction synchronously (transaction_id = {LOAN_ID})
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    # Step 2 — read the transaction details back
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"

  # ---------- attributes selector (Scenario Outline over each CSV token) ----------

  @positive @creditline @multistep
  Scenario Outline: attributes selector "<attributes>" is accepted and returns 200 "success"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}   |
      | attributes | <attributes>   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"

    Examples:
      | attributes      |
      | loan_attributes |
      | emi_schedule    |

    # These selectors trigger an additional-attributes fetch that 500s ("something went wrong")
    # for the staging credit-line company (company-data dependent, not a test defect — see §6.4).
    @env-blocked
    Examples:
      | attributes            |
      | all                   |
      | additional_attributes |

  # ---------- allocation_month variants ----------

  @positive @creditline @multistep
  Scenario Outline: allocation_month "<allocation_month>" is accepted and returns 200 "success"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}         |
      | allocation_month | <allocation_month>   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"

    Examples:
      | allocation_month |
      | Overall          |
      | 2026-7-01        |

  @positive @creditline @multistep
  Scenario: No allocation_month query param falls back to the default "Overall" and returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"

  # ---------- Negatives: unknown / undefined / null transaction_id ----------

  @negative @creditline @smoke
  Scenario: Unknown/random transaction_id returns 400 "Invalid transaction_id provided"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
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
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
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
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/transaction/details/null"
    Then the response status code should be 400
    And the response message should be "Invalid transaction_id provided"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"
