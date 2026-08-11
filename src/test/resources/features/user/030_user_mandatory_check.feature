@api @user @roles-list
Feature: Roles — POST /user/creation/ (mandatory fields check)

Background:
    Given I authenticate as "approver" slot 0 and remember as "approver0"

@positive @smoke @approver
Scenario: Fetch user creation variables successfully

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


@negative @duplicate @approver
Scenario Outline: User creation validation

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

                   
 @negative @duplicate @approver
Scenario Outline: User creation validation

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
 
 
 @positive @validation @approver @user @email @api
Scenario: User creation rejects email address for email field with more than 64 characters  

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

@positive @validation @approver @user @email @api
Scenario: User creation accepts email with leading and trailing spaces
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

    @positive @validation @approver @user @email @api
Scenario: User creation accepts Valid email and mobile number and successfully creates user.
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

    @positive@api @approver @role-hierarchy
  Scenario: Validate role hierarchy API response
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

     @positive@api @approver @role-hierarchy
  Scenario: Validate company admin role hierarchy
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

@api @territory @approver@schema-validation
Scenario: Validate territory details response schema
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





