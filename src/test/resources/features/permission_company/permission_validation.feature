@positive @api @chief-admin @permission-page @permission-update
Feature: Company Permission - Update and Validate Permission Configuration

@permission-update 
Scenario Outline: Fetch existing company permission and update read or write access

    # 1. AUTHENTICATE
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And scenario loan id is unique

    # 2. FETCH CURRENT COMPANY PERMISSION - VERIFY INITIAL STATE
    And I prepare a request
    And I set the request headers:
      | accept              | application/json           |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0}   |
      | content-type        | application/json           |
      | x-company-id        | {COMPANY_ID:approver0}     |
      | role                | admin                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |

    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response message should be "profile data fetched successfully"
    And the response should match json schema "schemas/permission/success/company_permission_details.json"
    And the response body should contain field "data.profile_details.permissions.<module>.<permission>.meta_data.name" as "string" with value "<permissionName>"
    And the response body should contain field "data.profile_details.permissions.<module>.<permission>.<accessType>" as "boolean" with value "<initialState>"

    # 3. PREPARE AND SEND PATCH REQUEST TO UPDATE PERMISSION
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json           |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0}   |
      | content-type        | application/json           |
      | x-company-id        | {COMPANY_ID:approver0}     |
      | role                | admin                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |
    And I set the request body from file "test-data/permission/update_company_permission.json"
    And I update JSON field "permissions.<module>.<permission>.<accessType>" as "boolean" to "<updatedState>"

    When I send a "PATCH" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response message should be "permission group updated successfully"
    And the response should match json schema "schemas/permission/success/permission_group_update.json"
    And the response body should contain field "data.profile_id" as "string" with value "anexjjvliuaihjei"
    And the response body should contain field "data.calling_user_result" as "string" with value "User account(s) updated successfully"

    # 4. FETCH AGAIN TO VERIFY UPDATE WAS APPLIED
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json           |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0}   |
      | content-type        | application/json           |
      | x-company-id        | {COMPANY_ID:approver0}     |
      | role                | admin                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |

    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response body should contain field "data.profile_details.permissions.<module>.<permission>.<accessType>" as "boolean" with value "<updatedState>"

    # 5. REVERT BACK TO INITIAL STATE
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json           |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0}   |
      | content-type        | application/json           |
      | x-company-id        | {COMPANY_ID:approver0}     |
      | role                | admin                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |
    And I set the request body from file "test-data/permission/update_company_permission.json"
    And I update JSON field "permissions.<module>.<permission>.<accessType>" as "boolean" to "<initialState>"

    When I send a "PATCH" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response message should be "permission group updated successfully"

Examples:
    | module | permission                   | permissionName               | accessType | initialState | updatedState |
    | fos    | branch_collection_management | branch_collection_management | write      | true         | false        |
    | fos    | change_requests_module       | change_requests_module       | read       | true         | false        |


@positive @api @chief-admin @permission-validation @approver
Scenario: Validate company permission metadata and access controls

    Given I authenticate as "approver" slot 0 and remember as "approver0"
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And scenario loan id is unique

    Given I prepare a request
    And I set the request headers:
      | accept              | application/json           |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0}   |
      | content-type        | application/json           |
      | x-company-id        | {COMPANY_ID:approver0}     |
      | role                | admin                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID:approver0} |
    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |

    When I send a "GET" request to "/user/profiles/{profile_id}"
    Then the response status code should be 200
    And the response message should be "profile data fetched successfully"
    And I validate company permissions against test data "test-data/permission/fos_permission_validation.json"
