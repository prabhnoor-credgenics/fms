@api @user @roles-update
Feature: Roles — PATCH /user/roles/<role_id> (update role)



  @positive @smoke @creator @roles-write
  Scenario: Update a role's name returns 200
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
      { "role_name": "autoUpd{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoUpdated{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/roles_success_schema.json"
    And the roles success response should be valid

  @positive @creator @roles-write
  Scenario: Update a role's description returns 200
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
      { "role_name": "autoUpd{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_description": "updated by automation" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 200
    And the roles success response should be valid

  @negative @creator @roles-write
  Scenario: Update a role to report to itself returns 400
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
      { "role_name": "autoSelf{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "reports_to_role_id": "{VARIABLE_ID}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "A role cannot report to itself"

  @negative @auth @creator @roles-update
  Scenario: Update a role without authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept       | application/json |
      | Content-Type | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "x" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @creator @roles-write
  Scenario: Update a role with an empty body is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {}
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Update a role with a non-alphanumeric role_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | bad-role-id! |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid role_id provided"

  @negative @creator @roles-write
  Scenario: Update a syntactically-valid but unknown role_id returns 422
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | {RANDOM_STRING:16} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 422
    And the roles failure response should be valid

  # ---------------------------------------------------------------------------
  # Expanded coverage (auth, invalid field values/types, reserved name conflict,
  # company_id negatives, method/content-type, success envelope) — grounded in roles-crud-api-doc.md.
  # ---------------------------------------------------------------------------

  @negative @auth @creator @roles-update
  Scenario: Update a role with an invalid authentication token is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | not-a-real-token |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator @roles-write
  Scenario: Update a role with an empty role_name value returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Update a role with a non-alphanumeric role_name returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "man@ger#1" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @security @creator @roles-write
  Scenario: Update a role with special characters in role_name returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "role<name>{RANDOM_STRING:4}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @security @creator @roles-write
  Scenario: Update a role with a SQL injection attempt in role_name returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "x'; DROP TABLE roles;--" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Update a role with a wrong-length reports_to_role_id returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "reports_to_role_id": "short123" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Update a role with a non-alphanumeric reports_to_role_id returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "reports_to_role_id": "abcd!efgh12345_7" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Update a role with a wrong-length reports_to_user_id returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "reports_to_role_id": "{RANDOM_STRING:16}", "reports_to_user_id": "tooShort" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Update a role with an invalid tenant_type value returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}", "tenant_type": "invalidtype" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-write
  Scenario: Update a role to a reserved role_name returns 409
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
      { "role_name": "autoRsv{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "chief admin" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 409
    And the response body should not be empty

  @negative @company @creator @roles-write
  Scenario: Update a role without a company_id is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be one of "400,403"

  @negative @company @creator @roles-write
  Scenario: Update a role with an unknown company_id is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be one of "400,403"

  @negative @company @creator @roles-write
  Scenario: Update a role with an empty company_id is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id |  |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be one of "400,403"

  @negative @method @creator @roles-write
  Scenario: Update a role using an unsupported PUT method is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}" }
      """
    When I send a "PUT" request to "/user/roles/{role_id}"
    Then the response status code should be one of "404,405"

  @negative @creator @roles-write
  Scenario: Update a role with an unsupported content type is rejected
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | text/plain       |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be one of "400,415"

  @negative @creator @roles-write
  Scenario: Update a role with a malformed JSON body returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | abcd1234efgh5678 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoUpd{RANDOM_STRING:6}"
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator @roles-write
  Scenario: Update a role returns the documented success envelope
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
      { "role_name": "autoShape{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the path parameters:
      | role_id | {VARIABLE_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "autoShaped{RANDOM_STRING:6}" }
      """
    When I send a "PATCH" request to "/user/roles/{role_id}"
    Then the response status code should be 200
    And the response message should be "role updated successfully"
