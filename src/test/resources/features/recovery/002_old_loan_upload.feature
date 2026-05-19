@jjjapijhk @loan-recovery
Feature: Loan Recovery Old Loan Upload API

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | role                | admin |
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN} |

  @smoke @positive
  Scenario: Create loan recovery record with valid data
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,201"
    And the response content type should be "application/json"
    And the response body should not be empty

  @positive
  Scenario: Create loan recovery record with all required fields
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,201"
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
    Then the response status code should be one of "401,403"

  @negative @validation
  Scenario: Create loan recovery record without company_id query parameter
    Given I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "400,422"

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
    Then the response status code should be one of "400,422"

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
    Then the response status code should be one of "400,422"

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
    Then the response status code should be one of "400,422"

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
    Then the response status code should be one of "400,422"

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
    Then the response status code should be one of "400,422"

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
    Then the response status code should be one of "400,422"

  @edge-case
  Scenario: Create loan recovery record with empty document_details array
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "document_details" to "[]"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,201,400"

  @edge-case
  Scenario: Create loan recovery record with special characters in loan ID
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | loan-test-123!@# |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,201,400"

  @edge-case
  Scenario: Create loan recovery record with very long transaction ID
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" to "{RANDOM_STRING:500}"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,201,400"

  @edge-case
  Scenario: Create loan recovery record with multiple defaults
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,201"
    And the response body should contain field "defaults"