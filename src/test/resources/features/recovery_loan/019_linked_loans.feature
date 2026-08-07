Feature: Linked Loans API

  @positive1
  Scenario: GET linked loans by loan_id after uploading a loan
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "group_id" as "auto" to "linked-loans-auto-grp"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | allocation_month | overall      |
      | loan_id          | {LOAN_ID}    |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/linked_loans_success_schema.json"
    And the response body should contain field "output"

  @positive
  Scenario: GET linked loans by group_id with allocation_month=overall
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "group_id" as "auto" to "linked-loans-auto-grp"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200,201,400"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}          |
      | allocation_month | overall               |
      | group_id         | linked-loans-auto-grp |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/linked_loans_success_schema.json"
    And the response body should contain field "output"

  @positive
  Scenario: GET linked loans by group_id with pagination params
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "group_id" as "auto" to "linked-loans-auto-grp"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200,201,400"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}          |
      | allocation_month | overall               |
      | group_id         | linked-loans-auto-grp |
      | page_number      |                     1 |
      | page_size        |                    10 |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/linked_loans_success_schema.json"
    And the response body should contain field "output"

  @negative @creator
  Scenario: GET linked loans should return all loans and groups when both loan_id and group_id are missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | allocation_month | overall      |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be one of "200"
    And the response should match json schema "schemas/recovery/success/linked_loans_success_schema.json"

  @negative @auth @creator
  Scenario: GET linked loans should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                         |
      | allocation_month | overall                              |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 400
    And the response body should contain field "message" as "auto" with value "invalid authentication token"

  @negative @auth @creator
  Scenario: GET linked loans should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                         |
      | allocation_month | overall                              |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be one of "400"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"

  @negative @creator
  Scenario: GET linked loans should fail when company_id is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | allocation_month | overall |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be one of "400,401,403"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "invalid company id"

  @negative @creator @discuss
  Scenario: GET linked loans should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | 00000000-0000-0000-0000-000000000000 |
      | allocation_month | overall                              |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be one of "422"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "one or more companies not found"

  @negative @creator
  Scenario: GET linked loans should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | invalid-company-id |
      | allocation_month | overall            |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "Invalid company_id"
    
  @negative @creator @500
  Scenario: GET linked loans should fail when allocation_month does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                        |
      | allocation_month |   invalid_allocation_month                          |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 422
    And the response body should contain field "message" as "auto" with value "one or more companies not found"
  
