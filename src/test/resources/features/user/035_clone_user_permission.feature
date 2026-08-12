@positive @api @approver @permission-group

Feature: Permission Group Creation and Clone Validation

  Background:
    Given I authenticate as "approver" slot 0 and remember as "approver0"


  Scenario Outline: Create permission group by cloning an existing permission group and verify cloned permission metadata

    # 1. FETCH AVAILABLE PERMISSION GROUPS

    Given I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |

    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | profile_type | self         |

    When I send a "GET" request to "/user/profiles"

    Then the response status code should be 200

    And the response message should be "profiles fetched successfully"

    And the response should match json schema "schemas/permission/success/permission_group_list.json"

    And the response body should contain field "data.profiles"

    # 2. CAPTURE SOURCE PERMISSION GROUP

    And I capture response field "data.profiles[2].profile_id" as "sourceProfileId"

    And I capture response field "data.profiles[2].profile_name" as "sourceProfileName"

    # 3. FETCH SOURCE PERMISSION GROUP DETAILS

    Given I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |
      | role                | admin            |

    And I set the query parameters:
      | company_id | {COMPANY_ID} |

    And I set the path parameters:
      | profile_id | {CAPTURED:sourceProfileId} |

    When I send a "GET" request to "/user/profiles/{profile_id}"

    Then the response status code should be 200

    And the response message should be "profile data fetched successfully"

    And the response should match json schema "schemas/permission/success/permission_group_details.json"

    # 4. VALIDATE SOURCE PERMISSION GROUP

    And the response body should contain field "data.profile_details.profile_id" as "auto" with value "{CAPTURED:sourceProfileId}"

    And the response body should contain field "data.profile_details.profile_name" as "string" with value "{CAPTURED:sourceProfileName}"

    And the response body should contain field "data.profile_details.permissions"

    # 5. CAPTURE SOURCE PERMISSION METADATA

    And I capture response field "data.profile_details.permissions['<permissionModule>']['<permissionKey>'].meta_data.name" as "sourcePermissionName"

    And I capture response field "data.profile_details.permissions['<permissionModule>']['<permissionKey>'].meta_data.description" as "sourcePermissionDescription"

    # 6. CREATE NEW PERMISSION GROUP

    Given I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | content-type        | application/json |
      | x-company-id        | {COMPANY_ID}     |
      | role                | admin            |

    And I set the query parameters:
      | company_id | {COMPANY_ID} |

    And I set the request body from file "test-data/create_permission_group_permission_page.json"

    And I update JSON field "profile_name" as "auto" to "<permissionGroupName>"

    And I update JSON field "profile_description" as "string" to "<permissionGroupDescription>"

    When I send a "POST" request to "/user/profiles"

    Then the response status code should be 201

    And the response message should be "profile created successfully"

    And I capture response field "data.profile_id" as "createdProfileId"

    # 7. VALIDATE CREATED PROFILE ID

    And the response body should contain field "data.profile_id" as "auto" with value "{CAPTURED:createdProfileId}"

    # 8. FETCH PERMISSION GROUP LIST AGAIN

    Given I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |

    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | profile_type | self         |

    When I send a "GET" request to "/user/profiles"

    Then the response status code should be 200

    And the response message should be "profiles fetched successfully"

    And the response should match json schema "schemas/permission/success/permission_group_list.json"

    And the response body should contain field "data.profiles"

    # 9. FETCH CREATED PERMISSION GROUP DETAILS

    Given I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |
      | role                | admin            |

    And I set the query parameters:
      | company_id | {COMPANY_ID} |

    And I set the path parameters:
      | profile_id | {CAPTURED:createdProfileId} |

    When I send a "GET" request to "/user/profiles/{profile_id}"

    Then the response status code should be 200

    And the response message should be "profile data fetched successfully"

    And the response should match json schema "schemas/permission/success/permission_group_details.json"

    # 10. VALIDATE CREATED PERMISSION GROUP

    And the response body should contain field "data.profile_details.profile_id" as "auto" with value "{CAPTURED:createdProfileId}"

    And I capture response field "data.profile_details.profile_name" as "createdProfileName"

    And the response body should contain field "data.profile_details.profile_name" as "string" with value "{CAPTURED:createdProfileName}"

    And the response body should contain field "data.profile_details.profile_description" as "string" with value "<permissionGroupDescription>"

    And the response body should contain field "data.profile_details.permissions"

    # 11. VALIDATE CLONED PERMISSION

    And the response body should contain field "data.profile_details.permissions['<permissionModule>']['<permissionKey>']"

    And the response body should contain field "data.profile_details.permissions['<permissionModule>']['<permissionKey>'].meta_data.name" as "string" with value "{CAPTURED:sourcePermissionName}"

    And the response body should contain field "data.profile_details.permissions['<permissionModule>']['<permissionKey>'].meta_data.description" as "string" with value "{CAPTURED:sourcePermissionDescription}"

    And the response body should contain field "data.profile_details.permissions['<permissionModule>']['<permissionKey>'].levels"

    And the response body should contain field "data.profile_details.permissions['<permissionModule>']['<permissionKey>']['<permissionAccess>']" as "boolean" with value "true"


    Examples:
      | permissionGroupName                    | permissionGroupDescription | permissionModule        | permissionKey | permissionAccess |
      | clonedpermission{RANDOM_INT:1000:9999} | automated clone permission | User Management Module  | profiles      | write            |
