@api @regression @p1 @loan-update @recovery
Feature: Loan Update via API — PATCH /recovery/loan/<loan_id>

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
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @positive @creator
  Scenario: TC_LUU_011 — Update loan variables through the API
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
      { "source": "platform", "applicant_name": "Updated API Applicant", "loan_amount": 125000 }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/loan_update_success_schema.json"
    And the "loan_update" success response should be valid
