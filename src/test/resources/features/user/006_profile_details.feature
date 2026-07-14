@api @user @profile-details
Feature: Profile Details — GET /user/profiles/<profile_id>



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @creator @500
  Scenario: Fetch a profile's details (Branch B) returns 200
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/profile_details_success_schema.json"
    And the profile details success response should be valid


  @negative @creator
  Scenario Outline: Invalid profile_type "<profile_type>" returns 400
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}   |
      | profile_type | <profile_type> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 400
    And the profile details failure response should be valid

    Examples:
      | profile_type |
      | invalid      |
      | owner        |
      | 123          |


  @negative @creator
  Scenario: Unknown profile_id (Branch B, profile_type=self) returns 400
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | profile_type | self         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown profile_id (Branch B, profile_type=shared) returns 400
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | profile_type | shared       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown profile_id with is_api_endpoints_required (Branch A) returns 424
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id                | {COMPANY_ID} |
      | is_api_endpoints_required | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 424
    And the response body should not be empty


  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 400
    And the response body should not be empty

  # ---------------------------------------------------------------------------
  # Expanded coverage (auth, company_id, method, profile_type/flag variants,
  # profile_id injection, path quirks) — grounded in profiles-profile-id-api-doc.md.
  # ---------------------------------------------------------------------------

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-value |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "401,400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Malformed company_id is rejected
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Empty company_id value is rejected
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Foreign company_id (cross-company scoping) is rejected
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "403,400"
    And the response body should not be empty

  @negative @creator
  Scenario Outline: Unsupported HTTP method "<method>" on the item URL is rejected
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "<method>" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "405,404"
    And the response body should not be empty

    Examples:
      | method |
      | PUT    |
      | POST   |

  @negative @creator
  Scenario Outline: Case/whitespace-variant profile_type "<profile_type>" returns 400
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}   |
      | profile_type | <profile_type> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 400
    And the profile details failure response should be valid

    Examples:
      | profile_type |
      | SELF         |
      | SHARED       |
      | Self         |
      | shared_x     |

  @negative @creator
  Scenario Outline: is_api_endpoints_required="<flag>" switches to Branch A and returns dependency error
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id                | {COMPANY_ID} |
      | is_api_endpoints_required | <flag>       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "424,422"
    And the response body should not be empty

    Examples:
      | flag  |
      | false |
      | 1     |
      | 0     |
      | yes   |

  @negative @creator
  Scenario: Branch A combined with profile_type=shared returns dependency error
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id                | {COMPANY_ID} |
      | is_api_endpoints_required | true         |
      | profile_type              | shared       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "424,422"
    And the response body should not be empty

  @negative @security @creator
  Scenario Outline: Malformed/injection profile_id "<profile_id>" returns 400
    Given I prepare a request
    And I set the path parameters:
      | profile_id | <profile_id> |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "400,404"
    And the response body should not be empty

    Examples:
      | profile_id            |
      | ' OR '1'='1           |
      | <script>alert(1)</script> |
      | プロファイル             |
      | not a uuid at all     |
      | {RANDOM_STRING:512}   |

  @negative @creator
  Scenario: Unknown/list-only query params are ignored for the item fetch
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | parent_company_id | {UUID}       |
      | neglect_hierarchy | true         |
      | unknown_param     | foo          |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be one of "400,424"
    And the response body should not be empty

  @negative @creator
  Scenario: Trailing-slash item path still resolves (strict_slashes=False)
    Given I prepare a request
    And I set the path parameters:
      | profile_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/profiles/{profile_id}/"
    Then the response status code should be one of "400,404"
    And the response body should not be empty
