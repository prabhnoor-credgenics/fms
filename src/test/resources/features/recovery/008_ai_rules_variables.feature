Feature: AI Rules Variables
  @positive1
  Scenario: Verify AI rules variables request
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id                    | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | exclude_non_ai                | true                                 |
      | only_customer_level_variables | False                                |
    When I send a "GET" request to "recovery/ai-rules/variables"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_success_schema.json"
And the response body should contain field "output"
And the response body should contain field "output[0].variable"
And the response body should contain field "output[0].variable_type"
And the response body should contain field "output[0].is_default"
And the response body should contain field "output[0].variable_category"
And the response body should contain field "output[0].type"
And the response body should contain field "output[0].operators"
And the response body should contain field "output[0].operators[0]"
And the response body should contain field "message"
And the response body should contain field "message_template"
And the response body should contain field "message_placeholder"