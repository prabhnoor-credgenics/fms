@api @user @roles-list
Feature: Roles — POST /user/roles/ (Invalid_User_Role_Creation)


Background:
    Given I authenticate as "approver" slot 0 and remember as "approver0"


@negative @validation @approver @roles-list
Scenario Outline: Role creation fails when role name contains non-alphanumeric characters

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
      | role 12  |
      | role 111  |

    @positive@api @approver @role-hierarchy
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