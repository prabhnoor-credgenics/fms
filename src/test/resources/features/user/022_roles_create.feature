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
    And the response body should contain field "message" as "auto" with value "invalid authentication token"

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
    And the response body should contain field "message" as "auto" with value "invalid authentication token"

  @negative @creator @roles-create
  Scenario: Create a role without company_id is rejected
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
    And the "roles" failure response should be valid

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
    And the "roles" failure response should be valid

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
    And the "roles" failure response should be valid

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
    And the "roles" failure response should be valid

    Examples:
      | case                         | body                                                                                            |
      | missing role_name            | { "reports_to_role_id": "abcd1234efgh5678" }                                                    |
      | missing reports_to_role_id   | { "role_name": "autoRoleX1" }                                                                   |
      | role_name empty string       | { "role_name": "", "reports_to_role_id": "abcd1234efgh5678" }                                   |
      | role_name non-alphanumeric   | { "role_name": "team@lead", "reports_to_role_id": "abcd1234efgh5678" }                          |
      | role_name special chars      | { "role_name": "<b>x</b>", "reports_to_role_id": "abcd1234efgh5678" }                           |
      | reports_to_role_id short     | { "role_name": "autoRoleX2", "reports_to_role_id": "short" }                                    |
      | reports_to_role_id non-alnum | { "role_name": "autoRoleX3", "reports_to_role_id": "abcd-234-fgh-678" }                         |
      | tenant_type invalid enum     | { "role_name": "autoRoleX4", "reports_to_role_id": "abcd1234efgh5678", "tenant_type": "bogus" } |

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
    And I update JSON field "role_name" as "null" to "null"
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the "roles" failure response should be valid

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
    And the "roles" failure response should be valid

    Examples:
      | role_name     |
      | chief admin   |
      | super admin   |
      | company admin |

  @negative @creator @roles-write
  Scenario: Creating a role whose name already exists returns 409 (duplicate active role)
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
    And the "roles" failure response should be valid


  @positive @creator @roles-write
  Scenario: Create a role with a valid non-default tenant_type returns 201
    Given I grant the current user all loan permissions
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
      { "role_name": "autoRole{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}", "tenant_type": "agency" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201

  @positive @creator @roles-write
  Scenario: Create a role with unknown extra fields ignores them and returns 201
    Given I grant the current user all loan permissions
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
      { "role_name": "autoRole{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}", "unknown_field": "x", "is_admin": true }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201

  @positive @creator @roles-write
  Scenario: Successful create exposes the documented response shape (data.role_id)
    Given I grant the current user all loan permissions
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
    And the response body should contain field "data.role_id"

  @negative @creator @roles-write
  Scenario: Create a role with a well-formed but non-existent reports_to_role_id is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:8}", "reports_to_role_id": "{RANDOM_STRING:16}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator @roles-write
  Scenario Outline: Create a role with reserved name "<role_name>" is rejected with 409
    Given I grant the current user all loan permissions
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
    Then the response status code should be one of "409,400"
    And the "roles" failure response should be valid

    Examples:
      | role_name  |
      | super user |
      | api user   |
      | co-admin   |

  @negative @security @creator @roles-write
  Scenario Outline: Create a role with injection/special role_name "<case>" is rejected with 400
    Given I grant the current user all loan permissions
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
    And the "roles" failure response should be valid

    Examples:
      | case           | body                                                                                    |
      | apostrophe     | { "role_name": "o'brien", "reports_to_role_id": "abcd1234efgh5678" }                    |
      | curly braces   | { "role_name": "role{admin}", "reports_to_role_id": "abcd1234efgh5678" }                |
      | question mark  | { "role_name": "role?name", "reports_to_role_id": "abcd1234efgh5678" }                  |
      | angle brackets | { "role_name": "role>name", "reports_to_role_id": "abcd1234efgh5678" }                  |
      | sql injection  | { "role_name": "role'; DROP TABLE roles;--", "reports_to_role_id": "abcd1234efgh5678" } |

  @negative @creator @roles-write
  Scenario Outline: Create a role with type/format violation "<case>" is rejected with 400
    Given I grant the current user all loan permissions
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
    Then the response status code should be one of "400,403"
    And the "roles" failure response should be valid

    Examples:
      | case                          | body                                                                                                    |
      | reports_to numeric            | { "role_name": "autoRoleTy1", "reports_to_role_id": 1234567890123456 }                                  |
      | reports_to boolean            | { "role_name": "autoRoleTy2", "reports_to_role_id": true }                                              |
      | reports_to null               | { "role_name": "autoRoleTy3", "reports_to_role_id": null }                                              |
      | reports_to_user_id short      | { "role_name": "autoRoleTy4", "reports_to_role_id": "abcd1234efgh5678", "reports_to_user_id": "short" } |
      | role_description leading char | { "role_name": "autoRoleTy5", "reports_to_role_id": "abcd1234efgh5678", "role_description": "=danger" } |

  @negative @creator @roles-write
  Scenario: Create a role with an empty company_id value is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id |  |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:6}", "reports_to_role_id": "abcd1234efgh5678" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be one of "400,403"
    And the "roles" failure response should be valid

  @negative @creator @roles-write
  Scenario: Create a role with a malformed JSON body is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:6}", "reports_to_role_id": "abcd1234efgh5678"
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator @roles-write
  Scenario: Create a role with an unsupported content-type is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | text/plain       |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:6}", "reports_to_role_id": "abcd1234efgh5678" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be one of "400,415"
    And the response body should not be empty

  @negative @creator @roles-write
  Scenario: Sending an unsupported HTTP method to the roles collection is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoRole{RANDOM_STRING:6}", "reports_to_role_id": "abcd1234efgh5678" }
      """
    When I send a "PUT" request to "/user/roles/"
    Then the response status code should be one of "404,405"

  @negative @boundary @creator @roles-write
  Scenario Outline: Create a role with borderline role_name "<case>" is server-dependent
    Given I grant the current user all loan permissions
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
    Then the response status code should be one of "201,400"

    Examples:
      | case            | role_name                                                                                               |
      | unicode letters | rôlé{RANDOM_STRING:4}                                                                                   |
      | over-long name  | autoRole{RANDOM_STRING:8}abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz |

@negative @validation @approver @roles-list
Scenario Outline: Role creation fails when role name contains non-alphanumeric characters
Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_role_name.json"
    And I update JSON field "role_name" as "auto" to "<role_name>"
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 400
    And the response should match json schema "schemas/user/error/role_create_validation_error_schema.json"
    And the response message should be "Assertion failed, must be alphanumeric"

Examples:
| role_name |
| 333# |
| **** |
| Admin!|
| Test$ |
| User% |
| Team& |
| Dev* |
| Role+ |
| Role= |
| Role? |
| Role/ |
| Role: |
| Role; |
| Role~ |
| Role` |
| Role. |

@negative @duplicate @approver @role-create 
Scenario Outline: Role creation fails when the role name already exists
Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_role_name.json"
    And I update JSON field "role_name" as "auto" to "<role_name>"
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 409
    And the response message should be "A role with provided name already exists, please provide a different name"

    Examples:
      | role_name |
      | role      |
      | role 1    |
      | role 11   |
      | role 111  |
      | role 112  |
      | role 12   |
      | role 111  |

  @positive @approver @role-hierarchy
  Scenario: Validate role hierarchy API response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |

    And I set the query parameters:
      | company_id | {COMPANY_ID} |

    When I send a "GET" request to "/user/roles/hierarchy"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/role_hierarchy_success_schema.json"
    And the response message should be "role hierarchy fetched successfully"