@api @loan-recovery @allocation-month
Feature: Loan Upload - Dynamic Allocation Month

  Background:
    Given scenario loan id is unique
    And I prepare a request

  @creator
  Scenario: Upload loan with allocation month set to the previous month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    Given scenario allocation month offset is -1
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_month.json"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200,201"

  @creator
  Scenario: Upload loan with allocation month set to the current month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    Given scenario allocation month offset is 0
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_month.json"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200,201"

  @creator
  Scenario: Upload loan with allocation month set to a future month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    Given scenario allocation month offset is 1
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_month.json"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200,201"

  @creator
  Scenario: Filter loans by allocation month using an inline offset query parameter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    Given I set the query parameters:
      | company_id       | {COMPANY_ID}                 |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:-1} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200

  @creator
  Scenario Outline: Upload loan with allocation month offset <offset> injected into the body
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:<offset>}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"

    Examples:
      | offset |
      | -1     |
      | 0      |
      | 1      |
