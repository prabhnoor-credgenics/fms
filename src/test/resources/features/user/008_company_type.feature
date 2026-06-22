@api @user @company-type
Feature: Company Type — GET /user/company-type



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Fetch company types for the logged-in user returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/company_type_success_schema.json"
    And the company type success response should be valid

  @positive @creator
  Scenario: v2 alias path returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/v2/company-type"
    Then the response status code should be 200
    And the company type success response should be valid

  @positive @creator
  Scenario: Response carries the company_type list and success flag
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the response body should contain field "data.company_type"
    And the response body should contain field "success"
    And the company type success response should be valid

  @positive @creator
  Scenario: Extraneous query param is ignored and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 200
    And the company type success response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/company-type"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: POST on the company-type endpoint is not allowed (405)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/company-type"
    Then the response status code should be 405
