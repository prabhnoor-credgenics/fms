@positive @api @chief-admin @permission-page
Feature: Company Permission - Update and Validate Permission Configuration

  # Scenario 1: Update/Persistence Testing
  # GET → capture original state → PATCH → GET again → verify ONLY the changed permission persisted

  @permission-update
  Scenario Outline: Update permission and verify persistence
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"

    # 1. GET - Capture original state
    And I prepare a request
    And I set the request headers:
      | accept              | application/json         |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
      | x-company-id        | {COMPANY_ID:approver0}   |
      | role                | admin                    |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response message should be "profile data fetched successfully"
    And the response should match json schema "schemas/permission/success/company_permission_details.json"
    And the response body should contain field "data.profile_details.permissions.<module>.<permission>.meta_data.name" as "string" with value "<permissionName>"
    And I capture response field "data.profile_details.permissions.<module>.<permission>.<accessType>" as "originalState"

    # 2. PATCH - Update permission using test data file
    And I prepare a request
    And I set the request headers:
      | accept              | application/json         |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
      | x-company-id        | {COMPANY_ID:approver0}   |
      | role                | admin                    |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |
    And I set the request body from file "test-data/permission/update_company_permission.json"
    And I update JSON field "permissions.<module>.<permission>.<accessType>" as "boolean" to "<updatedState>"
    When I send a "PATCH" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response message should be "permission group updated successfully"

    # 3. GET again - Verify ONLY the changed permission persisted
    And I prepare a request
    And I set the request headers:
      | accept              | application/json         |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
      | x-company-id        | {COMPANY_ID:approver0}   |
      | role                | admin                    |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/permission/success/company_permission_details.json"
    And the response body should contain field "data.profile_details.permissions.<module>.<permission>.meta_data.name" as "string" with value "<permissionName>"
    And the response body should contain field "data.profile_details.permissions.<module>.<permission>.<accessType>" as "boolean" with value "<updatedState>"

    # 4. Revert to original state
    And I prepare a request
    And I set the request headers:
      | accept              | application/json         |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
      | x-company-id        | {COMPANY_ID:approver0}   |
      | role                | admin                    |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |
    And I set the request body from file "test-data/permission/update_company_permission.json"
    And I update JSON field "permissions.<module>.<permission>.<accessType>" as "boolean" to "{CAPTURED:originalState}"
    When I send a "PATCH" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200

    Examples:
      | module  | permission                   | permissionName               | accessType | updatedState |
      | fos     | branch_collection_management | branch_collection_management | write      | false        |
      | fos     | change_requests_module       | change_requests_module       | read       | false        |
      | calling | click_to_call                | Click To Call                | write      | false        |
      | calling | campaign                     | Campaign Management          | read       | false        |


  # Scenario 2: Complete Permission-Catalogue Validation
  # GET → company_permission_validation.json → iterate/validate ALL permissions

  @permission-validation
  Scenario: Validate all company permissions against catalogue
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"

    # GET - Fetch all permissions
    And I prepare a request
    And I set the request headers:
      | accept              | application/json         |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
      | x-company-id        | {COMPANY_ID:approver0}   |
      | role                | admin                    |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |
    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response message should be "profile data fetched successfully"
    And the response should match json schema "schemas/permission/success/company_permission_details.json"
    And I validate company permissions against test data "test-data/company_permission_validation.json"
