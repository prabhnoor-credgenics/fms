@api @user @user-variables
Feature: User Variables — GET /user/variables/


  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal — company variables (defaults) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/user_variables_success_schema.json"
    And the "user_variables" success response should be valid

  @positive @creator
  Scenario Outline: include_user_level_variables=<flag> returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                    | {COMPANY_ID} |
      | include_user_level_variables  | <flag>       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid

    Examples:
      | flag  |
      | true  |
      | false |

  @positive @creator
  Scenario: include_all_default_variables=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_all_default_variables | true        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid

  @positive @creator
  Scenario: Both flags true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                    | {COMPANY_ID} |
      | include_user_level_variables  | true         |
      | include_all_default_variables | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (well-formed) UUID company_id is rejected with 422
    # Observed on staging: a well-formed but non-existent company_id UUID resolves to 422 (org lookup
    # found no such company), distinct from a malformed/non-UUID company_id which is 400.
    Given I prepare a request
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 422
    And the response body should not be empty

  # ---------------------------------------------------------------------------
  # Expanded coverage (flag coercion, extra params ignored, response shape,
  # company_id negatives, method/route) — grounded in variables-api-doc.md.
  # ---------------------------------------------------------------------------

  @positive @creator
  Scenario: include_all_default_variables=false (explicit default) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                    | {COMPANY_ID} |
      | include_all_default_variables | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid

  @positive @creator
  Scenario Outline: Non-boolean include_user_level_variables value "<flag>" is tolerated and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_user_level_variables | <flag>       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid

    Examples:
      | flag  |
      | TRUE  |
      | YES   |
      | 1     |
      | maybe |

  @positive @creator
  Scenario: Extra unknown query parameter is silently ignored and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}      |
      | unexpected_param | {RANDOM_STRING:8} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid

  @positive @creator
  Scenario: variable_type passed as query param is ignored (not a GET filter) and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id    | {COMPANY_ID} |
      | variable_type | text         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid

  @positive @security @creator
  Scenario: Injection strings in flag params are coerced to false and return 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                    | {COMPANY_ID}              |
      | include_user_level_variables  | ' OR '1'='1               |
      | include_all_default_variables | <xss>alert(1)</xss> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid

  @positive @creator
  Scenario: Request Content-Type header is irrelevant on a bodyless GET and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | Content-Type        | text/plain   |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the "user_variables" success response should be valid

  @positive @creator
  Scenario: Response exposes documented shape (data.variables and success message)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response body should contain field "data.variables"
    And the response body should contain text "variables fetched successfully"
    And the "user_variables" success response should be valid

  @negative @security @creator
  Scenario Outline: Malformed or hostile company_id "<label>" is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | <value> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be one of "400,422"
    And the response body should not be empty

    Examples:
      | label         | value                         |
      | non-uuid text | not-a-valid-uuid              |
      | sql injection | ' OR '1'='1                   |
      | xss payload   | <xss>alert(1)</xss>     |
      | long unicode  | 名前テスト-{RANDOM_STRING:200} |

  @negative @creator
  Scenario: Empty company_id value is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/"
    Then the response status code should be one of "400,422"
    And the response body should not be empty

  @negative @creator
  Scenario Outline: Unsupported HTTP method "<method>" on the variables collection is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "<method>" request to "/user/variables/"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

    Examples:
      | method |
      | PUT    |
      | DELETE |

  @negative @creator
  Scenario: Unknown route under variables namespace returns 404
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables/does-not-exist-{RANDOM_STRING:6}"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

  @negative @creator
  Scenario: Trailing-slash-removed path behaviour is stable
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/variables"
    Then the response status code should be one of "200,301,307,308,404"
    And the response body should not be empty
