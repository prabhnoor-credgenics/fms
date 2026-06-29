@api @user @role-details
Feature: Roles — GET /user/roles/<role_id> (get one role)

  

  @positive @smoke @creator @role-details
  Scenario: Get a single role's details returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And I store response field "data.roles[0].role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/{role_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/roles_success_schema.json"
    And the role details response should be valid

  @negative @auth @creator @role-details
  Scenario: Get role details without authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @auth @creator @role-details
  Scenario: Get role details with an invalid authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json    |
      | authenticationtoken | invalid_token_12345 |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @creator @role-details
  Scenario: Get role details without company_id is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    When I send a "GET" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @role-details
  Scenario: Get role details with a non-alphanumeric role_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | bad-role-id! |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid role_id provided"

  @negative @creator @role-details
  Scenario: Get role details for a syntactically-valid but unknown role_id returns 422
    # TODO: verify on staging — validate_role_id_argument rejects inaccessible/unknown ids with 422
    # "role not found" (a found-but-empty fetch could instead surface as 500 per the source note).
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {RANDOM_STRING:16} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/{role_id}"
    Then the response status code should be 422
    And the roles failure response should be valid
