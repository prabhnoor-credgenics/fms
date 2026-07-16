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

  # ---------------------------------------------------------------------------
  # Expanded coverage (path quirks, response shape, auth/company_id negatives,
  # user_id injection, method/route) — grounded in company-users-user-id-api-doc.md.
  # ---------------------------------------------------------------------------

  @positive @creator
  Scenario: Trailing-slash path (strict_slashes=False) still resolves the item URL returns 200
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}/"
    Then the response status code should be 200
    And the company user details success response should be valid

  @positive @creator
  Scenario: descendants=false is still truthy and returns 200
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | descendants | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the company user details success response should be valid

  @positive @creator
  Scenario: Unknown query param is accepted and passed through returns 200
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id     | {COMPANY_ID}       |
      | unknown_filter | {RANDOM_STRING:8}  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the company user details success response should be valid

  @positive @creator
  Scenario: Self lookup response exposes documented envelope fields
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the response body should contain field "data"
    And the response body should contain field "message"
    And the response body should contain text "{USER_ID:creator0}"

  @positive @creator
  Scenario: Response content type is JSON
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the response content type should be "application/json"

  @positive @creator
  Scenario: Self lookup responds within the configured time limit
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the response time should be within configured limit

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-value |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be one of "401,400"
    And the response body should not be empty

  @negative @creator
  Scenario: Malformed (non-UUID) company_id is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Empty company_id value is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Cross-company scoping — caller cannot use a company they do not belong to
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be one of "403,400"
    And the response body should not be empty

  @negative @security @creator
  Scenario: SQL injection payload in user_id returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | 1' OR '1'='1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 400
    And the company user details failure response should be valid

  @negative @security @creator
  Scenario: XSS payload in user_id returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | <script>alert(1)</script> |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

  @negative @creator
  Scenario: Special-character user_id (non-alphanumeric) returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | user@id#123 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 400
    And the company user details failure response should be valid

  @negative @creator
  Scenario: Very long alphanumeric (non-existent) user_id returns 422
    Given I prepare a request
    And I set the path parameters:
      | user_id | {RANDOM_STRING:64} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 422
    And the response body should not be empty

  @negative @creator
  Scenario: Mixed valid and invalid attributes CSV returns 400
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}          |
      | attributes | name,email,bogus_attr |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/{user_id}"
    Then the response status code should be 400
    And the company user details failure response should be valid

  @negative @creator
  Scenario: Unsupported HTTP method (PUT) on the item URL is rejected
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "PUT" request to "/user/company/users/{user_id}"
    Then the response status code should be one of "405,404"
    And the response body should not be empty

  @negative @creator
  Scenario: Wrong route path returns 404
    Given I prepare a request
    And I set the path parameters:
      | user_id | {USER_ID:creator0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/userz/{user_id}"
    Then the response status code should be 404
    And the response body should not be empty
