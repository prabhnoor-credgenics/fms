@API @UserMandatoryCheck @POD1
Feature: User Creation - Mandatory Fields Check

Background:
    Given I authenticate as "approver" slot 0 and remember as "approver0"

@Positive @Smoke @approver
Scenario: TC001 - Fetch user creation variables successfully
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/user_creation_form.json"
    And the response message should be "variables fetched successfully"


@Negative @Regression @approver
Scenario Outline: TC002 - User creation validation with invalid field values
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be <status>
    And the response message should be "<message>"

Examples:
| field               | value                      | status | message                                                                        |
| email               | mihir.kumar@credgenics.com | 400    | User already exists with different credentials, kindly provide the correct set of credentials. |
| email               | MIHIR.KUMAR@credgenics.com | 400    | User already exists with different credentials, kindly provide the correct set of credentials. |
| address_latitude    | 242232                     | 400    | Value error, Latitude out of range.                                            |
| address_longitude   | 1831                       | 400    | Value error, Longitude out of range.                                           |
| mobile              | 732008164098               | 400    | invalid mobile number ,having country ISD code: +91                            |
| mobile              | 7320081640                 | 400    | User already exists with different credentials, kindly provide the correct set of credentials. |


@Negative @Regression @approver
Scenario: TC003 - User creation fails when email and mobile belong to different users
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "email" as "auto" to "jhunjhun.yadav@credgenics.com"
    And I update JSON field "mobile" as "auto" to "7320081640"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 409
    And the response message should be "provided email or mobile belong to different existing users"


@Negative @Regression @approver
Scenario: TC004 - User creation rejects email with more than 64 characters
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "email" as "auto" to "abdc{RANDOM_STRING:65}@yopmail.com"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 400
    And the response message should be "Value error, Invalid email address"


@Positive @Regression @approver
Scenario: TC005 - User creation accepts email with leading and trailing spaces
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "email" as "auto" to "  abdc{RANDOM_STRING:5}@yopmail.com  "
    And I update JSON field "mobile" as "auto" to "73200{RANDOM_INT:10000:99999}"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 201
    And the response message should be "user account created successfully"


@Positive @Regression @approver
Scenario: TC006 - User creation with valid email and mobile succeeds
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "email" as "auto" to "abdc{RANDOM_STRING:5}@yopmail.com"
    And I update JSON field "mobile" as "auto" to "73200{RANDOM_INT:10000:99999}"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 201
    And the response message should be "user account created successfully"


@Positive @Regression @approver
Scenario: TC007 - Validate company admin role hierarchy
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/roles/hierarchy"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/role_hierarchy_success_schema.json"
    And the response message should be "role hierarchy fetched successfully"
    And the response body should contain field "data.role_hierarchy[0].role_name" as "auto" with value "company admin"


@Positive @Regression @approver
Scenario: TC008 - Validate territory details response schema
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/territory_body.json"
    When I send a "POST" request to "/user/territory/details"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/territory_details_count_schema.json"
    And the response message should be "Territory details fetched successfully."


@Positive @Smoke @approver
Scenario: TC009 - Validate newly created user is listed and user count increases
    # 1. Fetch initial user count
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200
    And I store response field "data.total_count" as "initialUserCount"

    # 2. Create a new user
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "email" as "auto" to "abdc{RANDOM_STRING:5}@yopmail.com"
    And I update JSON field "mobile" as "auto" to "73200{RANDOM_INT:10000:99999}"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 201
    And I capture response field "data.user_id" as "createdUserId"
    And the response message should be "user account created successfully"

    # 3. Fetch user list again and verify count increased by 1
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200
    And the response message should be "user accounts fetched successfully"
    And the response body field "data.total_count" should be captured value "initialUserCount" "increase" by 1


@Positive @Smoke @approver
Scenario: TC010 - Search newly created user by user_id and verify it is listed
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "email" as "auto" to "abdc{RANDOM_STRING:5}@yopmail.com"
    And I update JSON field "mobile" as "auto" to "73200{RANDOM_INT:10000:99999}"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 201
    And I capture response field "data.user_id" as "createdUserId"
    And the response message should be "user account created successfully"

    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}             |
      | search_type  | user_id                  |
      | search_query | {CAPTURED:createdUserId} |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200
    And the response message should be "user accounts fetched successfully"
    And the response body should contain field "data.users[0].user_id" as "auto" with value "{CAPTURED:createdUserId}"
    And the response body should contain field "data.total_count" as "int" with value "1"


@Positive @Smoke @approver
Scenario: TC011 - Delete the newly created user
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "email" as "auto" to "abdc{RANDOM_STRING:5}@yopmail.com"
    And I update JSON field "mobile" as "auto" to "73200{RANDOM_INT:10000:99999}"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 201
    And I capture response field "data.user_id" as "createdUserId"
    And the response message should be "user account created successfully"

    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | user_id | {CAPTURED:createdUserId} |
    When I send a "DELETE" request to "/user/company/users/{user_id}"
    Then the response status code should be 200
    And the response message should be "user account deleted successfully"
    And the response body should contain field "data.rowcount" as "int" with value "1"


