@api @move-loan-restrictions @recovery
Feature: Move Loan Restriction

  Scenario: Verify get move loan restriction variables request
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","recovery_status":["fully recovered"],"global_status":["closed"],"is_move_loan_restriction_enabled":true}
      """
    When I send a "PUT" request to "/recovery/move-loan-restriction"
    Then the response status code should be 200
    And the response body should contain field "message" as "auto" with value "Move loans Setting saved successfully"
    And the response body should contain field "message_template" as "auto" with value "Move loans Setting saved successfully"
    And the response body should contain field "success" as "auto" with value "true"


  Scenario: Verify get move loan restriction variables request
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/move-loan-restriction"
    Then the response status code should be 200
    And the response message should be "data fetched successfully"
    And the response should match json schema "schemas/recovery/success/recovery_move_loan_restriction_success_schema.json"
    And the response body should contain field "success"
    And the response body should contain field "message"
    And the response body should contain field "data"
    And the response body should contain field "data.recovery_status"
    And the response body should contain field "data.recovery_status[0]"
    And the response body should contain field "data.global_status"
    And the response body should contain field "data.global_status[0]"
    And the response body should contain field "data.is_move_loan_restriction_enabled"
    And the response body should contain field "message_template"


  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/move-loan-restriction"
    Then the response status code should be 400
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "invalid company id"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/move-loan-restriction"
    Then the response status code should be 422
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "one or more companies not found"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/move-loan-restriction"
    Then the response status code should be 400
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "Invalid company_id"
  
