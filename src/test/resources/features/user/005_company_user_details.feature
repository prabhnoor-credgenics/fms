@api @user @company-user-details
Feature: Company User Details — GET /user/company/users/<user_id>



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Self lookup — fetch own user details returns 200
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/company_user_details_success_schema.json"
    And the company user details success response should be valid

  @positive @creator
  Scenario: Self lookup with descendants included returns 200
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | descendants | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the company user details success response should be valid

  @positive @creator
  Scenario: attributes query param (validated, ignored for single-user response) returns 200
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}                  |
      | attributes | name,email,mobile,role,profile |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the company user details success response should be valid

  @positive @creator
  Scenario: v2 alias path (/user/company-users/<user_id>) returns 200
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-users/{user_id}"
    Then the response status code should be 200
    And the company user details success response should be valid


  @negative @creator
  Scenario: Non-alphanumeric user_id returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | abc-123-xyz |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 400
    And the company user details failure response should be valid

  @negative @creator
  Scenario: Non-existent (valid alphanumeric) user_id returns 422
    Given I prepare a request
    And I set the path parameters:
      | user_id | {RANDOM_STRING:16} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 422
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid attributes value returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | attributes | not_a_real_attr   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 400
    And the company user details failure response should be valid


  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty
