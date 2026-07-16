@api @user @global-users
Feature: Global Users — GET (list) and POST (create) /user/global/users/


  Background:
    # chief-admin is the caller for the endpoint; its own company is the pseudo value "All"
    # (not a real UUID), so we also source a real member-company UUID from a creator session
    # and reference it via {COMPANY_ID:creator0} in assigned_companies. chief-admin is
    # authenticated last so it remains the active caller.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"


  @positive @smoke @chief-admin
  Scenario: Minimal (defaults, no query params) returns 200 with list envelope
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/global_users_list_success_schema.json"
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: Explicit attributes (CSV) returns 200
    Given I prepare a request
    And I set the query parameters:
      | attributes | name,email,mobile,created,country_isd_code |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: Pagination (page_number + page_size) returns 200
    Given I prepare a request
    And I set the query parameters:
      | page_number | 1  |
      | page_size   | 25 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: disable_paging=true returns 200 (all matching rows)
    Given I prepare a request
    And I set the query parameters:
      | disable_paging | true |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario Outline: search_type "<search_type>" with search_query returns 200
    Given I prepare a request
    And I set the query parameters:
      | search_type  | <search_type> |
      | search_query | test          |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

    Examples:
      | search_type        |
      | user_id            |
      | name               |
      | email              |
      | mobile             |
      | client_employee_id |

  @positive @chief-admin
  Scenario: roles filter (chief admin + super admin) returns 200
    Given I prepare a request
    And I set the query parameters:
      | roles | chief admin,super admin |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: assigned_companies filter (a real member company) returns 200
    Given I prepare a request
    And I set the query parameters:
      | assigned_companies | {COMPANY_ID:creator0} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid


  @negative @boundary @chief-admin
  Scenario: search_type outside the allowed set returns 400
    Given I prepare a request
    And I set the query parameters:
      | search_type  | astronaut |
      | search_query | test      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @boundary @chief-admin
  Scenario: page_size over the max allowed limit (5000) returns 400
    Given I prepare a request
    And I set the query parameters:
      | page_number | 1    |
      | page_size   | 5001 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin
  Scenario: assigned_companies with a non-UUID value returns 400
    Given I prepare a request
    And I set the query parameters:
      | assigned_companies | not-a-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin
  Scenario: attributes value outside the allowed set returns 400
    Given I prepare a request
    And I set the query parameters:
      | attributes | name,not_a_real_attribute |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @auth @chief-admin
  Scenario: Missing authenticationtoken header is rejected with 400
    Given I prepare a request
    And I set the request headers:
      | referer | abc |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @auth @chief-admin
  Scenario: Invalid authenticationtoken is rejected with 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
      | referer             | abc               |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @auth
  Scenario: Non chief/super admin caller (creator) is forbidden with 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 403
    And the global users failure response should be valid


  @positive @smoke @chief-admin @global-user-create
  Scenario: Create a super user (email) in caller's company returns 201
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Sam", "email": "globalu{RANDOM_STRING:8}@credgenics.com", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID:creator0}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 201
    And the response should match json schema "schemas/user/success/global_user_create_success_schema.json"
    And the global user create response should be valid

  @positive @chief-admin @global-user-create
  Scenario: Create a super user (mobile instead of email) in caller's company returns 201
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Sam", "mobile": "98{RANDOM_INT:10000000:99999999}", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID:creator0}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 201
    And the global user create response should be valid


  @negative @chief-admin @global-user-create
  Scenario: Empty JSON body returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Missing first_name (required) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "email": "globalu{RANDOM_STRING:8}@credgenics.com", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID:creator0}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Neither email nor mobile provided returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "NoContact", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Invalid email format returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Bad", "email": "not-an-email", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID:creator0}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Non chief-admin user_type without any company/agency returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Orphan", "email": "orphan{RANDOM_STRING:6}@credgenics.com", "user_type": "super user" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: chief admin with a non-credgenics.com email domain returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Chief", "email": "chief{RANDOM_STRING:6}@example.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Invalid user_type enum returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Nope", "email": "nope{RANDOM_STRING:6}@credgenics.com", "user_type": "astronaut" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @auth @chief-admin @global-user-create
  Scenario: Create with missing authenticationtoken header is rejected with 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
      | referer      | abc              |
    And I set the request body:
      """
      { "first_name": "NoAuth", "email": "noauth{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the response body should not be empty

  # ---------------------------------------------------------------------------
  # Expanded coverage — GET (filters/pagination/injection/shape) + POST create
  # (required fields, invalid formats/enums, domain rules, method/content-type,
  # RBAC) — grounded in global-users-get-api-doc.md + global-users-post-api-doc.md.
  # ---------------------------------------------------------------------------

  @positive @chief-admin
  Scenario: disable_paging=false with explicit paging returns 200
    Given I prepare a request
    And I set the query parameters:
      | disable_paging | false |
      | page_number    | 2     |
      | page_size      | 25    |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @boundary @chief-admin
  Scenario: page_size at the max allowed limit (5000) returns 200
    Given I prepare a request
    And I set the query parameters:
      | page_number | 1    |
      | page_size   | 5000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: search_query without search_type (defaults to name) returns 200
    Given I prepare a request
    And I set the query parameters:
      | search_query | test |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: search_type without search_query (no filter applied) returns 200
    Given I prepare a request
    And I set the query parameters:
      | search_type | name |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: Wide attributes set (accepted, list shape unaffected) returns 200
    Given I prepare a request
    And I set the query parameters:
      | attributes | name,email,mobile,role,profile,profession,team,location,department,created,country_isd_code,territory_code |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: Unknown extra query parameter is accepted (extra=allow) and returns 200
    Given I prepare a request
    And I set the query parameters:
      | not_a_real_param | anything |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario Outline: roles filter with a single value "<role>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | roles | <role> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

    Examples:
      | role        |
      | chief admin |
      | super admin |

  @negative @chief-admin
  Scenario: page_number with a non-integer value returns 400
    Given I prepare a request
    And I set the query parameters:
      | page_number | abc |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin
  Scenario: page_size with a non-integer value returns 400
    Given I prepare a request
    And I set the query parameters:
      | page_size | abc |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @method @chief-admin
  Scenario: Unsupported HTTP method DELETE on the collection is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "DELETE" request to "/user/global/users/"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

  @negative @security @chief-admin
  Scenario: SQL injection in search_query is sanitised and returns 200
    Given I prepare a request
    And I set the query parameters:
      | search_type  | name                               |
      | search_query | ' OR '1'='1'; DROP TABLE _users;-- |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @negative @security @chief-admin
  Scenario: XSS payload in search_query returns 200
    Given I prepare a request
    And I set the query parameters:
      | search_type  | name                      |
      | search_query | <script>alert(1)</script> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @negative @boundary @chief-admin
  Scenario: Very long search_query returns 200
    Given I prepare a request
    And I set the query parameters:
      | search_type  | name                |
      | search_query | {RANDOM_STRING:300} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: Unicode search_query returns 200
    Given I prepare a request
    And I set the query parameters:
      | search_type  | name |
      | search_query | Jösé |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the global users list response should be valid

  @positive @chief-admin
  Scenario: List response exposes documented data and message shape
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 200
    And the response body should contain field "data"

  @positive @chief-admin @global-user-create
  Scenario: Create a chief admin (credgenics.com email, no company) returns 201
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Chief", "email": "chief{RANDOM_STRING:8}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 201
    And the global user create response should be valid

  @positive @chief-admin @global-user-create
  Scenario: Extra unknown top-level field is ignored and create returns 201
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Sam", "email": "globalu{RANDOM_STRING:8}@credgenics.com", "user_type": "super user", "unknown_field": "ignore-me", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 201
    And the global user create response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Missing user_type (required) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "NoType", "email": "notype{RANDOM_STRING:6}@credgenics.com", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Invalid mobile (non-digits) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "BadMobile", "mobile": "98abc12345", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: assigned_companies company_id that is not a UUID returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "BadCompany", "email": "badco{RANDOM_STRING:6}@credgenics.com", "user_type": "super user", "assigned_companies": [ { "company_id": "not-a-uuid" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: assigned_companies item missing required company_id returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "NoCompanyId", "email": "nocoid{RANDOM_STRING:6}@credgenics.com", "user_type": "super user", "assigned_companies": [ { "profession": "other" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @boundary @chief-admin @global-user-create
  Scenario: last_name exceeding max length returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Long", "last_name": "Laaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaastname", "email": "longln{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @security @chief-admin @global-user-create
  Scenario: first_name starting with a formula character returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "=cmd|calc", "email": "formula{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @security @chief-admin @global-user-create
  Scenario: first_name containing an HTML tag returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "<script>alert(1)</script>", "email": "xss{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

  @negative @boundary @chief-admin @global-user-create
  Scenario: first_name exceeding max length returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Fiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiirstname", "email": "longfn{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Invalid session_timeout_duration returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Timeout", "email": "timeout{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin", "session_timeout_duration": 45 }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Invalid profession enum returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "BadProf", "email": "badprof{RANDOM_STRING:6}@credgenics.com", "user_type": "user", "assigned_companies": [ { "company_id": "{COMPANY_ID}", "profession": "astronaut" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Field executive without field_collection_limit returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "FieldExec", "mobile": "98{RANDOM_INT:10000000:99999999}", "user_type": "user", "assigned_companies": [ { "company_id": "{COMPANY_ID}", "reports_to_user_id": "abcd1234efgh5678", "role_id": "rrrr1111tttt2222", "profile_id": "pppp3333ffff4444", "profession": "field executive" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: role_id that is not a valid 16-char NanoID returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "BadRole", "email": "badrole{RANDOM_STRING:6}@credgenics.com", "user_type": "user", "assigned_companies": [ { "company_id": "{COMPANY_ID}", "reports_to_user_id": "abcd1234efgh5678", "role_id": "short", "profile_id": "pppp3333ffff4444" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Invalid whitelisted_ip_addresses returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "BadIp", "email": "badip{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin", "whitelisted_ip_addresses": ["999.999.999.999"] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Invalid alternate_email returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "BadAlt", "email": "badalt{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin", "alternate_email": "not-an-email" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Invalid address_pincode returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "BadPin", "email": "badpin{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin", "address_pincode": "@@" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: assigned_companies of the wrong type (string, not array) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "WrongType", "email": "wrong{RANDOM_STRING:6}@credgenics.com", "user_type": "super user", "assigned_companies": "not-an-array" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: super admin with a non-credgenics.com email domain returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "SuperDomain", "email": "super{RANDOM_STRING:6}@example.com", "user_type": "super admin", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the global users failure response should be valid

  @negative @chief-admin @global-user-create
  Scenario: Malformed JSON body returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Broken", "email": "broken{RANDOM_STRING:6}@credgenics.com",
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @chief-admin @global-user-create
  Scenario: Unsupported content-type (text/plain) is rejected with 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | text/plain   |
      | authenticationtoken | {AUTH_TOKEN} |
      | referer             | abc          |
    And I set the request body:
      """
      { "first_name": "Plain", "email": "plain{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be one of "400,415"
    And the response body should not be empty

  @negative @auth @chief-admin @global-user-create
  Scenario: Create with invalid authenticationtoken is rejected with 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
      | referer             | abc               |
    And I set the request body:
      """
      { "first_name": "BadAuth", "email": "badauth{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @auth @global-user-create
  Scenario: Non chief/super admin caller (creator) cannot create and is forbidden with 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | referer             | abc              |
    And I set the request body:
      """
      { "first_name": "Forbidden", "email": "forbid{RANDOM_STRING:6}@credgenics.com", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be one of "403,400"
    And the response body should not be empty
