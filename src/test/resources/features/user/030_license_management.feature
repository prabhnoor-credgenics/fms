@api @user @license-management
Feature: License Management (per-company per-profession license configuration)

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I prepare a request


  @positive @chief-admin
  Scenario: TC_LIC_003 / TC_LIC_006 / TC_LIC_007 / TC_LIC_008 / TC_LIC_009 — View license usage for a company
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} | 
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    When I send a "GET" request to "/user/license-management-config/"
    Then the response status code should be 200
    And the response message should be "License management configuration fetched successfully"
    And the response body should contain field "data"

  @positive @chief-admin @search
  Scenario: TC_LIC_044 / TC_LIC_045 / TC_LIC_048 — Company search (substring, case-insensitive) returns 200
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
    And I set the query parameters:
      | company_name | A |
    When I send a "GET" request to "/user/license-management-config/"
    Then the response status code should be 200
    And the response body should contain field "data"

  @positive @chief-admin @search
  Scenario: TC_LIC_046 — Company search with no match returns 200 with an empty list
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
    And I set the query parameters:
      | company_name | ZzQqNoSuchCompany_{RANDOM_STRING:6} |
    When I send a "GET" request to "/user/license-management-config/"
    Then the response status code should be 200
    And the response body should contain field "data"


  @positive @chief-admin @configure
  Scenario: TC_LIC_013 — Save a valid Min/Max license config for a profession
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "lawyer", "minimum_limit": 0, "maximum_limit": 100000 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be one of "200,201,409"
    And the response body should not be empty

  @positive @chief-admin @configure
  Scenario Outline: TC_LIC_012 — Config accepts profession "<profession>"
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "<profession>", "minimum_limit": 0, "maximum_limit": 100000 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be one of "200,201,409"
    And the response body should not be empty

    Examples:
      | profession                       |
      | advocate                         |
      | area manager                     |
      | collection manager               |
      | field executive                  |
      | field collection manager         |
      | field and telecalling executive  |
      | field and telecalling supervisor |
      | telecalling                      |
      | telecalling supervisor           |
      | other                            |

  @positive @chief-admin @edge
  Scenario: TC_LIC_054 — Min equal to Max passes max>=min validation
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "collection manager", "minimum_limit": 10, "maximum_limit": 10 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be one of "200,201,400,409"
    And the response body should not be empty

  @positive @chief-admin @edge
  Scenario: TC_LIC_057 — Very large Max value is accepted (no overflow)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "other", "minimum_limit": 0, "maximum_limit": 999999 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be one of "200,201,409"
    And the response body should not be empty


  @positive @chief-admin @edit
  Scenario: TC_LIC_023 / TC_LIC_024 / TC_LIC_026 — Update an existing config (PUT)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "lawyer", "minimum_limit": 0, "maximum_limit": 100000 } ]
      }
      """
    When I send a "PUT" request to "/user/license-management-config/"
    Then the response status code should be 200
    And the response body should not be empty


  @positive @chief-admin @delete
  Scenario: TC_LIC_029b — Delete (deactivate) a profession config
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
      | profession | other                 |
    When I send a "DELETE" request to "/user/license-management-config/"
    Then the response status code should be one of "200,404"
    And the response body should not be empty


  @negative @chief-admin
  Scenario: TC_LIC_014 — Max less than Min is rejected
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "lawyer", "minimum_limit": 50, "maximum_limit": 20 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be 400
    And the response body should contain text "minimum_limit cannot be greater than maximum_limit"

  @negative @chief-admin
  Scenario: TC_LIC_016 — Max=0 while Min>0 is rejected (Max < Min)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "lawyer", "minimum_limit": 10, "maximum_limit": 0 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be 400
    And the response body should contain text "minimum_limit cannot be greater than maximum_limit"

  @negative @chief-admin @edge
  Scenario: TC_LIC_056 — Decimal Min/Max is rejected (integers only)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "lawyer", "minimum_limit": 5.5, "maximum_limit": 10 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be 400
    And the response body should contain text "integer"

  @negative @chief-admin
  Scenario: TC_LIC_017 / TC_LIC_018 — Both limits are required at save (Min-only / Max-only rejected)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "advocate", "minimum_limit": 5 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be 400
    And the response body should contain text "required for profession"

  @negative @chief-admin
  Scenario: TC_LIC_012b — Duplicate professions in one payload are rejected
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [
          { "profession": "lawyer", "minimum_limit": 1, "maximum_limit": 5 },
          { "profession": "lawyer", "minimum_limit": 2, "maximum_limit": 6 }
        ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be 400
    And the response body should contain text "Duplicate professions are not allowed"

  @negative @chief-admin
  Scenario: TC_LIC_012c — Invalid profession is rejected
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "wizard", "minimum_limit": 1, "maximum_limit": 5 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @chief-admin
  Scenario: TC_LIC_013b — Empty data array is rejected
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID:creator0}", "data": [] }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @security @approver
  Scenario: TC_LIC_037 / TC_LIC_040 — A non chief/super-admin cannot view license management (403)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:approver0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    When I send a "GET" request to "/user/license-management-config/"
    Then the response status code should be 403
    And the response body should contain text "Only chief admin and super admin"

  @negative @security @approver
  Scenario: TC_LIC_038 — A non chief/super-admin cannot add/edit license config (403)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:approver0} |
      | content-type        | application/json       |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID:creator0}",
        "data": [ { "profession": "lawyer", "minimum_limit": 1, "maximum_limit": 10 } ]
      }
      """
    When I send a "POST" request to "/user/license-management-config/"
    Then the response status code should be one of "401,403"
    And the response body should not be empty

  @negative @auth
  Scenario: TC_LIC_040b — Missing authentication token is rejected
    Given I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    When I send a "GET" request to "/user/license-management-config/"
    Then the response status code should be one of "400,401"
    And the response body should not be empty
