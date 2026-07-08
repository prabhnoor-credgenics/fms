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


  @positive @e2e @lifecycle @chief-admin
  Scenario: Full lifecycle — create role, create user with that role, set/reset password, login, verify by user_id
    # Auth: creator creates the role + user; chief admin sets the password and does the verify lookup.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions

    # 1) Create a role (reporting to an existing role)
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/"
    Then the response status code should be 200
    And I store response field "data.roles[0].role_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "role_name": "lifecycleRole{RANDOM_STRING:8}", "reports_to_role_id": "{MAPPING_ID}" }
      """
    When I send a "POST" request to "/user/roles/"
    Then the response status code should be 201
    And I store response field "data.role_id" as variable id

    # 2) Create a permission profile (POST /user/profiles) — this is the "permission" step; a profile is
    # a permission group. The created profile_id is used for the new user below. Asserts 2xx internally.
    When I create a permission profile

    # 3) Create a company user assigned the created role + created profile (reports_to resolved from the
    # creator). This step asserts 201 internally (the generic status step reads the prior response).
    When I create a company user assigned the created role

    # 4) Chief admin sets the new user's password, then 5) the user logs in (login asserts 200 internally)
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    When I set the lifecycle user's password to "User@123" using the chief admin token
    And I log in as the lifecycle user with password "User@123"

    # 6) Change the password again (a different value), then log in with it
    When I set the lifecycle user's password to "User@1234" using the chief admin token
    And I log in as the lifecycle user with password "User@1234"

    # 7) Verify the user's details via verify-user, looked up by user_id (admin token; asserts 200 internally)
    When I verify the lifecycle user's details by user id
    And the verify user success response should be valid
