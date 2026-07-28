@api @creditline @creditline-transaction-single-update @recovery
Feature: Credit-line Single Transaction Update — PATCH /recovery[/v3|v4|v5]/transaction/<client_customer_id>/<transaction_id>
  # Credit-line product (company_type == "credit line"). GROUP 3 (loan_upload.py:210-247).
  # PATCH /recovery/transaction/<cust>/<txn> and the identical /recovery/v3|v4|v5/transaction/<...>
  # variants — all four are functionally the same, so equivalence cases run as a Scenario Outline
  # over the path prefixes "", "v3/", "v4/", "v5/".
  # Auth: login+org+validity_check, perm loan_update:write.
  # Body (dynamic): source (str), defaults[] (allocation-month scoped), additional_variables{}, any
  # company variable. PATCH does NOT enforce mandatory fields. Minimal {"source":"api","amount_recovered":1500}.
  # FLAT envelope: 200 {"output":"Transaction successfully updated","message":"success"} or {"message":"no data to update"}.
  # Errors: 400 {message:"transaction not found"} (unknown ids); 400 empty body {message:"Please provide data"};
  # 400 bad path param; 400 "Data Validation Failed" with output.errors.
  # NOTE: client_customer_id / transaction_id are supplied via `I set the path parameters:` so that
  # {LOAN_ID}/{UUID} tokens resolve — RestAssured treats raw {..} in the URL as undefined path params.

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
      | cust | CUST_{LOAN_ID} |
      | txn  | TXN_{LOAN_ID}  |
    And I set the request body from file "test-data/creditline/transaction_single_update.json"
    When I send a "PATCH" request to "/recovery/transaction/{cust}/{txn}"
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
      | cust | CUST_{LOAN_ID} |
      | txn  | TXN_{LOAN_ID}  |
    And I set the request body from file "test-data/creditline/transaction_single_update.json"
    When I send a "PATCH" request to "/recovery/transaction/{cust}/{txn}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 403
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | cust | CUST_{LOAN_ID} |
      | txn  | TXN_{LOAN_ID}  |
    And I set the request body from file "test-data/creditline/transaction_single_update.json"
    When I send a "PATCH" request to "/recovery/transaction/{cust}/{txn}"
    Then the response status code should be 403
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (multi-step: create the transaction, then update it) ----------

  @positive @smoke @creditline @multistep
  Scenario: Update an existing transaction returns 200 "Transaction successfully updated"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    # Step 1 — create CUST_{LOAN_ID}/{LOAN_ID} synchronously via the single-upload endpoint
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "client_customer_id" to "CUST_{LOAN_ID}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    # Step 2 — PATCH the just-created transaction (cust=CUST_{LOAN_ID}, txn={LOAN_ID})
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | cust | CUST_{LOAN_ID} |
      | txn  | {LOAN_ID}      |
    And I set the request body from file "test-data/creditline/transaction_single_update.json"
    When I send a "PATCH" request to "/recovery/transaction/{cust}/{txn}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output" with value "Transaction successfully updated"
    And the response should match json schema "schemas/creditline/success/transaction_single_update_success_schema.json"

  # ---------- Equivalence across the 4 path prefixes ("", v3, v4, v5) ----------

  @negative @creditline
  Scenario Outline: Unknown ids return 400 "transaction not found" for every path variant
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | cust | CUST_NOPE_{UUID} |
      | txn  | TXN_NOPE_{UUID}  |
    And I set the request body from file "test-data/creditline/transaction_single_update.json"
    When I send a "PATCH" request to "/recovery/<version_segment>transaction/{cust}/{txn}"
    Then the response status code should be 400
    And the response message should be "transaction not found"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

    Examples:
      | version_segment |
      |                 |
      | v3/             |
      | v4/             |
      | v5/             |

  # ---------- Body validation ----------

  @negative @creditline
  Scenario: Empty body returns 400 "Please provide data"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | cust | CUST_{LOAN_ID} |
      | txn  | TXN_{LOAN_ID}  |
    And I set the request body:
      """
      {}
      """
    When I send a "PATCH" request to "/recovery/transaction/{cust}/{txn}"
    Then the response status code should be 400
    And the response message should be "Please provide data"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Bad path param returns 400
    # TODO: verify on staging — malformed client_customer_id / transaction_id path segments.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | cust | @@@ |
      | txn  | ### |
    And I set the request body from file "test-data/creditline/transaction_single_update.json"
    When I send a "PATCH" request to "/recovery/transaction/{cust}/{txn}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline @multistep
  Scenario: Invalid field value fails data validation with 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    # Step 1 — create the transaction synchronously so the PATCH has a persisted row to validate
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "client_customer_id" to "CUST_{LOAN_ID}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    # Step 2 — PATCH with a wrongly-typed value → data validation fails
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | cust | CUST_{LOAN_ID} |
      | txn  | {LOAN_ID}      |
    And I set the request body:
      """
      { "source": "api", "total_loan_amount": "not_a_number" }
      """
    When I send a "PATCH" request to "/recovery/transaction/{cust}/{txn}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"
