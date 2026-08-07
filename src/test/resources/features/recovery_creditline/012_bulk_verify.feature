@api @creditline @creditline-bulk-verify @recovery
Feature: Credit-line Bulk Verify — POST /recovery/bulk/verify-customer & POST /recovery/bulk/verify-transaction

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |


  @negative @creditline
  Scenario: verify-customer without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request body from file "test-data/creditline/verify_customer.json"
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: verify-customer with an invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the request body from file "test-data/creditline/verify_customer.json"
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @negative @creditline
  Scenario: verify-transaction without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request body from file "test-data/creditline/verify_transaction.json"
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: verify-transaction with an invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the request body from file "test-data/creditline/verify_transaction.json"
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @smoke @creditline
  Scenario: verify-customer with an unknown id returns 200 with the id in non_verified_loan_ids
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["CUST_MISSING_{RANDOM_STRING:8}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "data.verified_loan_ids"
    And the response body should contain field "data.non_verified_loan_ids"
    And the response should match json schema "schemas/creditline/success/verify_customer_success_schema.json"

  @positive @creditline
  Scenario: verify-customer accepts optional allocation_month and archive and returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/verify_customer.json"
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 200
    And the response body should contain field "data.verified_loan_ids"
    And the response body should contain field "data.non_verified_loan_ids"
    And the response should match json schema "schemas/creditline/success/verify_customer_success_schema.json"

  @positive @creditline @multistep
  Scenario: Upload a transaction, then verify-customer for the created client_customer_id returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["CUST_{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 200
    And the response body should contain field "data.verified_loan_ids"
    And the response body should contain field "data.non_verified_loan_ids"
    And the response should match json schema "schemas/creditline/success/verify_customer_success_schema.json"


  @positive @smoke @creditline
  Scenario: verify-transaction with an unknown txn/cust pair returns 200 with maps
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "transactions": { "TXN_MISSING_{RANDOM_STRING:8}": "CUST_MISSING_{RANDOM_STRING:8}" } }
      """
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "data.verified_transactions_ids"
    And the response body should contain field "data.non_verified_transactions_ids"
    And the response should match json schema "schemas/creditline/success/verify_transaction_success_schema.json"

  @positive @creditline
  Scenario: verify-transaction accepts optional allocation_month and archive and returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/verify_transaction.json"
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 200
    And the response body should contain field "data.verified_transactions_ids"
    And the response body should contain field "data.non_verified_transactions_ids"
    And the response should match json schema "schemas/creditline/success/verify_transaction_success_schema.json"

  @positive @creditline @multistep
  Scenario: Upload a transaction, then verify-transaction for the created txn/cust pair returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "transactions": { "TXN_{LOAN_ID}": "CUST_{LOAN_ID}" } }
      """
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 200
    And the response body should contain field "data.verified_transactions_ids"
    And the response body should contain field "data.non_verified_transactions_ids"
    And the response should match json schema "schemas/creditline/success/verify_transaction_success_schema.json"


  @negative @creditline
  Scenario: verify-customer without company_id returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "loan_ids": ["CUST_{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: verify-customer with null company_id returns 500
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/verify_customer.json"
    And I update JSON field "company_id" as "null" to "null"
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 500
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: verify-customer without loan_ids returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: verify-customer with an empty loan_ids list returns 400 (min_length 1)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": [] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: verify-customer with loan_ids of the wrong type (object not array) returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": { "0": "CUST_{LOAN_ID}" } }
      """
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline @boundary
  Scenario: verify-customer with more than 10000 loan_ids returns 400 (max_length 10000)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/verify_customer_over_limit.json"
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @negative @creditline
  Scenario: verify-transaction without company_id returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "transactions": { "TXN_{LOAN_ID}": "CUST_{LOAN_ID}" } }
      """
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: verify-transaction with null company_id returns 500
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/verify_transaction.json"
    And I update JSON field "company_id" as "null" to "null"
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 500
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @positive @creditline
  Scenario: verify-transaction without transactions returns 200 (transactions is optional, not enforced)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "data.verified_transactions_ids"
    And the response should match json schema "schemas/creditline/success/verify_transaction_success_schema.json"

  @positive @creditline @boundary
  Scenario: verify-transaction with an empty transactions map returns 200 (empty map is not rejected)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "transactions": {} }
      """
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "data.verified_transactions_ids"
    And the response body should contain field "data.non_verified_transactions_ids"
    And the response should match json schema "schemas/creditline/success/verify_transaction_success_schema.json"

  @negative @creditline
  Scenario: verify-transaction with transactions of the wrong type (array not object) returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "transactions": ["TXN_{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-transaction"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"
