@api @user @assigned-companies
Feature: Assigned Companies — GET /user/companies/<user_id>

  Background: 
    Given I authenticate as "creator" slot 0 and remember as "creator0"

  @positive @smoke @creator
  Scenario: Self lookup (own user_id) returns 200
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/assigned_companies_success_schema.json"
    And the assigned companies success response should be valid

  @positive @creator
  Scenario: Self lookup with source=delete_user returns 200
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the query parameters:
      | source | delete_user |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the assigned companies success response should be valid

  @positive @creator
  Scenario: Self lookup with an arbitrary source tag returns 200
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the query parameters:
      | source | gum |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the assigned companies success response should be valid

  @negative @creator @500
  Scenario: A 16-char but non-existent user_id surfaces as a server-class failure
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 500

  @negative @creator
  Scenario: user_id not 16 characters returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | short |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 400
    And the assigned companies failure response should be valid

  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @boundary @creator
  Scenario: user_id longer than 16 characters returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh56789 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 400
    And the assigned companies failure response should be valid

  @negative @boundary @creator
  Scenario: user_id of 15 characters returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh567 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 400
    And the assigned companies failure response should be valid

  @negative @boundary @security @creator
  Scenario: 16-char user_id that sanitizes below 16 returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd12efgh56{};~ |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 400
    And the assigned companies failure response should be valid

  @negative @creator
  Scenario: Empty user_id resolves to the collection URL which has no verb
    Given I prepare a request
    And I set the path parameters:
      | user_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be one of "404,405"

  @negative @creator
  Scenario: Trailing slash on the item URL is not a registered route
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}/"
    Then the response status code should be one of "404,405"

  @negative @security @creator
  Scenario: SQL injection in user_id is sanitized and rejected by the length check
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 400
    And the assigned companies failure response should be valid

  @negative @security @creator @500
  Scenario: A 16-char XSS payload passes the length check but is an unknown user_id
    Given I prepare a request
    And I set the path parameters:
      | user_id | <script>alertxyz |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 500

  @negative @creator
  Scenario: POST to the item URL is not allowed
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "POST" request to "/user/companies/{user_id}"
    Then the response status code should be one of "404,405"

  @negative @creator
  Scenario: PUT to the item URL is not allowed
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "PUT" request to "/user/companies/{user_id}"
    Then the response status code should be one of "404,405"

  @negative @creator
  Scenario: DELETE to the item URL is not allowed
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "DELETE" request to "/user/companies/{user_id}"
    Then the response status code should be one of "404,405"

  @negative @creator
  Scenario: PATCH to the item URL is not allowed
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "PATCH" request to "/user/companies/{user_id}"
    Then the response status code should be one of "404,405"

  @positive @security @creator
  Scenario: Self lookup with SQL injection in source is logged only and returns 200
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the query parameters:
      | source | delete_user' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the assigned companies success response should be valid

  @positive @security @creator
  Scenario: Self lookup with XSS in source is logged only and returns 200
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the query parameters:
      | source | <script>alert(1)</script> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the assigned companies success response should be valid

  @positive @boundary @creator
  Scenario: Self lookup with a unicode source value returns 200
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the query parameters:
      | source | delete_user_日本語_😀 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the assigned companies success response should be valid

  @positive @boundary @creator
  Scenario: Self lookup with a very long source value returns 200
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the query parameters:
      | source | {RANDOM_STRING:256} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the assigned companies success response should be valid

  @positive @creator
  Scenario: Self lookup ignores an unknown query parameter and returns 200
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the query parameters:
      | foo | {RANDOM_STRING:8} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the assigned companies success response should be valid

  @positive @creator
  Scenario: Self lookup ignores an unsupported Content-Type header on GET
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN}    |
      | content-type        | application/xml |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the assigned companies success response should be valid

  @negative @security @creator
  Scenario: SQL injection in the authenticationtoken is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | abcd1234efgh5678 |
    And I set the request headers:
      | authenticationtoken | ' OR '1'='1 |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator
  Scenario: Self lookup response exposes the documented data shape
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response body should contain field "data.assigned_companies"
    And the response body should contain field "data.is_chief_admin"
    And the response body should contain field "message"

  @positive @creator
  Scenario: Self lookup with source=delete_user still returns the is_chief_admin flag
    Given I store the current user id from the user profile
    And I prepare a request
    And I set the path parameters:
      | user_id | {CREATOR_USER_ID} |
    And I set the query parameters:
      | source | delete_user |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/companies/{user_id}"
    Then the response status code should be 200
    And the response body should contain field "data.is_chief_admin"
    And the response body should contain field "data.assigned_companies"
