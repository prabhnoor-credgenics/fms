Feature: Payment Control 

  Scenario: Verify get payment control request
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
    When I send a "GET" request to "recovery/payment-controls"
    Then the response status code should be 200
  Then the response status code should be 200
And the response message should be "restriction details fetched"
And the response should match json schema "schemas/recovery_payment_controls_success_schema.json"
And the response body should contain field "success"
And the response body should contain field "message"
And the response body should contain field "message_template"
And the response body should contain field "message_placeholder"
And the response body should contain field "data"