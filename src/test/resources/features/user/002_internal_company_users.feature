@api @user @internal-company-users
Feature: Internal Company Users — POST /user/internal/company-users/

  Background: 
    Given I authenticate as "creator" slot 0 and remember as "creator0"

  @positive @smoke @creator
  Scenario: Minimal (only company_id) returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/internal_company_users_success_schema.json"
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Explicit attributes (list) with paging and count returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "attributes": ["name", "email", "mobile", "role", "profile", "profession"],
        "page_number": 1,
        "page_size": 50,
        "include_count_of_users": "true"
      }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: attributes as comma-separated string returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "attributes": "name,email,mobile,team,location,department" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Search by email returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "email", "search_query": "john@credgenics.com" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: include_inactive=true with paging disabled returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_inactive": "true", "disable_paging": "true" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: include_api_users=true with count and paging disabled returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_api_users": "true", "disable_paging": "true", "include_count_of_users": "true" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Hierarchy flags (descendants true / ascendants false) returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_descendants": "true", "include_ascendants": "false", "neglect_hierarchy": "false" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: neglect_hierarchy=true returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "neglect_hierarchy": "true" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: compress_data=true returns 200 (data is a base64 LZ4 string)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "compress_data": "true", "disable_paging": "true", "attributes": ["name", "email", "mobile"] }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Parent-company inclusion flags returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "include_parent_company_users": "true",
        "include_only_parent_company_users": "false",
        "fetch_parent_company_details": "true"
      }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario Outline: sort_by "<sort>" returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "page_number": 1, "page_size": 20, "sort_by": "<sort>" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

    Examples: 
      | sort         |
      | created_asc  |
      | created_desc |
      | updated_asc  |
      | updated_desc |

  @positive @creator
  Scenario Outline: data_scope "<scope>" returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "data_scope": "<scope>" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

    Examples: 
      | scope                    |
      | users                    |
      | session-summary          |
      | activity-sessions        |
      | login-sessions           |
      | user-audit-details       |
      | permission-audit-details |

  @positive @creator
  Scenario Outline: filters.profession "<profession>" returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "profession": "<profession>" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

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

  @positive @creator
  Scenario: filters.user_ids + deselected_user_ids returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "filters": { "user_ids": "abcd1234efgh5678,wxyz9876lmno5432", "deselected_user_ids": "qrst1234uvwx5678" }
      }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: filters.usernames (email + mobile) returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "attributes": ["name"], "filters": { "usernames": "john@credgenics.com,9876543210" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: filters roles / profiles / reports_to (NanoIDs) returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "filters": { "roles": "role1234abcd5678", "profiles": "prof1234abcd5678", "reports_to": "mgr01234abcd5678" }
      }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: filters location/team/department/coverage/state/employee/portfolio returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "filters": {
          "location": "mumbai,pune",
          "team": "north,south",
          "department": "recovery",
          "coverage_areas": "maharashtra,gujarat",
          "address_state": "maharashtra",
          "client_employee_id": "EMP123,EMP124"
        }
      }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Date-range filters (created + updated) returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "filters": {
          "created_date_start": "2026-01-01",
          "created_date_end": "2026-06-21",
          "updated_date_start": "2026-03-01",
          "updated_date_end": "2026-06-21"
        }
      }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Audit-date + activity-time ranges returns 200
    Given I prepare a request
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
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @negative @creator
  Scenario: include_only_inactive combined with include_inactive returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_only_inactive": "true", "include_inactive": "true" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: audit_created_date_start older than 6 months returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "data_scope": "user-audit-details", "filters": { "audit_created_date_start": "2020-01-01", "audit_created_date_end": "2020-02-01" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: filters.user_ids with invalid NanoID (wrong length) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "user_ids": "tooshort123" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: filters.profession with invalid enum value returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "profession": "astronaut" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @boundary @creator
  Scenario: page_size over max allowed limit returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "page_number": 1, "page_size": 999999 }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Missing company_id (mandatory body field) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "attributes": ["name", "email"] }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Non-UUID company_id returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "not-a-uuid" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Empty JSON body returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: GET on the internal company-users endpoint is not allowed (405)
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/internal/company-users/"
    Then the response status code should be 405

  # ---------------------------------------------------------------------------
  # Expanded coverage (search_type matrix, filters, pagination, invalid enums,
  # method/content-type, injection) — grounded in internal-company-users-api-doc.md.
  # ---------------------------------------------------------------------------
  @positive @creator
  Scenario Outline: search_type "<type>" with a query returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "<type>", "search_query": "test" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

    Examples: 
      | type               |
      | user_id            |
      | name               |
      | email              |
      | mobile             |
      | client_employee_id |

  @positive @creator
  Scenario: include_only_inactive alone returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_only_inactive": "true" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: include_chief_admin with specific user_ids returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "include_chief_admin": "true",
        "disable_paging": "true",
        "filters": { "user_ids": "abcd1234efgh5678,wxyz9876lmno5432" }
      }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: filters.exclude_profession (post-filter) returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "exclude_profession": "telecalling,other" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: filters.mapped_portfolio_ids returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "mapped_portfolio_ids": "{UUID},{UUID}" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Extended attributes (address / territory / reports_to_user) returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "attributes": ["name", "reports_to_user", "territory_code", "coverage_areas", "address_text", "address_city", "address_state", "address_pincode", "address_latitude", "address_longitude", "session_timeout_duration", "preferred_language", "alternate_email"]
      }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: duration_to_seconds and return_type with source query param returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | source | allocation |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "duration_to_seconds": "true", "return_type": "summary", "data_scope": "session-summary" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Unknown top-level parameter is accepted (extra=allow) and returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "totally_unknown_param": "some_value" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Unknown key inside filters (custom_filters) is accepted and returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "some_unknown_filter": "value" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @boundary @creator
  Scenario: page_size of 1 returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "page_number": 1, "page_size": 1 }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @boundary @creator
  Scenario: page_number without page_size auto-disables paging and returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "page_number": 1 }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Whitespace-padded company_id is stripped and returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "  {COMPANY_ID}  " }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @creator
  Scenario: Unicode value in filters.location returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "location": "मुंबई,बेंगलुरु" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @boundary @creator
  Scenario: Very long search_query returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "name", "search_query": "{RANDOM_STRING:500}" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

  @positive @security @creator
  Scenario Outline: Injection payload in search_query is treated literally and returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "name", "search_query": "<payload>" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 200
    And the internal company users success response should be valid

    Examples: 
      | payload                   |
      | ' OR '1'='1               |
      | <script>alert(1)</script> |

  @negative @creator
  Scenario: include_only_inactive combined with include_api_users returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "include_only_inactive": "true", "include_api_users": "true" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Invalid sort_by value returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "sort_by": "name_asc" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Invalid data_scope value returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "data_scope": "everything" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Invalid search_type value returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "search_type": "phone", "search_query": "123" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Invalid attributes value returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "attributes": ["name", "not_a_real_attribute"] }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: filters.exclude_profession with invalid enum returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "exclude_profession": "wizard" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: filters.usernames with invalid email/mobile returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "usernames": "not-an-email-or-mobile" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: filters date with unparseable format returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "created_date_start": "not-a-date" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: filters.roles with invalid NanoID returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "roles": "short" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: filters.deselected_user_ids with invalid NanoID returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "filters": { "deselected_user_ids": "bad!!id!!chars!!" } }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @boundary @creator
  Scenario: Paging explicitly enabled but page_size missing returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "disable_paging": "false", "page_number": 1 }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the internal company users failure response should be valid

  @negative @creator
  Scenario: Foreign (valid but not caller's) company_id is rejected by org check
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{UUID}" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be one of "403,400"
    And the response body should not be empty

  @negative @creator
  Scenario Outline: Unsupported HTTP method "<method>" is not allowed (405)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "<method>" request to "/user/internal/company-users/"
    Then the response status code should be 405

    Examples: 
      | method |
      | PUT    |
      | PATCH  |
      | DELETE |

  @negative @creator
  Scenario: Malformed JSON body returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}",, }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unsupported Content-Type with a JSON payload returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | text/plain   |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}" }
      """
    When I send a "POST" request to "/user/internal/company-users/"
    Then the response status code should be one of "400,415"
    And the response body should not be empty
