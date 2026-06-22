@api @loan-update @recovery
Feature: Loan Update — PATCH /recovery/loan/<loan_id>



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And scenario loan id is unique
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201



  @positive @smoke @creator
  Scenario: Update a single applicant variable returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/loan_update_success_schema.json"
    And the loan update success response should be valid

  @positive @creator
  Scenario: Update multiple loan variables returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar", "loan_amount": 100000 }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the loan update success response should be valid

  @positive @creator
  Scenario: Update defaults (allocation-month-keyed records) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "defaults": [ { "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}", "pos": 75000 } ] }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the loan update success response should be valid

  @positive @creator
  Scenario: Update applicant_address (list) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_address": [ { "address_line": "12 MG Road", "city": "Pune", "state": "maharashtra", "pincode": "411001" } ] }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the loan update success response should be valid

  @positive @creator
  Scenario: append=true appends list items returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | append     | true         |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_address": [ { "address_line": "5 Residency Rd", "city": "Mumbai", "state": "maharashtra", "pincode": "400001" } ] }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the loan update success response should be valid

  @positive @creator
  Scenario: append=false (explicit) replaces list fields returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | append     | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Suresh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the loan update success response should be valid

  @negative @creator
  Scenario: Empty body {} is rejected returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 400
    And the loan update failure response should be valid

  @positive @creator
  Scenario: Unknown extra variable is tolerated returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar", "totally_unknown_variable_xyz": "whatever" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the loan update success response should be valid

  @positive @creator
  Scenario Outline: source value "<source>" is accepted (enum check is disabled in service) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "<source>", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200

    Examples:
      | source               |
      | platform             |
      | quick_upload         |
      | quick_update         |
      | calling-service      |
      | communication-service|
      | legal-service        |
      | notice-service       |
      | fos-service          |
      | fos_app              |
      | upload_excel         |
      | update_excel         |
      | upload               |
      | api                  |
      | bulk_api_encr        |
      | unknown              |
      | priority_queue       |
      | totally_made_up      |

  @positive @creator
  Scenario Outline: append is parsed leniently — value "<value>" still returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | append     | <value>      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200

    Examples:
      | value            |
      | true             |
      | false            |
      | TRUE             |
      | 1                |
      | 0                |
      | yes              |
      | maybe            |
      | {RANDOM_STRING:6}|

  @positive @creator @multistep
  Scenario: Update then read back reflects the new value (PATCH then GET) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "ReadBackName Verify" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the loan update success response should be valid
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 200
    And the response body should contain text "ReadBackName Verify"


  @negative @creator
  Scenario: Updating a non-existent loan returns 400 (loan not found)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | NONEXISTENT-LOAN-9999 |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 400
    And the loan update failure response should be valid

  @positive @creator
  Scenario: Invalid variable value is dropped, nothing left to update returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "loan_amount": "not-a-number" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the loan update success response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json                                  |
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected (insufficient access rights)
    Given I prepare a request
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "Ramesh Kumar" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: DELETE on the loan endpoint is not allowed (405)
    Given I prepare a request
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "DELETE" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 405
