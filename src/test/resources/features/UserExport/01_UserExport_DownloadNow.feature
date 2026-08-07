@api @approver @user-export
Feature: User Export API


  @approver @positive @smoke @regression @user-details-report
  Scenario: Fetch the users for a company with valid authentication token
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1 |
      | search_type  | name |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200


  @approver @negative @regression @user-details-report
  Scenario: API should return 400 when authentication token is missing - User Details Report Download NOW
    And I prepare a request
    And I set the request headers:
      | accept       | application/json |
      | x-company-id | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
    When I send a "POST" request to "/user/export/user-details"
    Then the response status code should be 400


  @approver @negative @regression @user-details-report
  Scenario: API should return 400 when company_id is null in payload - User Details Report Download NOW
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
    And I update JSON field "company_id" as "string" to "null"
    When I send a "POST" request to "/user/export/user-details"
    Then the response status code should be 400


  @approver @negative @regression @user-details-report
  Scenario: API should return 400 when data_scope is invalid - User Details Report Download NOW
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
#    And I update JSON field "data_scope" to "invalid_scope"
    And I update JSON field "data_scope" as "string" to "invalid_scope"
    When I send a "POST" request to "/user/export/user-details"
    Then the response status code should be 400


  @approver @positive @smoke @regression @user-details-report
  Scenario: Download NOW with valid authentication token - User Details Report Download NOW
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
    When I send a "POST" request to "/user/export/user-details"
    Then the response status code should be 200
    And the response should match json schema "schemas/UserExport/success/UserDetails_DownloadNow_01.json"
    And the response message should be "user accounts export link generated successfully"


  @approver @positive @smoke @regression @user-details-report
  Scenario: Download NOW with created date filter - User Details Report Download NOW
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report2.json"
    When I send a "POST" request to "/user/export/user-details"
    Then the response status code should be 200
    And the response should match json schema "schemas/UserExport/success/UserDetails_DownloadNow_01.json"
    And the response message should be "user accounts export link generated successfully"

  @approver @positive @smoke @regression @user-details-report
  Scenario: API should return 200 when created_date_start is greater than created_date_end - User Details Report Download NOW
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report2.json"
#    And I update JSON field "created_date_start" to "2026-08-10 00:00:00"
    And I update JSON field "created_date_start" as "string" to "2026-08-10 00:00:00"
    And I update JSON field "created_date_end" as "string" to "2026-08-05 23:59:59"
    When I send a "POST" request to "/user/export/user-details"
    Then the response status code should be 200
    And the response should match json schema "schemas/UserExport/error/UserDetails_DownloadNow_01.json"
    And the response message should be "no data found"

  @approver @negative @regression @users-report
  Scenario: API should return 400 when authentication token is missing - Users Report Export Over Mail
    And I prepare a request
    And I set the request headers:
      | accept       | application/json |
      | x-company-id | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
    When I send a "POST" request to "/user/export/users"
    Then the response status code should be 400


  @approver @negative @regression @users-report
  Scenario: API should return 400 when company_id is null in payload - Users Report Export Over Mail
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
    And I update JSON field "company_id" as "string" to "null"
    When I send a "POST" request to "/user/export/users"
    Then the response status code should be 400


  @approver @negative @regression @users-report
  Scenario: API should return 400 when data_scope is invalid - Users Report Export Over Mail
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
    And I update JSON field "data_scope" as "string" to "invalid_scope"
    When I send a "POST" request to "/user/export/users"
    And the response should match json schema "schemas/UserExport/error/UserDetails_Export_Over_Mail_01.json"
    Then the response status code should be 400


  @approver @positive @smoke @regression @users-report
  Scenario: Download NOW with valid authentication token - Users Report Export Over Mail
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report1.json"
    When I send a "POST" request to "/user/export/users"
    Then the response status code should be 200
    And the response should match json schema "schemas/UserExport/success/UserDetails_Export_over_Mail_01.json"

  @approver @positive @smoke @regression @users-report
  Scenario: Download NOW with created date filter - Users Report Export Over Mail
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report2.json"
    When I send a "POST" request to "/user/export/users"
    Then the response status code should be 200
    And the response should match json schema "schemas/UserExport/success/UserDetails_Export_over_Mail_01.json"


  @approver @positive @smoke @regression @users-report
  Scenario: API should return 200 when created_date_start is greater than created_date_end - Users Report Export Over Mail
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |
      | x-company-id        | {COMPANY_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/UserExport_UserDetails_Report2.json"
    And I update JSON field "created_date_start" as "string" to "2026-07-10 00:00:00"
    And I update JSON field "created_date_end" as "string" to "2026-07-09 23:59:59"
    When I send a "POST" request to "/user/export/users"
    Then the response status code should be 200
    And the response should match json schema "schemas/UserExport/success/UserDetails_Export_over_Mail_02.json"
    And the response message should be "No data found"