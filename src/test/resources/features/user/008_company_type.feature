@api @user @company-type
Feature: Company Type — GET /user/company-type


  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Fetch company types for the logged-in user returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/company_type_success_schema.json"
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: v2 alias path returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/v2/company-type"
    Then the response status code should be 200
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Response carries the company_type list and success flag
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the response body should contain field "data.company_type"
    And the response body should contain field "success"
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Extraneous query param is ignored and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the "company_type" success response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: POST on the company-type endpoint is not allowed (405)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/company-type"
    Then the response status code should be 405


  @positive @creator
  Scenario: Response envelope exposes the caller identity fields
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the response body should contain field "data.user_id"
    And the response body should contain field "data.name"
    And the response body should contain field "data.user_type"
    And the response body should contain field "data.user_level"
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Response carries the standard envelope fields id, message and error_code
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the response body should contain field "id"
    And the response body should contain field "message"
    And the response body should contain field "success"
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Success message field is "success"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the response body should contain field "message" as "auto" with value "success"
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Response content type is application/json
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the response content type should be "application/json"

  @positive @creator
  Scenario: v2 alias response matches the success json schema
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/v2/company-type"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/company_type_success_schema.json"
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: v2 alias carries the company_type list and success flag
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/v2/company-type"
    Then the response status code should be 200
    And the response body should contain field "data.company_type"
    And the response body should contain field "success"
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Multiple unknown query params are ignored and return 200
    Given I prepare a request
    And I set the query parameters:
      | foo    | bar          |
      | limit  | 10           |
      | fields | company_type |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the "company_type" success response should be valid

  @positive @boundary @creator
  Scenario: Very long extraneous query param value is tolerated and returns 200
    Given I prepare a request
    And I set the query parameters:
      | note | {RANDOM_STRING:512} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Unicode extraneous query param value is tolerated and returns 200
    Given I prepare a request
    And I set the query parameters:
      | label | 公司类型-测试-ñç |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the "company_type" success response should be valid

  @positive @security @creator
  Scenario: SQL injection in an extraneous query param is ignored and returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | ' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 400
    And the "company_type" success response should be valid

  @positive @security @creator
  Scenario: XSS payload in an extraneous query param is ignored and returns 403
    Given I prepare a request
    And I set the query parameters:
      | q | <xss>alert(1)</xss> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 403
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Unknown extra request header is tolerated and returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | X-Custom-Header     | anything     |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the "company_type" success response should be valid

  @positive @creator
  Scenario: Content-Type header on a bodyless GET is tolerated and returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN}    |
      | Content-Type        | application/xml |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the "company_type" success response should be valid

  @negative @creator
  Scenario: v2 alias with missing authenticationtoken is rejected
    Given I prepare a request
    When I send a "GET" request to "/user/v2/company-type"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: v2 alias with invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/v2/company-type"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario Outline: Unsupported HTTP method "<method>" on company-type is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "<method>" request to "/user/company-type"
    Then the response status code should be one of "405,404"
    And the response body should not be empty

    Examples:
      | method |
      | PUT    |
      | PATCH  |
      | DELETE |

  @negative @creator
  Scenario: PUT on the v2 alias is not allowed
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "PUT" request to "/user/v2/company-type"
    Then the response status code should be one of "405,404"
    And the response body should not be empty

  @negative @creator
  Scenario: Trailing slash on company-type path
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type/"
    Then the response status code should be one of "200,404,405,308"
    And the response body should not be empty

  @negative @creator
  Scenario: Item subpath under a collection-only URL is not found
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type/{COMPANY_ID}"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown sibling route is not found
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-typo"
    Then the response status code should be one of "404,405"
    And the response body should not be empty
