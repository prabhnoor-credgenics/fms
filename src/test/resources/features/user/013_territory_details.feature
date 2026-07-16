@api @user @territory-details
Feature: Territory Details — POST /user/territory/details



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @negative @creator
  Scenario: Empty body is rejected (400)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator
  Scenario: Pagination returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_number": 2, "page_size": 50 }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario Outline: disable_paging=<flag> returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "disable_paging": <flag> }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

    Examples:
      | flag  |
      | true  |
      | false |

  @positive @creator
  Scenario: Search by code returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "code", "search_value": "MH-01" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Search by name returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "name", "search_value": "mumbai" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Filters state + zone returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "filters": { "state": ["maharashtra", "gujarat"], "zone": ["west"] } }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: territory_type_ids + territory_codes returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "territory_codes": ["MH-01", "GJ-02"] }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: columns projection returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "columns": ["code", "name", "state", "zone"] }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario Outline: disable_formatting=<flag> returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "disable_formatting": <flag> }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

    Examples:
      | flag  |
      | true  |
      | false |

  @positive @creator
  Scenario Outline: neglect_territory_hierarchy=<flag> returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "neglect_territory_hierarchy": <flag> }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

    Examples:
      | flag  |
      | true  |
      | false |

  @positive @creator
  Scenario: fetch_descendants with code search returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "fetch_descendants": true, "search_key": "code", "search_value": "MH-01" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid



  @negative @creator
  Scenario: Only search_key (no search_value) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "code" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid

  @negative @creator
  Scenario: Invalid search_key returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "pincode", "search_value": "400001" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid

  @negative @creator
  Scenario: fetch_descendants without search returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "fetch_descendants": true }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid

  @negative @creator
  Scenario: fetch_descendants with name search returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "fetch_descendants": true, "search_key": "name", "search_value": "mumbai" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid

  @negative @creator
  Scenario: Invalid columns returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "columns": ["code", "not_a_real_column"] }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid

  @negative @boundary @creator
  Scenario: page_size over 5000 returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_size": 5001 }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: GET on the territory/details endpoint is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/territory/details"
    Then the response status code should be 405

  # ---------------------------------------------------------------------------
  # Expanded coverage (filters, pagination boundary, response shape, injection,
  # validation negatives, method/path) — grounded in territory-details-api-doc.md.
  # ---------------------------------------------------------------------------

  @positive @creator
  Scenario: Filter by parent_territory_code returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "filters": { "parent_territory_code": ["{UUID}"] } }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Filter by territory_type_ids returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "territory_type_ids": ["{UUID}"] }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Combined pagination + state/zone filter + columns returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_number": 1, "page_size": 50, "filters": { "state": ["maharashtra"], "zone": ["west"] }, "columns": ["code", "name", "state", "zone"] }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Interservice fetch_descendants unpaginated + unformatted returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "fetch_descendants": true, "search_key": "code", "search_value": "MH-01", "disable_paging": true, "disable_formatting": true }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Admin export neglect_territory_hierarchy + disable_paging + territory_type_ids returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "neglect_territory_hierarchy": true, "disable_paging": true, "territory_type_ids": ["{UUID}"] }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Unknown/extra body fields are ignored (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_size": 5, "not_a_real_field": "should_be_ignored", "another_unknown": 123 }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @boundary @creator
  Scenario: page_size exactly at max 5000 returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_size": 5000 }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @boundary @creator
  Scenario: High page_number beyond available data returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_number": 999999, "page_size": 10 }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Search value matching nothing returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "code", "search_value": "ZZ-NO-SUCH-CODE-99999" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Default success response carries the expected message
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the response message should be "Territory details fetched successfully."

  @positive @creator
  Scenario: fetch_descendants response names the searched code in its message
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "fetch_descendants": true, "search_key": "code", "search_value": "MH-01" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the response body should contain text "All descendants of territory"

  @positive @creator
  Scenario: Success response content type is JSON
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the response content type should be "application/json"

  @positive @security @creator
  Scenario: SQL injection in search_value is treated as a literal (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "name", "search_value": "' OR '1'='1" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @security @creator
  Scenario: XSS payload in search_value is handled safely (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "name", "search_value": "<script>alert(1)</script>" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @creator
  Scenario: Unicode search_value is accepted (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "name", "search_value": "मुंबई" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @positive @boundary @creator
  Scenario: Very long search_value is accepted (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "name", "search_value": "{RANDOM_STRING:600}" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the territory details success response should be valid

  @negative @creator
  Scenario: Only search_value (no search_key) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_value": "MH-01" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid

  @negative @creator
  Scenario: Whitespace-only search_value is rejected (400)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_key": "code", "search_value": "   " }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid

  @negative @creator
  Scenario: fetch_descendants=true with search_key=code but no search_value returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "fetch_descendants": true, "search_key": "code" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the territory details failure response should be valid

  @negative @creator
  Scenario: Malformed JSON body is rejected (400)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_number": 2, }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Non-numeric page_size is rejected (400)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_size": "abc" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Wrongly typed filters object is rejected (400)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "filters": "west" }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Non-existent (random) company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Malformed company_id value is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario Outline: <method> on territory/details is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "<method>" request to "/user/territory/details"
    Then the response status code should be 405

    Examples:
      | method |
      | PUT    |
      | DELETE |
      | PATCH  |

  @negative @creator
  Scenario: Trailing slash on the endpoint path
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/territory/details/"
    Then the response status code should be one of "200,404,405"

  @negative @creator
  Scenario: Unsupported content-type body is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | text/plain   |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "page_size": 5 }
      """
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be one of "400,415"
    And the response body should not be empty
