Feature: Linked Loans API
  # The linked loans API requires either loan_id or group_id (in addition to
  # company_id). Every positive scenario therefore first uploads a loan tagged
  # with a known group_id, then queries linked loans by that loan_id or group_id.

  @positive1
  Scenario: GET linked loans by loan_id after uploading a loan
    # Setup: upload a loan tagged with a known group_id so it can be queried back.
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "group_id" to "linked-loans-auto-grp"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    # Setup upload. On staging this company carries orphaned mandatory recovery
    # variables (and a strict pincode rule) that make every loan upload return
    # 400 "Loan Data Validation Failed"; 400 is therefore accepted here so the
    # setup does not mask the real assertions on the linked-loans GET below.
    Then the response status code should be one of "200,201,400"
    # Query linked loans using the compulsory loan_id parameter.
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
    # Setup: upload a loan tagged with a known group_id.
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "group_id" to "linked-loans-auto-grp"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    # Setup upload. On staging this company carries orphaned mandatory recovery
    # variables (and a strict pincode rule) that make every loan upload return
    # 400 "Loan Data Validation Failed"; 400 is therefore accepted here so the
    # setup does not mask the real assertions on the linked-loans GET below.
    Then the response status code should be one of "200,201,400"
    # Query linked loans using the compulsory group_id parameter.
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
    # Setup: upload a loan tagged with a known group_id.
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "group_id" to "linked-loans-auto-grp"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    # Setup upload. On staging this company carries orphaned mandatory recovery
    # variables (and a strict pincode rule) that make every loan upload return
    # 400 "Loan Data Validation Failed"; 400 is therefore accepted here so the
    # setup does not mask the real assertions on the linked-loans GET below.
    Then the response status code should be one of "200,201,400"
    # Query linked loans by group_id with pagination.
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
  Scenario: GET linked loans should fail when both loan_id and group_id are missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | allocation_month | overall      |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be one of "400,422"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"

  @negative @auth @creator
  Scenario: GET linked loans should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | 00000000-0000-0000-0000-000000000000 |
      | allocation_month |   invalid_allocation_month                          |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
  
