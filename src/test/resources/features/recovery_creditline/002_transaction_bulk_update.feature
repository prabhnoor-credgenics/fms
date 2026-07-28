@api @creditline @creditline-transaction-update @recovery
Feature: Credit-line Transaction Bulk Update — PATCH /recovery/v1/bulk/transaction-update
  # Credit-line product (company_type == "credit line"). Async endpoint: a valid envelope returns
  # 202 + data.request_id; per-row validation happens later in the queue worker, so row-shape
  # errors are NOT returned synchronously. Only upload_type + transaction_data are validated inline.
  # Body serializer: BulkTransactionUpload (upload_type?, transaction_data[] min 1 / max 1000).
  # Mirrors 001 (transaction bulk upload) but uses PATCH; success 202 message
  # "Update Request Initiated Successfully"; synchronous validation error code REC_BT0002.

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
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
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
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 403
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 403
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path ----------

  @positive @smoke @creditline
  Scenario: Valid bulk transaction update returns 202 with a request_id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 202
    And the response message should be "Update Request Initiated Successfully"
    And the response body should contain field "data.request_id"
    And the response should match json schema "schemas/creditline/success/transaction_bulk_async_success_schema.json"

  @positive @creditline
  Scenario: Minimal body (only transaction_data) returns 202
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "transaction_data": [ { "client_customer_id": "CUST_{LOAN_ID}", "transaction_id": "TXN_{LOAN_ID}" } ] }
      """
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    And the response should match json schema "schemas/creditline/success/transaction_bulk_async_success_schema.json"

  @positive @creditline
  Scenario Outline: upload_type accepts each valid value and returns 202
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    And I update JSON field "upload_type" to "<upload_type>"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 202
    And the response should match json schema "schemas/creditline/success/transaction_bulk_async_success_schema.json"

    Examples:
      | upload_type           |
      | default               |
      | replace_previous_data |
      | replace_given_data    |

  # ---------- Required-field / body validation (synchronous: REC_BT0002) ----------

  @negative @creditline
  Scenario: Missing transaction_data returns 400 validation error
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "upload_type": "default" }
      """
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Null transaction_data returns 400 validation error
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    And I update JSON field "transaction_data" to null
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Empty transaction_data array returns 400 (min_length 1)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "transaction_data": [] }
      """
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid upload_type value returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    And I update JSON field "upload_type" to "not_a_valid_operation"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: transaction_data of the wrong type (object not array) returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "transaction_data": { "client_customer_id": "CUST_{LOAN_ID}", "transaction_id": "TXN_{LOAN_ID}" } }
      """
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Boundary ----------

  @negative @creditline @boundary
  Scenario: More than 1000 transactions in one request returns 400 (max_length 1000)
    # TODO: verify on staging — needs a 1001-row payload; asserting the documented max_length limit.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload_over_limit.json"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Async behaviour note ----------

  @positive @creditline @async
  Scenario: Rows with missing per-row keys still return 202 (row validation is async, not synchronous)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "transaction_data": [ { "total_loan_amount": 50000 } ] }
      """
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
