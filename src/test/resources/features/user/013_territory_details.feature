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
