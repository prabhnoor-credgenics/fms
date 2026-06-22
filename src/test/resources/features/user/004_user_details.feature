@api @user @user-details
Feature: User Details — GET /user/users/



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Fetch logged-in user details returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/user_details_success_schema.json"
    And the user details success response should be valid

  @positive @creator
  Scenario: Trailing-slash-insensitive path returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users"
    Then the response status code should be 200
    And the user details success response should be valid

  @positive @creator
  Scenario: Extraneous query param is ignored and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the user details success response should be valid

  @positive @creator
  Scenario: user_details carries the user_id field
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the response body should contain field "data.user_details.user_id"


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: POST on the collection URL is not allowed (405)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/users/"
    Then the response status code should be 405
