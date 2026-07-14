@api @user @roles-list
Feature: Roles — GET /user/roles/ (list roles)

  

  @positive @smoke @creator @roles-list
  Scenario: List roles returns 200 with a roles array
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/roles_success_schema.json"
    And the roles list response should be valid

  @positive @approver @roles-list
  Scenario: List roles succeeds for a non-creator role (GET is permission-exempt)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And the roles list response should be valid

  @negative @auth @creator @roles-list
  Scenario: List roles without authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @auth @creator @roles-list
  Scenario: List roles with an invalid authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json    |
      | authenticationtoken | invalid_token_12345 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @creator @roles-list
  Scenario: List roles without company_id is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 400
    And the roles failure response should be valid

  @negative @creator @roles-list
  Scenario: List roles with a malformed company_id is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | not-a-uuid |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 400
    And the roles failure response should be valid

  @positive @performance @creator @roles-list
  Scenario: List roles responds within the time threshold
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  # ---------------------------------------------------------------------------
  # Expanded coverage (response shape, API-key auth, company_id negatives,
  # extra params, method/path) — grounded in roles-crud-api-doc.md.
  # ---------------------------------------------------------------------------

  @positive @schema @creator @roles-list
  Scenario: List roles response exposes the documented data.roles array
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response body should not be empty
    And the response body should contain field "data.roles"

  @positive @creator @roles-list
  Scenario: List roles returns the documented success message
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And the roles list response should be valid

  @positive @auth @api-key @roles-list
  Scenario: List roles succeeds when authenticated with the environment API key
    Given I authenticate using the API key and remember as "apiuser0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And the response body should contain field "data.roles"
    And the roles list response should be valid

  @negative @creator @roles-list
  Scenario: List roles with an empty company_id value is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id |  |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be one of "400,403"
    And the roles failure response should be valid

  @negative @creator @roles-list
  Scenario: List roles for a well-formed but unauthorized company_id is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {UUID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be one of "400,403,422"
    And the roles failure response should be valid

  @negative @security @injection @creator @roles-list
  Scenario: List roles with a SQL injection payload in company_id is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | ' OR '1'='1 |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be one of "400,403"
    And the roles failure response should be valid

  @negative @security @xss @creator @roles-list
  Scenario: List roles with an XSS payload in company_id is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | <script>alert(1)</script> |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @security @creator @roles-list
  Scenario: List roles with an over-long company_id is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {RANDOM_STRING:200} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be one of "400,403"
    And the roles failure response should be valid

  @negative @security @unicode @creator @roles-list
  Scenario: List roles with a unicode company_id is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 你好-мир-🎉 |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be one of "400,403"
    And the roles failure response should be valid

  @positive @creator @roles-list
  Scenario: List roles ignores unknown and unsupported query parameters
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | page       | 1            |
      | limit      | 5            |
      | foo        | bar          |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And the response body should contain field "data.roles"
    And the roles list response should be valid

  @negative @method @creator @roles-list
  Scenario: PUT is not allowed on the roles collection
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "PUT" request to "/user/roles/"
    Then the response status code should be one of "404,405"

  @negative @method @creator @roles-list
  Scenario: DELETE is not allowed on the roles collection
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "DELETE" request to "/user/roles/"
    Then the response status code should be one of "404,405"

  @edge @creator @roles-list
  Scenario: List roles without the trailing slash resolves or redirects consistently
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles"
    Then the response status code should be one of "200,301,308,404,405"
