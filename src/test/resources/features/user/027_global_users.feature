@api @user @global-users
Feature: Global Users — GET (list) and POST (create) /user/global/users/


  Background:
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"


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
  Scenario: assigned_companies filter (caller's own company) returns 200
    Given I prepare a request
    And I set the query parameters:
      | assigned_companies | {COMPANY_ID} |
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
  Scenario: Missing authenticationtoken header is rejected with 401
    Given I prepare a request
    And I set the request headers:
      | referer | abc |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 401
    And the response body should not be empty

  @negative @auth @chief-admin
  Scenario: Invalid authenticationtoken is rejected with 401
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
      | referer             | abc               |
    When I send a "GET" request to "/user/global/users/"
    Then the response status code should be 401
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
      { "first_name": "Sam", "email": "globalu{RANDOM_STRING:8}@credgenics.com", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
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
      { "first_name": "Sam", "mobile": "98{RANDOM_INT:10000000:99999999}", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
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
      { "email": "globalu{RANDOM_STRING:8}@credgenics.com", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
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
      { "first_name": "Bad", "email": "not-an-email", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID}" } ] }
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
  Scenario: Create with missing authenticationtoken header is rejected with 401
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
      | referer      | abc              |
    And I set the request body:
      """
      { "first_name": "NoAuth", "email": "noauth{RANDOM_STRING:6}@credgenics.com", "user_type": "chief admin" }
      """
    When I send a "POST" request to "/user/global/users/"
    Then the response status code should be 401
    And the response body should not be empty
