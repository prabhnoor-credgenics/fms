@api @user @roles-list
Feature: Create a new user and verify it is listed in the user search using (Email,Mobile,User_id,Name) and verify user count increases by 1

Background:
Given I authenticate as "approver" slot 0 and remember as "approver0"

@positive @api @approver @user @creation @search
Scenario: Validate newly created user is listed and user count increases and delete the newly created user

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
And the response body field "data.total_count" should be captured value "initialUserCount" "increased" by 1

# 4. Search newly created user by user_id and verify it is listed

And I prepare a request
And I set the request headers:
| accept              | application/json |
| authenticationtoken | {AUTH_TOKEN}     |

And I set the query parameters:
| company_id | {COMPANY_ID} |
| search_type | user_id |
| search_query | {CAPTURED:createdUserId} |

When I send a "GET" request to "/user/company/users"

Then the response status code should be 200
And the response message should be "user accounts fetched successfully"
And the response body should contain field "data.users[0].user_id" as "auto" with value "{CAPTURED:createdUserId}"
And the response body should contain field "data.total_count" as "int" with value "1"

# 5. Delete the newly created user

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

@api @user @filter
Scenario: Validate user filter data API response schema

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


  @api @user @approver @filter @hello
  Scenario: Validate user list when filtering by role

  # Get available filter data

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
    | company_id  | {COMPANY_ID}     |
    | page_number | 1                |
    | roles       | {CAPTURED:roleId} |

  When I send a "GET" request to "/user/company/users"
  Then the response status code should be 200
  And the response message should be "user accounts fetched successfully"
  And the response body should contain field "data.total_count" as "int" with value "6"
  And the response body should contain field "data.users[0].role_id" as "string" with value "{CAPTURED:roleId}"
  And the response body should contain field "data.users[1].role_id" as "string" with value "{CAPTURED:roleId}"
  And the response body should contain field "data.users[2].role_id" as "string" with value "{CAPTURED:roleId}"


@positive @api @approver @user @filter @multiple-filters
Scenario: Validate user list with multiple filters applied

  And I prepare a request

  And I set the request headers:
    | accept              | application/json |
    | authenticationtoken | {AUTH_TOKEN}     |

  And I set the query parameters:
    | company_id         | {COMPANY_ID}       |
    | page_number        | 1                  |
    | permission_groups  | arvken14ze01rkp4   |
    | profession         | lawyer             |
    | roles              | xs1vliik024bn2e0   |

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


@positive @api @approver @user @search @updatedhello

Scenario Outline: Search newly created user, update searched field and verify updated value

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
  | company_id   | {COMPANY_ID} |
  | search_type  | <searchType> |
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

  # 5. SEARCH USING UPDATED VALUE

  And I prepare a request

  And I set the request headers:
    | accept              | application/json |
    | authenticationtoken | {AUTH_TOKEN}     |

  And I set the query parameters:
    | company_id   | {COMPANY_ID} |
    | search_type  | <searchType> |
    | search_query | {CAPTURED:updatedFieldValue} |

  When I send a "GET" request to "/user/company/users"

  Then the response status code should be 200

  And the response message should be "user accounts fetched successfully"

  And the response body should contain field "data.total_count" as "int" with value "1"

  And the response body should contain field "data.users[0].user_id" as "auto" with value "{CAPTURED:createdUserId}"

  And the response body should contain field "<responseField>" as "string" with value "{CAPTURED:updatedFieldValue}"


Examples:
  | searchType | searchValue                     | updateField | updatedValue                            | responseField            |
  | name       | {CAPTURED:createdFirstName}     | first_name  | MihirUpd{RANDOM_INT:10000:99999}        | data.users[0].first_name |
  | email      | {CAPTURED:createdUserEmail}     | email       | updated{RANDOM_INT:10000:99999}@yopmail.com | data.users[0].email  |
  | mobile     | {CAPTURED:createdUserMobile}    | mobile      | 73200{RANDOM_INT:10000:99999}        | data.users[0].mobile     |