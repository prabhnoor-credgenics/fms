#@api @approver
Feature: Global User Management

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

  Scenario: User has valid admin credentials with access to "User Management".
