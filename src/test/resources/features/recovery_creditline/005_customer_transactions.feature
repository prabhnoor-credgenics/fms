@api @creditline @creditline-customer-transactions @recovery
Feature: Credit-line Customer Transactions — GET /recovery/customer/transactions


  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |


  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id         | {COMPANY_ID}   |
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id         | {COMPANY_ID}   |
      | client_customer_id | CUST_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400

    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 400
    And the response message should be "invalid company id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @smoke @creditline @multistep @500
  Scenario: Upload a transaction then fetch it via customer/transactions returns 200 with a list
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
    And I update JSON field "client_customer_id" as "auto" to "CUST_{LOAN_ID}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id         | {COMPANY_ID}   |
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"


  @positive @creditline @multistep @500
  Scenario: Default allocation_month ("Overall") when the param is omitted returns 200 with a list
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
    And I update JSON field "client_customer_id" as "auto" to "CUST_{LOAN_ID}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id         | {COMPANY_ID}   |
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"

  @positive @creditline @multistep @500
  Scenario Outline: allocation_month values are accepted and return 200 with a list
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
    And I update JSON field "client_customer_id" as "auto" to "CUST_{LOAN_ID}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id         | {COMPANY_ID}       |
      | client_customer_id | CUST_{LOAN_ID}     |
      | allocation_month   | <allocation_month> |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"

    Examples:
      | allocation_month |
      | Overall          |
      | 2026-7-01        |


  @positive @creditline
  Scenario: Missing client_customer_id returns 200 with an empty result
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"

  @positive @creditline @env-blocked @500
  Scenario: Unknown client_customer_id returns 200 with an empty list
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id         | {COMPANY_ID}               |
      | client_customer_id | NO_SUCH_CUSTOMER_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"
