@api
Feature: Global User Management


  @api @user-management @positive @smoke
  Scenario: Fetch users with valid authentication token
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN} |

    When I send a "GET" request to "/user/users"
    Then the response status code should be 200

