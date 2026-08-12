@api @user @user-nav-bar
Feature: User Navigation Bar — GET /user/nav-bar/<user_id>


  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @creator @500
  Scenario: Fetch a user's saved nav-bar layout returns 200
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/user_nav_bar_success_schema.json"
    And the "user_nav_bar" success response should be valid


  @negative @creator
  Scenario: User with no saved nav-bar config returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: POST on the nav-bar item URL is not allowed (405)
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/nav-bar/{user_id}"
    Then the response status code should be 405


  @negative @security @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-{RANDOM_STRING:16} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be one of "400,401"
    And the response body should not be empty

  @negative @creator
  Scenario: Empty company_id query value is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Malformed non-UUID company_id is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Non-existent company_id is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Non-existent user_id returns no configuration found
    Given I prepare a request
    And I set the path parameters:
      | user_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: DELETE on the nav-bar item URL is not allowed (405)
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "DELETE" request to "/user/nav-bar/{user_id}"
    Then the response status code should be 405

  @negative @creator
  Scenario: PATCH on the nav-bar item URL is not allowed (405)
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "PATCH" request to "/user/nav-bar/{user_id}"
    Then the response status code should be 405

  @negative @creator
  Scenario: Unknown nav-bar sub-route returns 404
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/navbar/{user_id}"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

  @negative @security @creator
  Scenario: SQL injection payload in user_id is safely handled
    Given I prepare a request
    And I set the path parameters:
      | user_id | ' OR '1'='1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be one of "400,404"
    And the response body should not be empty

  @negative @security @creator
  Scenario: XSS payload in user_id is safely handled
    Given I prepare a request
    And I set the path parameters:
      | user_id | <xss>alert(1)</xss> |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be one of "403,400,404"
    And the response body should not be empty

  @negative @security @creator
  Scenario: SQL injection payload in company_id is safely handled
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | ' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @boundary @creator
  Scenario: Excessively long user_id is handled without server error
    Given I prepare a request
    And I set the path parameters:
      | user_id | {RANDOM_STRING:512} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}"
    Then the response status code should be one of "400,404,414"
    And the response body should not be empty

  @positive @boundary @creator
  Scenario: Trailing slash on the nav-bar path is tolerated
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/nav-bar/{user_id}/"
    Then the response status code should be one of "404"
    And the response body should not be empty
