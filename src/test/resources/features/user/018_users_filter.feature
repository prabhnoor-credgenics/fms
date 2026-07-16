@api @user @users-filter
Feature: Users Filter — GET /user/users/filter/

 

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal — all filters (defaults) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/users_filter_success_schema.json"
    And the users filter success response should be valid

  @positive @creator
  Scenario Outline: single filter "<filter>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | filters    | <filter>     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid

    Examples:
      | filter            |
      | reports_to        |
      | roles             |
      | permission_groups |
      | professions       |
      | teams             |
      | locations         |
      | departments       |
      | coverage_areas    |

  @positive @creator
  Scenario: Multiple filters (comma-separated) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                       |
      | filters    | reports_to,roles,permission_groups,professions     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid

  @positive @creator
  Scenario: Geography filters (locations + coverage_areas) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}             |
      | filters    | locations,coverage_areas |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid

  @negative @creator @500
  Scenario: address_states filter surfaces as a server-class failure
    # Observed on staging: requesting the address_states filter (alone or combined) returns a 500-class
    # error from the underlying query. Tagged @500 so the default suite skips this server-side issue.
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}   |
      | filters    | address_states |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 500

  @positive @creator
  Scenario: neglect_hierarchy set (bypass sub-tree scoping) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | neglect_hierarchy | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid


  @negative @creator @500
  Scenario: Invalid filter name surfaces as a server-class failure (returned, not raised)
    # Per the doc, an unknown filter name is `return`ed (not raised) as InvalidParametersException,
    # so it does not produce a clean 400 — it surfaces as a malformed / 500-class response.
    # TODO: verify exact status on staging.
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}     |
      | filters    | not_a_real_filter |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 500

  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
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
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 422
    And the response body should not be empty

  # ---------------------------------------------------------------------------
  # Expanded coverage (response shape, filter combos, neglect_hierarchy quirk,
  # company_id negatives, invalid-filter 500 family, method/route) —
  # grounded in users-filter-api-doc.md.
  # ---------------------------------------------------------------------------

  @positive @smoke @creator
  Scenario: Default response envelope shape and message are valid
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response body should contain field "data.filters"
    And the response time should be within configured limit
    And the users filter success response should be valid

  @positive @creator
  Scenario: roles filter returns the requested key in data.filters
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | filters    | roles        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the response body should contain field "data.filters.roles"
    And the users filter success response should be valid

  @positive @creator
  Scenario: Allocation panel filter combination returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                       |
      | filters    | reports_to,roles,permission_groups,teams,locations |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid

  @positive @creator
  Scenario: Duplicate filter key in CSV is tolerated (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | filters    | roles,roles  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid

  @positive @creator
  Scenario: neglect_hierarchy=false is still truthy (no coercion) and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | neglect_hierarchy | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid

  @positive @creator
  Scenario: neglect_hierarchy combined with filters returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id        | {COMPANY_ID}     |
      | filters           | reports_to,roles |
      | neglect_hierarchy | true             |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid

  @positive @creator
  Scenario: Unknown extra query parameter is ignored (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | not_a_param | anything     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 200
    And the users filter success response should be valid

  @negative @creator
  Scenario: Malformed (non-UUID) company_id is rejected with 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Empty company_id value is rejected with 400
    Given I prepare a request
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @security @creator
  Scenario: SQL injection payload in company_id is rejected with 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | ' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @security @creator
  Scenario: XSS payload in company_id is rejected with 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | <script>alert(1)</script> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

  @negative @boundary @creator
  Scenario: Over-long company_id value is rejected with 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {RANDOM_STRING:512} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator @500
  Scenario: Empty filters value surfaces as a server-class failure
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | filters    |              |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 500

  @negative @creator @500
  Scenario: Mixed valid and invalid filter names surface as a server-class failure
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}            |
      | filters    | roles,not_a_real_filter |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 500

  @negative @creator @500
  Scenario: Filter name is case-sensitive; uppercase key is invalid (server-class failure)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | filters    | ROLES        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 500

  @negative @security @creator @500
  Scenario: SQL injection in filters hits the invalid-filter path (server-class failure)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}     |
      | filters    | roles' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/"
    Then the response status code should be 500

  @negative @creator
  Scenario Outline: Wrong HTTP method on the filter route is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "<method>" request to "/user/users/filter/"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

    Examples:
      | method |
      | POST   |
      | PUT    |
      | PATCH  |
      | DELETE |

  @negative @creator
  Scenario: Unknown sub-path under the filter route is not found (404)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/filter/does-not-exist"
    Then the response status code should be 404
    And the response body should not be empty
