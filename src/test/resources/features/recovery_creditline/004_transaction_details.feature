@api @creditline @creditline-transaction-details @recovery
Feature: Credit-line Transaction Details — GET /recovery/transaction/details/<transaction_id>


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

    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"



  @positive @smoke @creditline @multistep
  Scenario: Upload a transaction then fetch its details returns 200 with output and message "success"
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
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/transaction_details_success_schema.json"



  @positive @creditline @multistep @500
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
      | all                   |
      | additional_attributes |




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
