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
    And the company permissions success response should be valid

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
    And the company permissions success response should be valid

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
    And the company permissions success response should be valid

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
    And the company permissions success response should be valid

  @positive @creator
  Scenario: Trailing-slash-insensitive path returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/permissions"
    Then the response status code should be 200
    And the company permissions success response should be valid


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
    Then the response status code should be 422
    And the company permissions failure response should be valid
