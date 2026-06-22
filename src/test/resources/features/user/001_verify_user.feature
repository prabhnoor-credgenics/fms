@api @user @verify-user
Feature: Verify User — GET /user/public/verify/user/



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal platform token verification returns 200
    Given I prepare a request
    And I set the query parameters:
      | auth_token | {AUTH_TOKEN} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/verify_user_success_schema.json"
    And the verify user success response should be valid

  @positive @creator
  Scenario: Token verification scoped to a company returns 200
    Given I prepare a request
    And I set the query parameters:
      | auth_token | {AUTH_TOKEN} |
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 200
    And the verify user success response should be valid
    And the response body should contain field "company_details"

  @positive @creator
  Scenario: Kong call authorizing a downstream endpoint (api_endpoint + api_method) returns 200
    Given I prepare a request
    And I set the query parameters:
      | auth_token | {AUTH_TOKEN} |
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN}        |
      | referer             | abc                 |
      | api_endpoint        | recovery/all-loans  |
      | api_method          | GET                 |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 200
    And the verify user success response should be valid

  @positive @creator
  Scenario: is_test_request truthy (suppresses session reset) returns 200
    Given I prepare a request
    And I set the query parameters:
      | auth_token      | {AUTH_TOKEN} |
      | company_id      | {COMPANY_ID} |
      | is_test_request | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 200
    And the verify user success response should be valid

  @positive @creator
  Scenario: All optional inputs together returns 200
    Given I prepare a request
    And I set the query parameters:
      | auth_token      | {AUTH_TOKEN}       |
      | key_name        | authentication_token |
      | company_id      | {COMPANY_ID}       |
      | is_test_request | true               |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN}        |
      | referer             | abc                 |
      | api_endpoint        | recovery/all-loans  |
      | api_method          | GET                 |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 200
    And the verify user success response should be valid


  @positive @creator
  Scenario Outline: Attribute lookup by "<key_name>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | key_name   | <key_name>   |
      | key_value  | <key_value>  |
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 200
    And the verify user success response should be valid

    Examples:
      | key_name | key_value                                       |
      | email    | testapiautomationusersrole11@yopmail.com        |
      | user_id  | {USER_ID:creator0}                              |


  @negative @creator
  Scenario: Missing auth_token with default key_name is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 400
    And the verify user failure response should be valid

  @negative @creator
  Scenario: key_name != authentication_token with empty key_value returns 400
    Given I prepare a request
    And I set the query parameters:
      | key_name   | email        |
      | key_value  |              |
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 400
    And the verify user failure response should be valid

  @negative @creator
  Scenario: Non-UUID auth_token (authentication_token flow) returns 400
    Given I prepare a request
    And I set the query parameters:
      | auth_token | not-a-uuid   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 400
    And the verify user failure response should be valid

  @negative @creator
  Scenario: Invalid (non-UUID) company_id returns 400
    Given I prepare a request
    And I set the query parameters:
      | auth_token | {AUTH_TOKEN} |
      | company_id | not-a-uuid   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 400
    And the verify user failure response should be valid

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | auth_token | {AUTH_TOKEN} |
      | company_id | {UUID}       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/public/verify/user/"
    Then the response status code should be 400
    And the response body should not be empty
