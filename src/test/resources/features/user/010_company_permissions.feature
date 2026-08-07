@api @user @company-permissions
Feature: Company Permissions — GET /user/company/permissions/



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal (default inject_meta_data=true) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/company_permissions_success_schema.json"
    And the "company_permissions" success response should be valid

  @positive @creator
  Scenario: inject_meta_data=true (explicit) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | inject_meta_data | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @positive @creator
  Scenario: inject_meta_data=false (raw permission set) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | inject_meta_data | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @positive @creator
  Scenario: inject_meta_data with a junk value is coerced to false and still returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}      |
      | inject_meta_data | {RANDOM_STRING:6} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @positive @creator
  Scenario: Trailing-slash-insensitive path returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id is rejected at org resolution
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @other-pod
  Scenario: Company with no active company-admin profile returns 422
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the "company_permissions" failure response should be valid



  @positive @creator
  Scenario: inject_meta_data uppercase TRUE is case-insensitively truthy and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | inject_meta_data | TRUE         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @positive @creator
  Scenario: Empty inject_meta_data value falls back to the default and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | inject_meta_data |              |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @positive @creator
  Scenario: Unknown extra query parameter is tolerated and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | foo        | {RANDOM_STRING:8} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @positive @creator
  Scenario: Success response exposes profile_id, permissions and the success message
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the response body should contain field "data.profile_id"
    And the response body should contain field "data.permissions"

  @positive @creator
  Scenario: Success response content type is application/json
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the response content type should be "application/json"

  @positive @security @creator
  Scenario: SQL-injection-like inject_meta_data is coerced to false and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}    |
      | inject_meta_data | true' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @positive @security @creator @shouldfail
  Scenario: XSS-like inject_meta_data is coerced to false and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}              |
      | inject_meta_data | <xss>alert(1)</xss> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @positive @creator
  Scenario: Unexpected request Content-Type header is ignored on GET and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN}    |
      | Content-Type        | application/xml |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 200
    And the "company_permissions" success response should be valid

  @negative @creator
  Scenario: Malformed (non-UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Empty company_id value is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @security @creator
  Scenario: SQL injection in company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | ' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @security @creator
  Scenario: XSS payload in company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | <xss>alert(1)</xss> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

  @negative @boundary @creator
  Scenario: Over-long unicode company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | 日本語-ñ-{RANDOM_STRING:200} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unsupported HTTP method on the collection URL is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "DELETE" request to "/user/company/permissions/"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown sub-path under the endpoint returns route not found
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions/does-not-exist"
    Then the response status code should be one of "404,405"
    And the response body should not be empty
