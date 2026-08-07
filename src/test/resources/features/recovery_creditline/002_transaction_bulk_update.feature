@api @creditline @creditline-transaction-update @recovery
Feature: Credit-line Transaction Bulk Update — PATCH /recovery/v1/bulk/transaction-update

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |


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
    And I update JSON field "upload_type" as "auto" to "<upload_type>"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 202
    And the response should match json schema "schemas/creditline/success/transaction_bulk_async_success_schema.json"

    Examples:
      | upload_type           |
      | default               |
      | replace_previous_data |
      | replace_given_data    |


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
    And I update JSON field "transaction_data" as "null" to "null"
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
    And I update JSON field "upload_type" as "auto" to "not_a_valid_operation"
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


  @negative @creditline @boundary
  Scenario: More than 1000 transactions in one request returns 400 (max_length 1000)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload_over_limit.json"
    When I send a "PATCH" request to "/recovery/v1/bulk/transaction-update"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


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
