@api @move-loan-restrictions @recovery
Feature: Move Loan Restriction

  Scenario: Verify get move loan restriction variables request
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
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
 #   And the response body should contain field "error"
    And the response body should contain field "message_template"
  #  And the response body should contain field "message_placeholder"
  
  
  
 @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                      |
    When I send a "GET" request to "/recovery/move-loan-restriction"
    Then the response status code should be one of "400,401,403,422"
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" with value "invalid company id"
  @negative @creator
  Scenario: API should fail when company_id does not exist
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | x-company-id        | 00000000-0000-0000-0000-000000000000 |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/move-loan-restriction"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/invalid_schema.json"
     And the response body should contain field "message" with value "forbidden: invalid company id"
  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | invalid-company-id                |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/move-loan-restriction"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/invalid_schema.json"
 And the response body should contain field "message" with value "Session expired, please login again"
  
