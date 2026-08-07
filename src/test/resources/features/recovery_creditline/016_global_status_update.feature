@api @creditline @creditline-global-status-update @recovery
Feature: Credit-line Global Status Update — PATCH /recovery/global-status/update/<client_customer_id>

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |


  @negative @creditline
  Scenario: Status update without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    And I set the request body:
      """
      { "module": "global", "status_name": "Closed" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{client_customer_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Status update with invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    And I set the request body:
      """
      { "module": "global", "status_name": "Closed" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{client_customer_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @negative @creditline
  Scenario: Status update with reserved client_customer_id "undefined" returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "module": "global", "status_name": "Closed" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/undefined"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creditline
  Scenario: Status update for a non-existent client_customer_id returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | client_customer_id | NOPE_{LOAN_ID} |
    And I set the request body:
      """
      { "module": "global", "status_name": "Closed" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{client_customer_id}"
    Then the response status code should be 400
    And the response body should not be empty


  @positive @creditline @creator
  Scenario: Fetch the company's global statuses returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response body should contain field "data"
    And the response should match json schema "schemas/creditline/success/global_status_list_success_schema.json"


  @positive @smoke @creditline @creator @multistep
  Scenario: Upload a credit-line transaction then update its global status by client_customer_id
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
    And I wait for 5 seconds
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_name" as mapping id
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    And I set the request body:
      """
      { "module": "global", "status_name": "{MAPPING_ID}" }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{client_customer_id}"
    Then the response status code should be 200
    And the response body should not be empty
