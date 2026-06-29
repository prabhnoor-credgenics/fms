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
    And the user variables success response should be valid

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
    And the user variables success response should be valid

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
    And the user variables success response should be valid

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
    And the user variables success response should be valid


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
