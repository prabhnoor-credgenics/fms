@api @user @roles-delete
Feature: Roles — DELETE /user/roles/<role_id> (delete role)

  

  @positive @smoke @creator @roles-write
  Scenario: Delete a freshly created leaf role returns 200
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
      { "role_name": "autoDel{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/roles_success_schema.json"
    And the role mutation response should be valid

  @positive @multistep @creator @roles-write
  Scenario: Create then delete then re-delete the same role returns 422 on the second delete
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
      { "role_name": "autoDel2{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 200
    And the role mutation response should be valid
    # second delete of the now-inactive role -> no longer accessible -> 422
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 422
    And the roles failure response should be valid

  @negative @auth @creator @roles-delete
  Scenario: Delete a role without authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @creator @roles-write
  Scenario: Delete a role without company_id is rejected
    # Observed on staging: on the write path the permission check fires before org resolution, so a
    # missing company_id returns 403 (the GET paths return 400 for the same omission).
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 403
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Delete a role with a non-alphanumeric role_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | bad-role-id! |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid role_id provided"

  @negative @creator @roles-write
  Scenario: Delete a syntactically-valid but unknown role_id returns 422
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {RANDOM_STRING:16} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 422
    And the roles failure response should be valid

  # ---------------------------------------------------------------------------
  # Expanded coverage (dependents/assigned conflicts, role_id injection/boundary,
  # auth/company negatives, method/path, success envelope) — grounded in roles-crud-api-doc.md.
  # ---------------------------------------------------------------------------

  @negative @multistep @conflict @creator @roles-write
  Scenario: Delete a non-leaf role that has a child role reporting to it returns 409
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
      { "role_name": "autoParent{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoChild{RANDOM_STRING:8}", "reports_to_role_id": "{VARIABLE_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 409
    And the roles failure response should be valid

  @negative @multistep @conflict @creator @roles-write
  Scenario: Delete a role that is assigned to an active user returns 409
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
      { "role_name": "autoAssigned{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I create a company user assigned the created role
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 409
    And the roles failure response should be valid

  @negative @security @creator @roles-write
  Scenario: Delete a role with a SQL-injection style role_id returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | 1 OR 1=1; DROP TABLE roles;-- |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator @roles-write
  Scenario: Delete a role with a unicode role_id is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | rôleÜnicödé1234 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be one of "400,422"
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Delete a role with an over-long alphanumeric role_id returns 422
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {RANDOM_STRING:40} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 422
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Delete with an empty role_id collapses to the collection URL and is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id |  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be one of "404,405"

  @negative @auth @creator @roles-delete
  Scenario: Delete a role with an invalid authentication token is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json        |
      | authenticationtoken | not-a-real-token-000000 |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator @roles-write
  Scenario: Delete a role with a malformed company_id is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | not-a-valid-company-id |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be one of "400,403"
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Delete a role with an empty company_id value is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id |  |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be one of "400,403"
    And the roles failure response should be valid

  @negative @method @creator @roles-write
  Scenario: Using PUT on the role item URL is not allowed
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "PUT" request to "/user/roles/{role_id}"
    Then the response status code should be one of "404,405"

  @negative @creator @roles-write
  Scenario: Delete on the item URL with a trailing slash does not match the route
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}/"
    Then the response status code should be one of "308,404,405"

  @positive @creator @roles-write
  Scenario: Delete a freshly created leaf role returns the documented success envelope
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
      { "role_name": "autoDel{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/{role_id}"
    Then the response status code should be 200
    And the response message should be "role deleted successfully"
    And the response body should contain field "data.rowcount"
