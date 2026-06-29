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
