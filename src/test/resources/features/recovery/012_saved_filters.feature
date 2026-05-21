Feature: Saved Filter API
  @positive1
  Scenario: Verify get saved filter request
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
    When I send a "GET" request to "/recovery/saved/filters"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery_saved_filter_api_schema.json"
 And the response body should contain field "output"
And the response body should contain field "message"
And the response body should contain field "message_template"
And the response body should contain field "message_placeholder"
And the response body should contain field "output[0].id"
And the response body should contain field "output[0].filter_name"
And the response body should contain field "output[0].created_by"
And the response body should contain field "output[0].filters"
And the response body should contain field "output[0].filters.loan_type"
And the response body should contain field "output[0].filters.product_type"