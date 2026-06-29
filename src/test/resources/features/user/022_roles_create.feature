@api @user @roles-create
Feature: Roles — POST /user/roles/ (create role)

 

  @positive @smoke @creator @roles-write
  Scenario: Create a role reporting to an existing role returns 201
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And I store response field "data.roles[0].role_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And the response should match json schema "schemas/user/success/roles_success_schema.json"
    And the role mutation response should be valid
    And the response body should contain field "data.role_id"

  @positive @creator @roles-write
  Scenario: Create a role with an optional description returns 201
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And I store response field "data.roles[0].role_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:8}", "role_description": "created by automation", "reports_to_role_id": "{MAPPING_ID}", "tenant_type": "company" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And the role mutation response should be valid

  @negative @auth @creator @roles-create
  Scenario: Create a role without authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept       | application/json |
      | Content-Type | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:6}", "reports_to_role_id": "abcd1234efgh5678" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @auth @creator @roles-create
  Scenario: Create a role with an invalid authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json    |
      | authenticationtoken | invalid_token_12345 |
      | Content-Type        | application/json    |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:6}", "reports_to_role_id": "abcd1234efgh5678" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @creator @roles-create
  Scenario: Create a role without company_id is rejected
    # Observed on staging: on the write path the permission check fires before org resolution, so a
    # missing company_id returns 403 (the GET list path returns 400 for the same omission).
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:6}", "reports_to_role_id": "abcd1234efgh5678" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 403
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Create a role with a malformed company_id is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | not-a-uuid |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:6}", "reports_to_role_id": "abcd1234efgh5678" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Create a role with an empty body is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario Outline: Create a role with invalid field "<case>" is rejected with 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the roles failure response should be valid

    Examples:
      | case                          | body                                                                  |
      | missing role_name             | { "reports_to_role_id": "abcd1234efgh5678" }                          |
      | missing reports_to_role_id    | { "role_name": "autoRoleX1" }                                          |
      | role_name empty string        | { "role_name": "", "reports_to_role_id": "abcd1234efgh5678" }         |
      | role_name non-alphanumeric    | { "role_name": "team@lead", "reports_to_role_id": "abcd1234efgh5678" }|
      | role_name special chars       | { "role_name": "<b>x</b>", "reports_to_role_id": "abcd1234efgh5678" } |
      | reports_to_role_id short      | { "role_name": "autoRoleX2", "reports_to_role_id": "short" }          |
      | reports_to_role_id non-alnum  | { "role_name": "autoRoleX3", "reports_to_role_id": "abcd-234-fgh-678" }|
      | tenant_type invalid enum      | { "role_name": "autoRoleX4", "reports_to_role_id": "abcd1234efgh5678", "tenant_type": "bogus" } |

  @negative @creator @roles-write
  Scenario: Create a role with a null role_name is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "placeholder", "reports_to_role_id": "abcd1234efgh5678" }
      """
    And I update JSON field "role_name" to null
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario Outline: Create a role with reserved name "<role_name>" is rejected with 409
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And I store response field "data.roles[0].role_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "<role_name>", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 409
    And the roles failure response should be valid

    Examples:
      | role_name     |
      | chief admin   |
      | super admin   |
      | company admin |

  @negative @creator @roles-write
  Scenario: Creating a role whose name already exists returns 409 (duplicate active role)
    # Collide against an already-existing role name (captured from the list) so the duplicate is
    # deterministic across runs; reports_to is a real accessible role id from the same list.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And I store response field "data.roles[0].role_id" as mapping id
    And I store response field "data.roles[0].role_name" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "{VARIABLE_ID}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 409
    And the roles failure response should be valid
