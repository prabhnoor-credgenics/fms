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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" success response should be valid

  @negative @creator @500
  Scenario: include_only_inactive=true alone returns 400
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
    And the "company_users_export" failure response should be valid

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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" success response should be valid

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
    And the "company_users_export" failure response should be valid

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
    And the "company_users_export" failure response should be valid

  @positive @creator @shouldfail
  Scenario: filters.user_ids with invalid NanoID (wrong length) returns 200
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
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

  @positive @creator @shouldfail
  Scenario: filters.profession invalid enum returns 200
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
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

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
    And the "company_users_export" failure response should be valid

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
    And the "company_users_export" failure response should be valid

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
    And the "company_users_export" failure response should be valid

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
    And the "company_users_export" failure response should be valid

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
    And the "company_users_export" failure response should be valid

  @positive @creator
  Scenario: company_id supplied only in body (no query param) still returns 200
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
    And the "company_users_export" success response should be valid

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


  @positive @creator
  Scenario: return_type=s3_link explicitly set returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "return_type": "s3_link" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario Outline: search_type "<search_type>" with search_query returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "<search_type>", "search_query": "test" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

    Examples:
      | search_type        |
      | user_id            |
      | name               |
      | email              |
      | mobile             |
      | client_employee_id |

  @positive @creator
  Scenario Outline: hierarchy/visibility flag "<flag>"=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "<flag>": "true" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

    Examples:
      | flag                   |
      | include_chief_admin    |
      | include_descendants    |
      | include_ascendants     |
      | neglect_hierarchy      |
      | include_api_users      |
      | include_count_of_users |

  @positive @creator
  Scenario Outline: valid sort_by "<sort_by>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "sort_by": "<sort_by>" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

    Examples:
      | sort_by      |
      | created_asc  |
      | created_desc |
      | updated_asc  |
      | updated_desc |

  @positive @creator
  Scenario: page_number and page_size supplied (handler forces disable_paging) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "page_number": 1, "page_size": 50 }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: disable_paging=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "disable_paging": "true" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: parent-company flags returns 200
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
        "include_parent_company_users": "true",
        "include_only_parent_company_users": "false",
        "fetch_parent_company_details": "false"
      }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: filters.exclude_profession returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "exclude_profession": "advocate,lawyer" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator @500
  Scenario: filters client_employee_id/department/coverage_areas/mapped_portfolio_ids returns 200
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
          "client_employee_id": "emp001,emp002",
          "department": "collections",
          "coverage_areas": "north,south",
          "mapped_portfolio_ids": "port001,port002"
        }
      }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: filters.profile_permission_group returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "profile_permission_group": "admin" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: filters created/updated date windows returns 200
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
          "created_date_start": "2026-01-01",
          "created_date_end": "2026-06-30",
          "updated_date_start": "2026-01-01",
          "updated_date_end": "2026-06-30"
        }
      }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: filters.deselected_user_ids (valid NanoID) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "deselected_user_ids": "abcd1234efgh5678" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: Unknown extra top-level param is allowed (extra=allow) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "totally_unknown_field": "some-value" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: Arbitrary return_type string (free-form str field) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "return_type": "csv" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @creator
  Scenario: Response body exposes data and message fields (default s3_link) returns 200
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
    And the response body should contain field "data"
    And the response body should contain field "message"

  @positive @creator @shouldfail
  Scenario: Invalid attributes enum returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "attributes": "name,not_a_real_attribute" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

  @negative @creator
  Scenario: Invalid search_type enum returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "phone_number" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the "company_users_export" failure response should be valid

  @negative @creator
  Scenario: include_only_inactive combined with include_api_users returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_only_inactive": "true", "include_api_users": "true" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the "company_users_export" failure response should be valid

  @positive @creator @shouldfail
  Scenario: filters.usernames not an email or mobile returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "usernames": "not-an-email-or-mobile" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

  @positive @creator  @shouldfail
  Scenario Outline: filters.<field> with invalid NanoID returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "<field>": "bad" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

    Examples:
      | field               |
      | roles               |
      | profiles            |
      | reports_to          |
      | deselected_user_ids |

  @positive @creator @shouldfail
  Scenario: filters.exclude_profession invalid enum returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "exclude_profession": "astronaut" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

  @positive @creator @shouldfail
  Scenario: Invalid created_date format returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "created_date_start": "2026/06/01" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

  @positive @creator @shouldfail
  Scenario: Invalid activity_start_time datetime format returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "data_scope": "activity-sessions", "filters": { "activity_start_time": "2026-06-01" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

  @positive @creator @shouldfail
  Scenario: Invalid StrBool value on include_inactive returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_inactive": "maybe" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" failure response should be valid

  @negative @creator
  Scenario: Non-numeric page_number returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "page_number": "abc" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 400
    And the "company_users_export" failure response should be valid

  @positive @security @creator
  Scenario: SQL injection in search_query is treated as literal (no error) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "name", "search_query": "'; DROP TABLE users;--" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @security @creator
  Scenario: XSS payload in filters.location is handled safely returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "location": "<xss>alert(1)</xss>" } }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @security @creator
  Scenario: company_id query param authoritative over differing body company_id returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{UUID}" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @negative @security @creator
  Scenario: Cross-company scoping — unknown company_id UUID is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{UUID}" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario Outline: <method> method is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "<method>" request to "/user/company/users/export"
    Then the response status code should be 405

    Examples:
      | method |
      | PUT    |
      | PATCH  |

  @negative @creator
  Scenario: Unsupported Content-Type is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | text/plain   |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be one of "400,415"
    And the response body should not be empty

  @positive @boundary @creator
  Scenario: Very long search_query returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "name", "search_query": "{RANDOM_STRING:500}" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid

  @positive @boundary @creator
  Scenario: Unicode search_query returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "name", "search_query": "名前 testüñ" }
      """
    When I send a "POST" request to "/user/company/users/export"
    Then the response status code should be 200
    And the "company_users_export" success response should be valid
