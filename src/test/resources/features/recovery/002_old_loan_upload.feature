@jjjapijhk @loan-recovery
Feature: Loan Recovery Old Loan Upload API

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | role                | admin |
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | replace_previous_data | false |
      | replace_given_data    | false |

  @smoke @positive
  Scenario: Create loan recovery record with valid data
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And the request body should match json schema "schemas/request/loan_upload_request_schema.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201
    And the response content type should be "application/json"
    And the response body should not be empty
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"

  @positive
  Scenario: Create loan recovery record with all required fields
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201
    And the response body should contain field "loan_id"
    And the response body should contain field "client_customer_id"

  @negative @validation
  Scenario: Create loan recovery record without authentication token
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I remove header "authenticationtoken"
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 401

  @negative @validation
  Scenario: Create loan recovery record without company_id query parameter
    Given I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 403

  @negative @validation
  Scenario: Create loan recovery record with missing required fields - loan_id
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body:
      """
      {
        "client_customer_id": "new",
        "loan_type": "Personal Loan",
        "applicant_name": "Test User"
      }
      """
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400

  @negative @validation
  Scenario: Create loan recovery record with invalid email format
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body:
      """
      {
        "loan_id": "{LOAN_ID}",
        "client_customer_id": "new",
        "loan_type": "Personal Loan",
        "applicant_name": "Test User",
        "applicant_email": "invalid-email-format"
      }
      """
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201

  @negative @validation
  Scenario: Create loan recovery record with invalid phone number
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body:
      """
      {
        "loan_id": "{LOAN_ID}",
        "client_customer_id": "new",
        "loan_type": "Personal Loan",
        "applicant_name": "Test User",
        "applicant_contact_number": "123"
      }
      """
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201

  @negative @validation
  Scenario: Create loan recovery record with invalid DOB format
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body:
      """
      {
        "loan_id": "{LOAN_ID}",
        "client_customer_id": "new",
        "loan_type": "Personal Loan",
        "applicant_name": "Test User",
        "applicant_dob": "24-11-1998"
      }
      """
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400

  @negative @validation
  Scenario: Create loan recovery record with negative loan amount
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body:
      """
      {
        "loan_id": "{LOAN_ID}",
        "client_customer_id": "new",
        "loan_type": "Personal Loan",
        "applicant_name": "Test User",
        "total_loan_amount": -50000
      }
      """
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201

  @negative @validation
  Scenario: Create loan recovery record with invalid CIBIL score range
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body:
      """
      {
        "loan_id": "{LOAN_ID}",
        "client_customer_id": "new",
        "loan_type": "Personal Loan",
        "applicant_name": "Test User",
        "applicant_cibil_score": 900
      }
      """
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201

  @edge-case
  Scenario: Create loan recovery record with empty document_details array
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "document_details" to "[]"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400

  @edge-case
  Scenario: Create loan recovery record with special characters in loan ID
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | loan-test-123!@# |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" to "loan-test-123!@#"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400

  @edge-case
  Scenario: Create loan recovery record with very long transaction ID
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {RANDOM_STRING:500} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" to "{RANDOM_STRING:500}"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400

  @edge-case
  Scenario: Create loan recovery record with multiple defaults
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201
    And the response body should contain field "defaults"

  @mandatory-variable @negative
  Scenario: Loan upload fails when mandatory allocation variable is_allocation_variable true is not provided, passes after marking non-mandatory
    Given I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autolnalloc{RANDOM_STRING:6}",
        "variable_type": "text",
        "is_allocation_variable": true,
        "is_mandatory": true
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | role                | admin            |
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | false        |
      | include_meta_data            | false        |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "autolnalloc{RANDOM_STRING:6}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "is_mandatory": false
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | role                | admin            |
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201

  @mandatory-variable @negative
  Scenario: Loan upload fails when mandatory non-allocation variable is_allocation_variable false is not provided, passes after marking non-mandatory
    Given I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autolnnon{RANDOM_STRING:6}",
        "variable_type": "text",
        "is_allocation_variable": false,
        "is_mandatory": true
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | role                | admin            |
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | false        |
      | include_meta_data            | false        |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "autolnnon{RANDOM_STRING:6}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "is_mandatory": false
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | role                | admin            |
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be 201