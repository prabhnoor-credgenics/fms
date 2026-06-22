@api @user @profiles-list
Feature: Profiles List — GET /user/profiles/



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"



  @positive @smoke @creator
  Scenario: Minimal (company_id only) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/profiles_list_success_schema.json"
    And the profiles list success response should be valid

  @positive @creator
  Scenario Outline: profile_type "<profile_type>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id   | {COMPANY_ID}   |
      | profile_type | <profile_type> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

    Examples:
      | profile_type |
      | self         |
      | shared       |

  @positive @creator
  Scenario Outline: neglect_hierarchy=<flag> returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | neglect_hierarchy | <flag>       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

    Examples:
      | flag  |
      | true  |
      | false |

  @positive @creator
  Scenario: masking_enabled_profiles=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id               | {COMPANY_ID} |
      | masking_enabled_profiles | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @positive @creator
  Scenario: include_parent_company_profiles=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                       | {COMPANY_ID} |
      | include_parent_company_profiles  | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @positive @creator
  Scenario: Combined self profiles, hierarchy ignored, parent profiles returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                      | {COMPANY_ID} |
      | profile_type                    | self         |
      | neglect_hierarchy               | true         |
      | include_parent_company_profiles | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @positive @creator @other-pod
  Scenario: Portfolio sub-branch (parent_company_id set, no profile_type) returns a map
    Given I prepare a request
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | parent_company_id | {UUID}       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid


  @negative @creator
  Scenario: Invalid profile_type returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | profile_type | bogus        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 400
    And the profiles list failure response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 400
    And the response body should not be empty
