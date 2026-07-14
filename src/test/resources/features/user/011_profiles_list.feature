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

  @positive @creator @other-pod @500
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

  # ---------------------------------------------------------------------------
  # Expanded coverage (response shape, branch combos, boolean coercion, invalid
  # profile_type/company_id, method/path) — grounded in profiles-api-doc.md.
  # ---------------------------------------------------------------------------

  @positive @creator
  Scenario: Success response exposes documented shape (data.profiles, message)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response body should contain field "data.profiles"
    And the response body should contain field "message"
    And the profiles list success response should be valid

  @positive @creator
  Scenario: parent_company_id WITH profile_type stays in the default list branch returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | parent_company_id | {UUID}       |
      | profile_type      | self         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @positive @creator
  Scenario: masking_enabled_profiles combined with include_parent_company_profiles returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                      | {COMPANY_ID} |
      | masking_enabled_profiles        | true         |
      | include_parent_company_profiles | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @positive @creator @other-pod @500
  Scenario: Portfolio sub-branch with masking (parent_company_id, no profile_type) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id               | {COMPANY_ID} |
      | parent_company_id        | {UUID}       |
      | masking_enabled_profiles | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @positive @creator
  Scenario Outline: Explicit false boolean flag "<flag>"="<value>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | <flag>     | <value>      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

    Examples:
      | flag                            | value |
      | masking_enabled_profiles        | false |
      | include_parent_company_profiles | false |

  @positive @creator
  Scenario Outline: Non-"true" boolean-like value "<value>" is coerced to false returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | neglect_hierarchy | <value>      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

    Examples:
      | value |
      | 1     |
      | yes   |
      | TRUE  |

  @positive @creator
  Scenario: Unknown / extra query parameter is tolerated returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID}      |
      | bogus_extra_arg | {RANDOM_STRING:8} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @positive @creator
  Scenario: Content-Type header on a GET (no body) is tolerated returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @positive @creator
  Scenario: profile_type=shared combined with neglect_hierarchy=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | profile_type      | shared       |
      | neglect_hierarchy | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be 200
    And the profiles list success response should be valid

  @negative @security @creator
  Scenario Outline: Invalid profile_type "<profile_type>" returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id   | {COMPANY_ID}   |
      | profile_type | <profile_type> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

    Examples:
      | profile_type                                     |
      | SELF                                             |
      | Shared                                           |
      | self' OR '1'='1                                  |
      | <script>alert(1)</script>                        |
      | セルフ                                            |
      | selfselfselfselfselfselfselfselfselfselfselfself |

  @negative @creator
  Scenario Outline: Malformed / invalid company_id "<company_id>" is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | <company_id> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

    Examples:
      | company_id            |
      | not-a-uuid            |
      | 12345                 |
      | {COMPANY_ID}' OR '1=1 |

  @negative @creator
  Scenario: Empty company_id value is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario Outline: Unsupported HTTP method "<method>" on the collection URL is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "<method>" request to "/user/profiles/"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

    Examples:
      | method |
      | PUT    |
      | DELETE |

  @negative @creator
  Scenario: Collection path without trailing slash behaves per routing config
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles"
    Then the response status code should be one of "200,301,308,404"
    And the response body should not be empty
