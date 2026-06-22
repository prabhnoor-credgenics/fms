@api @user @company-users-list
Feature: Company Users List — GET /user/company/users/



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
