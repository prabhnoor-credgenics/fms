@api @user @company-users-list
Feature: Company Users — GET (list) and POST (create) /user/company/users/



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal (company_id only) returns 200 with defaults
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/company_users_list_success_schema.json"
    And the company users list success response should be valid

  @positive @creator
  Scenario: Pagination plus attributes (CSV) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID}                                  |
      | page_number | 1                                             |
      | page_size   | 25                                            |
      | attributes  | name,email,mobile,role,profile,profession     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario: v2 alias /user/company-users/ returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | page_number | 1            |
      | page_size   | 10           |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company-users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario Outline: search_type "<search_type>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id   | {COMPANY_ID}  |
      | search_type  | <search_type> |
      | search_query | test          |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

    Examples:
      | search_type        |
      | user_id            |
      | name               |
      | email              |
      | mobile             |
      | client_employee_id |

  @positive @creator
  Scenario Outline: sort_by "<sort_by>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | page_number | 1            |
      | page_size   | 10           |
      | sort_by     | <sort_by>    |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

    Examples:
      | sort_by      |
      | created_asc  |
      | created_desc |
      | updated_asc  |
      | updated_desc |

  @positive @creator
  Scenario Outline: data_scope "<data_scope>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | data_scope | <data_scope> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

    Examples:
      | data_scope               |
      | users                    |
      | session-summary          |
      | activity-sessions        |
      | login-sessions           |
      | user-audit-details       |
      | permission-audit-details |

  @positive @creator
  Scenario Outline: include_inactive=<flag> returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_inactive | <flag>       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

    Examples:
      | flag  |
      | true  |
      | false |

  @positive @creator
  Scenario: include_only_inactive=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | include_only_inactive | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario: include_chief_admin + include_api_users (paging disabled) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id          | {COMPANY_ID} |
      | include_chief_admin | true         |
      | include_api_users   | true         |
      | disable_paging      | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario: Hierarchy flags (descendants/ascendants/neglect) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id          | {COMPANY_ID} |
      | include_descendants | true         |
      | include_ascendants  | false        |
      | neglect_hierarchy   | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario: Parent-company flags returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                        | {COMPANY_ID} |
      | include_parent_company_users      | true         |
      | include_only_parent_company_users | false        |
      | fetch_parent_company_details      | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario: filters.usernames (email + mobile) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                       |
      | usernames  | john@credgenics.com,9876543210     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario Outline: filters.profession "<profession>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | profession | <profession> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

    Examples:
      | profession                          |
      | advocate                            |
      | area manager                        |
      | collection manager                  |
      | field executive                     |
      | field collection manager            |
      | field and telecalling executive     |
      | field and telecalling supervisor    |
      | lawyer                              |
      | telecalling                         |
      | telecalling supervisor              |
      | other                               |

  @positive @creator
  Scenario: filters.exclude_profession returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id         | {COMPANY_ID}     |
      | exclude_profession | telecalling,other |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario: filters location/team/department/coverage_areas/address_state returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id     | {COMPANY_ID}        |
      | location       | mumbai,pune         |
      | team           | north,south         |
      | department     | recovery            |
      | coverage_areas | maharashtra,gujarat |
      | address_state  | maharashtra         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid

  @positive @creator
  Scenario: Date-range filters (created + updated) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id         | {COMPANY_ID} |
      | created_date_start | 2026-01-01   |
      | created_date_end   | 2026-06-21   |
      | updated_date_start | 2026-03-01   |
      | updated_date_end   | 2026-06-21   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 200
    And the company users list success response should be valid


  @negative @boundary @creator
  Scenario: include_only_inactive combined with include_inactive returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | include_only_inactive | true         |
      | include_inactive      | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 400
    And the company users list failure response should be valid

  @negative @boundary @creator
  Scenario: page_size over max allowed limit returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | page_number | 1            |
      | page_size   | 100000       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 400
    And the company users list failure response should be valid

  @negative @creator
  Scenario: Invalid NanoID in user_ids filter returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | user_ids   | short-id     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 400
    And the company users list failure response should be valid

  @negative @creator
  Scenario: audit_created_date_start older than 6 months returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id               | {COMPANY_ID} |
      | data_scope               | permission-audit-details |
      | audit_created_date_start | 2020-01-01   |
      | audit_created_date_end   | 2026-06-21   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 400
    And the company users list failure response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/users/"
    Then the response status code should be 400
    And the response body should not be empty


  
  @positive @smoke @creator @company-user-create
  Scenario: Create a super user (email, no identity triple) returns 201
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "super user", "first_name": "Cory", "email": "superu{RANDOM_STRING:8}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 201
    And the response should match json schema "schemas/user/success/company_user_create_success_schema.json"
    And the company user create success response should be valid

  @positive @creator @company-user-create
  Scenario: Create a super user (mobile instead of email) returns 201
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "super user", "first_name": "Cory", "mobile": "98{RANDOM_INT:10000000:99999999}" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 201
    And the company user create success response should be valid

  @positive @creator @company-user-create
  Scenario: Create a super user (identity triple omitted) returns 201
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "super user", "first_name": "Sam", "email": "superu{RANDOM_STRING:8}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 201
    And the company user create success response should be valid

  @positive @creator @company-user-create
  Scenario: Create super user with full optional profile (address, coverage, allocation, timeout) returns 201
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}", "user_type": "super user",
        "first_name": "John", "last_name": "Doe", "email": "fulluser{RANDOM_STRING:8}@credgenics.com",
        "country_isd_code": "+91", "session_timeout_duration": 60,
        "profession": "collection manager", "team": "north", "location": "mumbai", "department": "recovery",
        "allocation_capacity": 200, "client_employee_id": "EMP{RANDOM_INT:1000:9999}",
        "coverage_areas": ["maharashtra", "gujarat"], "territory_code": "MH-01",
        "address_text": "123 Main Street", "address_city": "Mumbai", "address_state": "Maharashtra",
        "address_pincode": "400001", "address_latitude": "19.076090", "address_longitude": "72.877426",
        "whitelisted_ip_addresses": ["10.0.0.1"]
      }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 201
    And the company user create success response should be valid


  @negative @creator @company-user-create
  Scenario: Neither email nor mobile provided returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "NoContact" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: Missing first_name (required) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "email": "nofn{RANDOM_STRING:6}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: first_name present but empty string returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "", "email": "emptyfn{RANDOM_STRING:6}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: first_name present but null returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "placeholder", "email": "nullfn{RANDOM_STRING:6}@credgenics.com" }
      """
    And I update JSON field "first_name" to null
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: first_name starting with a disallowed character returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "=cmd", "email": "badfn{RANDOM_STRING:6}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: first_name one character over max length (51 chars) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "Aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "email": "longfn{RANDOM_STRING:6}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: Invalid email format returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "Bad", "email": "not-an-email" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: Invalid mobile format returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "Bad", "mobile": "12ab" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @boundary @creator @company-user-create
  Scenario: session_timeout_duration not in allowed set returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "Tim", "email": "timeout{RANDOM_STRING:6}@credgenics.com", "session_timeout_duration": 45 }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: field-executive profession without field_collection_limit returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "Fred", "mobile": "98{RANDOM_INT:10000000:99999999}", "profession": "field executive" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: super user with a non-null identity triple returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "super user", "first_name": "Sam", "email": "supbad{RANDOM_STRING:6}@credgenics.com", "role_id": "role1234abcd5678", "profile_id": "prof1234abcd5678", "reports_to_user_id": "mgr01234abcd5678" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: source=form non-co-admin user missing the identity triple returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "source": "form", "first_name": "Frank", "email": "formuser{RANDOM_STRING:6}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: allocation_capacity not a whole number returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "Al", "email": "alloc{RANDOM_STRING:6}@credgenics.com", "allocation_capacity": "abc" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: Invalid profession enum returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "Pro", "email": "prof{RANDOM_STRING:6}@credgenics.com", "profession": "astronaut" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: Missing company_id body field returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "user_type": "co-admin", "first_name": "NoCompany", "email": "noco{RANDOM_STRING:6}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
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
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the company user create failure response should be valid

  @negative @creator @company-user-create
  Scenario: Create with missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "NoAuth", "email": "noauth{RANDOM_STRING:6}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator @company-user-create
  Scenario: Create with invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "user_type": "co-admin", "first_name": "BadAuth", "email": "badauth{RANDOM_STRING:6}@credgenics.com" }
      """
    When I send a "POST" request to "/user/company/users/"
    Then the response status code should be 400
    And the response body should not be empty