@Positive @Smoke @approver
Scenario: TC012 - Validate user filter data API response schema
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "email" as "auto" to "abdc{RANDOM_STRING:5}@yopmail.com"
    And I update JSON field "mobile" as "auto" to "73200{RANDOM_INT:10000:99999}"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 201
    And I capture response field "data.user_id" as "createdUserId"
    And the response message should be "user account created successfully"

    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/users/filter"
    Then the response status code should be 200
    And the response message should be "user accounts filter data fetched successfully"
    And the response should match json schema "schemas/user/success/user_filter_schema.json"

    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/users/filter"
    Then the response status code should be 200
    And the response message should be "user accounts filter data fetched successfully"
    And I store response field "data.filters.roles[1].value" as "roleId"

    # Apply captured role filter
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}      |
      | page_number | 1                 |
      | roles       | {CAPTURED:roleId} |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200
    And the response message should be "user accounts fetched successfully"
    And the response body should contain field "data.total_count" as "int" with value "8"
    And the response body should contain field "data.users[0].role_id" as "string" with value "{CAPTURED:roleId}"
    And the response body should contain field "data.users[1].role_id" as "string" with value "{CAPTURED:roleId}"
    And the response body should contain field "data.users[2].role_id" as "string" with value "{CAPTURED:roleId}"


@Positive @Regression @approver
Scenario: TC013 - Validate user list with multiple filters applied
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id        | {COMPANY_ID}     |
      | page_number       | 1                |
      | permission_groups | arvken14ze01rkp4 |
      | profession        | lawyer           |
      | roles             | xs1vliik024bn2e0 |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200
    And the response message should be "user accounts fetched successfully"
    And the response body should contain field "data.total_count" as "int" with value "2"
    And the response body should contain field "data.users[0].profile_id" as "auto" with value "arvken14ze01rkp4"
    And the response body should contain field "data.users[0].profession" as "string" with value "lawyer"
    And the response body should contain field "data.users[0].role_id" as "auto" with value "xs1vliik024bn2e0"
    And the response body should contain field "data.users[1].profile_id" as "auto" with value "arvken14ze01rkp4"
    And the response body should contain field "data.users[1].profession" as "string" with value "lawyer"
    And the response body should contain field "data.users[1].role_id" as "auto" with value "xs1vliik024bn2e0"


@Positive @Regression @approver
Scenario Outline: TC014 - Search user by original value after creation
    # 1. CREATE USER
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "first_name" as "auto" to "Mihir{RANDOM_STRING:5}"
    And I update JSON field "email" as "auto" to "abdc{RANDOM_STRING:5}@yopmail.com"
    And I update JSON field "mobile" as "auto" to "73200{RANDOM_INT:10000:99999}"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 201
    And I capture response field "data.user_id" as "createdUserId"
    And I capture request field "first_name" as "createdFirstName"
    And I capture request field "email" as "createdUserEmail"
    And I capture request field "mobile" as "createdUserMobile"
    And the response message should be "user account created successfully"

    # 2. SEARCH USER USING ORIGINAL VALUE
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}  |
      | search_type  | <searchType>  |
      | search_query | <searchValue> |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200
    And the response message should be "user accounts fetched successfully"
    And the response body should contain field "data.users[0].user_id" as "auto" with value "{CAPTURED:createdUserId}"

Examples:
  | searchType | searchValue                 |
  | name       | {CAPTURED:createdFirstName} |
  | email      | {CAPTURED:createdUserEmail} |
  | mobile     | {CAPTURED:createdUserMobile}|


@Positive @Regression @approver
Scenario Outline: TC015 - Search user, update field and verify updated value
    # 1. CREATE USER
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/create_user_correct_value.json"
    And I update JSON field "first_name" as "auto" to "Mihir{RANDOM_STRING:5}"
    And I update JSON field "email" as "auto" to "abdc{RANDOM_STRING:5}@yopmail.com"
    And I update JSON field "mobile" as "auto" to "73200{RANDOM_INT:10000:99999}"
    When I send a "POST" request to "/user/company/users"
    Then the response status code should be 201
    And I capture response field "data.user_id" as "createdUserId"
    And I capture request field "first_name" as "createdFirstName"
    And I capture request field "email" as "createdUserEmail"
    And I capture request field "mobile" as "createdUserMobile"
    And the response message should be "user account created successfully"

    # 2. SEARCH USER USING ORIGINAL VALUE
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}  |
      | search_type  | <searchType>  |
      | search_query | <searchValue> |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200
    And the response message should be "user accounts fetched successfully"
    And the response body should contain field "data.users[0].user_id" as "auto" with value "{CAPTURED:createdUserId}"

    # 3. UPDATE THE SAME FIELD THAT WAS SEARCHED
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | user_id | {CAPTURED:createdUserId} |
    And I set the request body:
      """
      {
        "<updateField>": "<updatedValue>"
      }
      """
    When I send a "PATCH" request to "/user/users/{user_id}"
    Then the response status code should be 200
    And I capture request field "<updateField>" as "updatedFieldValue"

    # 4. SEARCH USING UPDATED VALUE
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}                 |
      | search_type  | <searchType>                 |
      | search_query | {CAPTURED:updatedFieldValue} |
    When I send a "GET" request to "/user/company/users"
    Then the response status code should be 200
    And the response message should be "user accounts fetched successfully"
    And the response body should contain field "data.total_count" as "int" with value "1"
    And the response body should contain field "data.users[0].user_id" as "auto" with value "{CAPTURED:createdUserId}"
    And the response body should contain field "<responseField>" as "string" with value "{CAPTURED:updatedFieldValue}"

Examples:
  | searchType | searchValue                 | updateField | updatedValue                            | responseField            |
  | name       | {CAPTURED:createdFirstName} | first_name  | MihirUpd{RANDOM_INT:10000:99999}        | data.users[0].first_name |
  | email      | {CAPTURED:createdUserEmail} | email       | updated{RANDOM_INT:10000:99999}@yopmail.com | data.users[0].email  |
  | mobile     | {CAPTURED:createdUserMobile}| mobile      | 73200{RANDOM_INT:10000:99999}           | data.users[0].mobile     |
