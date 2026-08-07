@api @approver @user-export
Feature: User Export API - DownloadNow

  @approver @positive @smoke @regression @user-export
  Scenario Outline: Download NOW with valid authentication token - <reportName>
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    Given I capture the current time as "CURRENT_TIME"
    And I set the request body from file "test-data/UserExport/<requestFile>"
    When I send a "POST" request to "/user/export/<endpoint>"
    Then the response status code should be 200
    And the response should match json schema "<successSchema>"
    And the response message should be "<successMessage>"

    Examples:
      | reportName                | requestFile                              | endpoint                | successSchema                                             | successMessage                                   |
      | User Details              | UserExport_UserDetails_Report1.json      | user-details            | schemas/UserExport/success/UserDetails_DownloadNow_01.json | user accounts export link generated successfully |
      | User Details Audit        | UserExport_UserDetailsAudit_Report1.json | user-audit-report       | schemas/UserExport/success/UserDetailsAudit_DownloadNow.json | user accounts export link generated successfully |
      | Detailed Activity Session | UserExport_DetailedActivitySession_Report1.json         | activity-session-report | schemas/UserExport/success/DetailedActivitySession_DownloadNow_01.json | user accounts export link generated successfully |
      | Detailed Login Session    | UserExport_DetailedLoginSession_Report1.json | login-session-report    | schemas/UserExport/success/DetailedLoginSession_DownloadNow_01.json | user accounts export link generated successfully |
      | Session Summary           | UserExport_SessionSummary_Report1.json   | user-summary-report     | schemas/UserExport/success/SessionSummary_DownloadNow.json | user accounts export link generated successfully |


#  @approver @positive @smoke @regression @user-details-report
#  Scenario: Fetch the users for a company with valid authentication token
#    And I authenticate as "approver" slot 0 and remember as "approver0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id   | {COMPANY_ID} |
#      | page_number  | 1 |
#      | search_type  | name |
#    When I send a "GET" request to "/user/company/users"
#    Then the response status code should be 200
#
#
#  @positive @smoke @chief-admin @global-user-create
#  Scenario: Create a super user (email) in caller's company returns 201
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | referer             | abc              |
#    And I set the request body:
#      """
#      { "first_name": "Sam", "email": "globalu{RANDOM_STRING:8}@credgenics.com", "user_type": "super user", "assigned_companies": [ { "company_id": "{COMPANY_ID:creator0}" } ] }
#      """
#    When I send a "POST" request to "/user/global/users/"
#    Then the response status code should be 201
#    And the response should match json schema "schemas/user/success/global_user_create_success_schema.json"
#    And the global user create response should be valid
#
#
#  @approver @negative @regression @user-details-report
#  Scenario: API should return 400 when authentication token is missing - User Details Report Download NOW
#    And I prepare a request
#    And I set the request headers:
#      | accept       | application/json |
#      | x-company-id | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id | {COMPANY_ID} |
#    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
#    When I send a "POST" request to "/user/export/user-details"
#    Then the response status code should be 400
#
#
#  @approver @negative @regression @user-details-report
#  Scenario: API should return 400 when company_id is null in payload - User Details Report Download NOW
#    And I authenticate as "approver" slot 0 and remember as "approver0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id | {COMPANY_ID} |
#    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
#    And I update JSON field "company_id" as "string" to "null"
#    When I send a "POST" request to "/user/export/user-details"
#    Then the response status code should be 400
#
#
#  @approver @negative @regression @user-details-report
#  Scenario: API should return 400 when data_scope is invalid - User Details Report Download NOW
#    And I authenticate as "approver" slot 0 and remember as "approver0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id | {COMPANY_ID} |
#    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
#    And I update JSON field "data_scope" as "string" to "invalid_scope"
#    When I send a "POST" request to "/user/export/user-details"
#    Then the response status code should be 400
#
#
#  @approver @positive @smoke @regression @user-details-report
#  Scenario: Download NOW with valid authentication token - User Details Report Download NOW
#    And I authenticate as "approver" slot 0 and remember as "approver0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id   | {COMPANY_ID} |
#    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
#    When I send a "POST" request to "/user/export/user-details"
#    Then the response status code should be 200
#    And the response should match json schema "schemas/UserExport/success/UserDetails_DownloadNow_01.json"
#    And the response message should be "user accounts export link generated successfully"
#
#
#  @approver @positive @smoke @regression @user-details-report
#  Scenario: Download NOW with created date filter - User Details Report Download NOW
#    And I authenticate as "approver" slot 0 and remember as "approver0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id | {COMPANY_ID} |
#    And I set the request body from file "test-data/UserExport_UserDetails_Report2.json"
#    When I send a "POST" request to "/user/export/user-details"
#    Then the response status code should be 200
#    And the response should match json schema "schemas/UserExport/success/UserDetails_DownloadNow_01.json"
#    And the response message should be "user accounts export link generated successfully"
#
#  @approver @positive @smoke @regression @user-details-report
#  Scenario: API should return 200 when created_date_start is greater than created_date_end - User Details Report Download NOW
#    And I authenticate as "approver" slot 0 and remember as "approver0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id | {COMPANY_ID} |
#    And I set the request body from file "test-data/UserExport_UserDetails_Report2.json"
#    And I update JSON field "created_date_start" as "string" to "2026-08-10 00:00:00"
#    And I update JSON field "created_date_end" as "string" to "2026-08-05 23:59:59"
#    When I send a "POST" request to "/user/export/user-details"
#    Then the response status code should be 200
#    And the response should match json schema "schemas/UserExport/error/UserDetails_DownloadNow_01.json"
#    And the response message should be "no data found"


