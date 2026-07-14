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

  # ---------------------------------------------------------------------------
  # Expanded coverage (response shape, extra params ignored, auth negatives,
  # method) — grounded in users-api-doc.md (GET /user/users/ = own profile).
  # ---------------------------------------------------------------------------

  @positive @creator
  Scenario: Response exposes documented profile fields
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the response body should contain field "data.user_details.name"
    And the response body should contain field "data.user_details.email"
    And the response body should contain field "data.user_details.mobile"
    And the response body should contain field "data.user_details.role"

  @positive @creator
  Scenario: Response exposes name and ISD identity fields
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the response body should contain field "data.user_details.first_name"
    And the response body should contain field "data.user_details.last_name"
    And the response body should contain field "data.user_details.country_isd_code"

  @positive @creator
  Scenario: Response includes preferred_language field
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the response body should contain field "data.user_details.preferred_language"

  @positive @creator
  Scenario: Response envelope carries data.user_details and message
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the response body should contain field "data.user_details"
    And the response body should contain field "message"

  @positive @creator
  Scenario: Response content type is JSON
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the response content type should be "application/json"

  @positive @creator
  Scenario: Response is returned within the configured time limit
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the response time should be within configured limit

  @positive @creator
  Scenario: Unknown query parameter is ignored and returns 200
    Given I prepare a request
    And I set the query parameters:
      | user_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the user details success response should be valid

  @positive @creator
  Scenario: Multiple extraneous query parameters are ignored and return 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | user_id    | {UUID}            |
      | foo        | {RANDOM_STRING:8} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the user details success response should be valid

  @positive @security @creator
  Scenario: SQL-injection-style query parameter is ignored and returns 200
    Given I prepare a request
    And I set the query parameters:
      | user_id | 1' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the user details success response should be valid

  @positive @creator
  Scenario: Unusual Content-Type header on a bodyless GET is ignored
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | text/plain   |
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 200
    And the user details success response should be valid

  @negative @creator
  Scenario: Malformed authenticationtoken containing spaces is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | invalid token with spaces |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @security @creator
  Scenario: SQL-injection authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | ' OR 1=1;-- |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @security @creator
  Scenario: XSS-payload authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | <script>alert(1)</script> |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

  @negative @boundary @creator
  Scenario: Overly long authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {RANDOM_STRING:1024} |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unicode authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | 日本語トークン-ключ-😀 |
    When I send a "GET" request to "/user/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: PATCH on the collection URL is not allowed (405)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "PATCH" request to "/user/users/"
    Then the response status code should be 405

  @negative @creator
  Scenario: PUT on the collection URL is not allowed (405)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "PUT" request to "/user/users/"
    Then the response status code should be 405

  @negative @creator
  Scenario: DELETE on the collection URL is not allowed (405)
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "DELETE" request to "/user/users/"
    Then the response status code should be 405
