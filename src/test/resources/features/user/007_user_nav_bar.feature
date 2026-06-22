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
    And the user nav bar success response should be valid


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
