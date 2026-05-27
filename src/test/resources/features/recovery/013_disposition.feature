Feature: Disposition API
  @positive1
  Scenario: Verify get disposition request
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response message should be "Dispositions Fetched"
    And the response should match json schema "schemas/recovery/success/recovery_get_disposition_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "data[0].id"
    And the response body should contain field "data[0].company_id"
    And the response body should contain field "data[0].name"
    And the response body should contain field "data[0].key"
    And the response body should contain field "data[0].sub_dispositions"
    And the response body should contain field "data[0].active"
