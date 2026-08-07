@api @loan-recovery @allocation-month @all-loans
Feature: Loan Upload and Get Loan Across Allocation Months

  Background:
    Given scenario loan id is unique
    And I prepare a request

  @creator
  Scenario: 01 - Upload loan in previous month and get loan in previous month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:-1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                 |
      | search_type      | loan_id                      |
      | query            | {LOAN_ID}                    |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:-1} |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"

  @creator
  Scenario: 02 - Upload loan in previous month and get loan in current month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:-1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | search_type      | loan_id                     |
      | query            | {LOAN_ID}                   |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"

  @creator
  Scenario: 03 - Upload loan in previous month and get loan in future month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:-1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | search_type      | loan_id                     |
      | query            | {LOAN_ID}                   |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:1} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"

  @creator
  Scenario: 04 - Upload loan in previous month and get loan in Overall month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:-1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | search_type      | loan_id      |
      | query            | {LOAN_ID}    |
      | allocation_month | overall      |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"

  @creator
  Scenario: 05 - Upload loan in current month and get loan in previous month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                 |
      | search_type      | loan_id                      |
      | query            | {LOAN_ID}                    |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:-1} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"

  @creator
  Scenario: 06 - Upload loan in current month and get loan in current month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | search_type      | loan_id                     |
      | query            | {LOAN_ID}                   |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"

  @creator
  Scenario: 07 - Upload loan in current month and get loan in future month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | search_type      | loan_id                     |
      | query            | {LOAN_ID}                   |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:1} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"

  @creator
  Scenario: 08 - Upload loan in current month and get loan in Overall month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | search_type      | loan_id      |
      | query            | {LOAN_ID}    |
      | allocation_month | overall      |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"

  @creator
  Scenario: 09 - Upload loan in future month and get loan in previous month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                 |
      | search_type      | loan_id                      |
      | query            | {LOAN_ID}                    |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:-1} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"

  @creator
  Scenario: 10 - Upload loan in future month and get loan in current month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | search_type      | loan_id                     |
      | query            | {LOAN_ID}                   |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"

  @creator
  Scenario: 11 - Upload loan in future month and get loan in future month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | search_type      | loan_id                     |
      | query            | {LOAN_ID}                   |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:1} |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"

  @creator
  Scenario: 12 - Upload loan in future month and get loan in Overall month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "200,201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | search_type      | loan_id      |
      | query            | {LOAN_ID}    |
      | allocation_month | overall      |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"
