Feature: Linked Loans API

  @positive1
  Scenario: GET linked loans with required params
    Given I prepare a request
    And I set the request headers:
       | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | allocation_month | 2026-4-01    |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/linked_loans_success_schema.json"
    And the response body should contain field "output"

  @positive
  Scenario: GET linked loans with allocation_month=overall
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                         |
      | allocation_month | overall                              |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/linked_loans_success_schema.json"
    And the response body should contain field "output"

  @positive
  Scenario: GET linked loans with pagination params
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                         |
      | allocation_month | overall                              |
      | page_number      |                                    1 |
      | page_size        |                                   10 |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/linked_loans_success_schema.json"
    And the response body should contain field "output"

  @negative @auth @creator
  Scenario: GET linked loans should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                         |
      | allocation_month | overall                              |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 422
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @auth @creator
  Scenario: GET linked loans should fail with invalid authentication token
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                         |
      | allocation_month | overall                              |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be one of "401,403"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"

  @negative @creator
  Scenario: GET linked loans should fail when company_id is missing
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | allocation_month | overall |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be one of "400,401,403"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "invalid company id"

  @negative @creator @discuss
  Scenario: GET linked loans should fail when company_id does not exist
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | 00000000-0000-0000-0000-000000000000 |
      | allocation_month | overall                              |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be one of "401,403"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message"

  @negative @creator
  Scenario: GET linked loans should fail when company_id is invalid UUID format
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | invalid-company-id |
      | allocation_month | overall            |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "invalid authentication token"
    
      @negative @creator @bug
    Scenario: GET linked loans should fail when allocation_month does not exist
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | 00000000-0000-0000-0000-000000000000 |
      | allocation_month |   invalid_allocation_month                          |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
  
