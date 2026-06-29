@api @user @company-users-export
Feature: Company Users Export — POST /user/company/users/export

  

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal — export all users to S3 link (default return_type) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/company_users_export_success_schema.json"
    And the company users export success response should be valid

  @positive @creator
  Scenario: return_type=data (inline response) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "return_type": "data" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200

  @positive @creator
  Scenario: Selected attributes + filters returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "attributes": ["name", "email", "mobile", "role", "profile", "profession"],
        "filters": { "profession": "collection manager,field executive", "location": "mumbai" }
      }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

  @positive @creator
  Scenario: attributes as comma-separated string returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "attributes": "name,email,mobile,team,location" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

  @positive @creator
  Scenario Outline: data_scope "<scope>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "data_scope": "<scope>" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

    Examples:
      | scope                    |
      | users                    |
      | session-summary          |
      | activity-sessions        |
      | login-sessions           |
      | user-audit-details       |
      | permission-audit-details |

  @positive @creator
  Scenario: include_inactive=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_inactive": "true" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

  @negative @creator
  Scenario: include_only_inactive=true alone returns 400
    # Observed on staging: the export handler auto-sets include_inactive=true (no deselected_user_ids),
    # so include_only_inactive=true alone conflicts → 400 "Only one of 'include_inactive'/'include_api_users'
    # and 'include_only_inactive' can be true at a time."
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_only_inactive": "true" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @positive @creator
  Scenario: filters user_ids/usernames/roles/profiles/reports_to returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "filters": {
          "user_ids": "abcd1234efgh5678,wxyz9876lmno5432",
          "usernames": "john@credgenics.com,9876543210",
          "roles": "role1234abcd5678",
          "profiles": "prof1234abcd5678",
          "reports_to": "mgr01234abcd5678"
        }
      }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

  @positive @creator
  Scenario: Geography filters returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "data_scope": "users",
        "filters": { "location": "mumbai,pune", "team": "north", "address_state": "maharashtra" },
        "attributes": ["name", "email", "mobile", "team", "location"]
      }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

  @positive @creator
  Scenario: Login-session report with duration_to_seconds and date window returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "data_scope": "login-sessions",
        "duration_to_seconds": "true",
        "filters": { "created_date_start": "2026-06-01", "created_date_end": "2026-06-21" }
      }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

  @positive @creator
  Scenario: Audit + activity ranges (permission-audit-details) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "data_scope": "permission-audit-details",
        "filters": {
          "audit_created_date_start": "2026-03-01",
          "audit_created_date_end": "2026-06-21",
          "activity_start_time": "2026-06-01 00:00:00",
          "activity_end_time": "2026-06-21 23:59:59"
        }
      }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

  @positive @creator
  Scenario Outline: filters.profession "<profession>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "profession": "<profession>" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

    Examples:
      | profession                       |
      | advocate                         |
      | area manager                     |
      | collection manager               |
      | field executive                  |
      | field collection manager         |
      | field and telecalling executive  |
      | field and telecalling supervisor |
      | lawyer                           |
      | telecalling                      |
      | telecalling supervisor           |
      | other                            |


  @negative @creator
  Scenario: include_only_inactive combined with include_inactive returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_only_inactive": "true", "include_inactive": "true" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @negative @creator
  Scenario: audit_created_date_start older than 6 months returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "data_scope": "user-audit-details", "filters": { "audit_created_date_start": "2020-01-01", "audit_created_date_end": "2020-02-01" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @negative @creator
  Scenario: filters.user_ids with invalid NanoID (wrong length) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "user_ids": "tooshort123" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @negative @creator
  Scenario: filters.profession invalid enum returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "profession": "astronaut" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @negative @creator
  Scenario: Invalid data_scope enum returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "data_scope": "not-a-scope" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @negative @creator
  Scenario: Invalid sort_by enum returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "sort_by": "name_asc" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @negative @creator
  Scenario: Missing company_id (mandatory body field) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "attributes": ["name", "email"] }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @negative @creator
  Scenario: Non-UUID company_id returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | not-a-uuid |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "not-a-uuid" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @negative @creator
  Scenario: Empty JSON body returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the company users export failure response should be valid

  @positive @creator
  Scenario: company_id supplied only in body (no query param) still returns 200
    # Observed on staging: company_id is resolved from the request body when the query param is absent,
    # so the export succeeds with 200 (the doc's "required query param" is not enforced when body has it).
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the company users export success response should be valid

  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: DELETE method is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "DELETE" request to "/user/company/users/export"
    Then the response status code should be 405
