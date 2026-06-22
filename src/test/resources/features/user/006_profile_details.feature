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
