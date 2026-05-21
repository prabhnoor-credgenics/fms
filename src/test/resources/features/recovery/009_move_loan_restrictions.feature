Feature: Move Loan Restriction

  Scenario: Verify get move loan restriction variables request
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
    When I send a "GET" request to "recovery/move-loan-restriction"
    Then the response status code should be 200
    And the response message should be "data fetched successfully"
    And the response should match json schema "schemas/recovery_move_loan_restriction_success_schema.json"
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
