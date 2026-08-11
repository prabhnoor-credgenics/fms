@positive @api @chief-admin @permission-page @permission-update
Feature: Company Permission - Update and Validate Permission Configuration

Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And scenario loan id is unique
    And I grant the current user all loan permissions

@permission-update
Scenario Outline: Fetch existing company permission and update read or write access

    # 1. FETCH CURRENT COMPANY PERMISSION

    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"

    And I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json |
      | x-company-id        | {COMPANY_ID:creator0} |
      | role                | admin            |

    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |

    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |

    When I send a "GET" request to "/user/profiles/{profile_id}"

    Then the response status code should be 200

    And the response message should be "profile data fetched successfully"

    And the response should match json schema "schemas/permission/success/company_permission_details.json"

    And the response body should contain field "data.profile_details" as "object"

    And the response body should contain field "data.profile_details.permissions" as "object"

    # 2. CONFIRM PERMISSION TO BE UPDATED EXISTS

    And the response body should contain field "{permissionPath}" as "object"

    And the response body should contain field "{permissionPath}.meta_data.name" as "string" with value "{permissionName}"

    And the response body should contain field "{permissionPath}.meta_data.description" as "string" with value "{permissionDescription}"

    And the response body should contain field "{permissionPath}.levels"

    And the response body should contain field "{permissionPath}.{accessType}" as "boolean" with value "{initialState}"

    # 3. PREPARE PATCH REQUEST

    Given I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json |
      | x-company-id        | {COMPANY_ID:creator0} |
      | role                | admin            |

    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |

    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |

    And I set the request body from file "test-data/permission/update_company_permission.json"

    # 4. UPDATE SELECTED READ / WRITE PERMISSION

    And I update JSON field "{permissionPath}.{accessType}" as "boolean" to "{updatedState}"

    # 5. PATCH COMPANY PERMISSION

    When I send a "PATCH" request to "/user/profiles/{profile_id}"

    Then the response status code should be 200

    And the response message should be "permission group updated successfully"

    And the response should match json schema "schemas/permission/success/permission_group_update.json"

    And the response body should contain field "data.profile_id" as "string" with value "anexjjvliuaihjei"

    And the response body should contain field "data.calling_user_result" as "string" with value "User account(s) updated successfully"


Examples:
    | permissionPath                      | permissionName                | permissionDescription                                                                        | accessType | initialState | updatedState |
    | calling.additional_contact_number   | Add Additional Contact Number | Provides access to add additional contact number against the loan id through calling pop-up  | write      | true         | false        |
    | calling.agent_leaderboard           | Agent Leaderboard             |                                                                                              | read       | true         | false        |
    | Segment Management.segment          | Segment                       |                                                                                              | write      | false        | true         |
    | Segment Management.group_segment    | Group Segment                 |                                                                                              | read       | false        | true         |


@positive @api @chief-admin @permission-validation
Scenario: Validate company permission metadata and access controls

    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"

    Given I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json |
      | x-company-id        | {COMPANY_ID:creator0} |
      | role                | admin            |

    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |

    And I set the path parameters:
      | profile_id | anexjjvliuaihjei |

    When I send a "GET" request to "/user/profiles/{profile_id}"

    Then the response status code should be 200

    And the response message should be "profile data fetched successfully"

    And I validate company permissions against test data "test-data/company_permission_validation.json"