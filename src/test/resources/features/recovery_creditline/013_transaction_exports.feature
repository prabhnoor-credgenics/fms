@api @creditline @creditline-transaction-exports @recovery
Feature: Credit-line Transaction Exports — POST /recovery/export/{bulk,export-now,export-later}/loan-transactions


  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

 

  @negative @creditline
  Scenario: Bulk export without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Bulk export with an invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Bulk export with missing company_id returns 403
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 403
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Export-now without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/export-now/loan-transactions"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Export-later without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/creditline/loan_export_transaction_later.json"
    When I send a "POST" request to "/recovery/export/export-later/loan-transactions"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @smoke @creditline
  Scenario: Bulk export with response_type=link returns 200 (link or no-data-found)
   
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"

  @positive @creditline
  Scenario: Bulk export with response_type=data returns 200

    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    And I update JSON field "response_type" to "data"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"

  @positive @creditline
  Scenario: Bulk export with explicit export_type=transaction and archive flag returns 200
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
      { "export_type": "transaction", "response_type": "link", "archive": true }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"



  @positive @smoke @creditline
  Scenario: Export-now returns 200 (always a link / no-data-found)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/export-now/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"

  @positive @smoke @creditline
  Scenario: Export-later with export_type=portfolio_transaction_data returns 200 success:true
  
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction_later.json"
    When I send a "POST" request to "/recovery/export/export-later/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_later_success_schema.json"



  @positive @creditline
  Scenario: Export-later with export_type=transaction is accepted and returns 200 success:true

    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction_later.json"
    And I update JSON field "export_type" to "transaction"
    When I send a "POST" request to "/recovery/export/export-later/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_later_success_schema.json"

  @positive @creditline @boundary
  Scenario: Bulk export with a selected_loan_ids list returns 200 (5000-loan guard not tripped)

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
      { "export_type": "transaction", "response_type": "link", "selected_loan_ids": ["CUST_{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"



  @positive @creditline
  Scenario: Bulk export with no export_type falls back to a customer export and still returns 200

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
      { "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"
