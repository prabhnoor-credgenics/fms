#@api @creator
Feature: Filter & Sort

#    Scenario: Fetch the users for a company with valid authentication token
#        And I authenticate as "creator" slot 0 and remember as "creator0"
#        And I prepare a request
#        And I set the request headers:
#        | accept              | application/json |
#        | authenticationtoken | {AUTH_TOKEN} |
#        | x-company-id        | {COMPANY_ID} |
#        And I set the query parameters:
#        | company_id   | {COMPANY_ID} |
#        | page_number  | 1 |
#        | search_type  | name |
#        When I send a "GET" request to "/user/company/users"
#        Then the response status code should be 200


  @positive @create @creator
  Scenario Outline: Create recovery variable and add it to created permission group

  # ============================================================
  # STEP 1: Authenticate
  # ============================================================

    Given I authenticate as "creator" slot 0 and remember as "creator0"


  # ============================================================
  # STEP 2: Create Permission Group
  # ============================================================

    And I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | content-type        | application/json |
      | x-company-id        | {COMPANY_ID}     |
      | role                | admin            |

    And I set the query parameters:
      | company_id | {COMPANY_ID} |

    And I set the request body from file "test-data/UserVariable_permission_group_FilterAndSort.json"

    When I send a "POST" request to "/user/profiles"

    Then the response status code should be 201

    And I store response field "data.profile_id" as "permission_id"


  # ============================================================
  # STEP 3: Create Recovery Variable
  # ============================================================

    And scenario variable name is unique
    And scenario variable type is "<variable_type>"


    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |

    And I set the request body from file "test-data/UserVariable_CreateRecoveryVariable.json"

    And I update JSON field "variable_name" as "auto" to "{VARIABLE_NAME}"

    When I send a "POST" request to "/recovery/variables"

    Then the response status code should be 201

    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"

    And recovery variables create response should be valid


  # ============================================================
  # STEP 4: Validate Created Recovery Variable
  # ============================================================

    And I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |

    And I set the query parameters:
      | company_id                 | {COMPANY_ID}    |
      | variable_type              | <variable_type> |
      | is_default_variable        | false           |
      | include_computed_variables | true            |
      | include_meta_data          | true            |

    When I send a "GET" request to "/recovery/variables"

    Then the response status code should be 200

    And the response body should contain text "{VARIABLE_NAME}"

    And I store response field "output[1].variable_id" as variable id

  # ============================================================
  # STEP 5: Add Created Variable to Created Permission Group
  # ============================================================

    And I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |
      | Content-Type        | application/json |

    And I set the query parameters:
      | company_id    | {COMPANY_ID}            |
      | permission_id | {CAPTURED:permission_id} |

    And I set the request body from file "test-data/UserVariable_Mappingto_Portfolio_Customization.json"

    When I send a "PUT" request to "/portfolio-v2/v1/variable-collection"

    Then the response status code should be 200


  # ============================================================
  # STEP 6: Validate Variable Collection
  # ============================================================

    And I prepare a request

    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |

    And I set the query parameters:
      | company_id    | {COMPANY_ID}            |
      | permission_id | {CAPTURED:permission_id} |

    When I send a "GET" request to "/portfolio-v2/v1/variable-collection"

    Then the response status code should be 200

    And the response body should contain text "{VARIABLE_NAME}"


    Examples:
      | variable_type |
      | text          |
      | number        |
      | amount        |
      | bool          |
      | email address |
      | pincode       |
      | mobile number |
      | link          |
      | datetime      |


#  @positive @create @creator
#  Scenario: Create recovery variable with different variable types - List
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And scenario variable name is unique
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#    And I set the request body from file "test-data/UserVariableList_Variable_Creation1.json"
#    When I send a "POST" request to "/recovery/variables"
#    Then the response status code should be 201
#    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
#    And recovery variables create response should be valid
#
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#      | variable_type              | list |
#      | is_default_variable        | false|
#      | include_computed_variables | true |
#      | include_meta_data          | true |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 200
#    And the response body should contain text "{VARIABLE_NAME}"
#
#
#  @positive
#  Scenario: Fetch variable collection with valid company and permission - Portfolio Customization
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id   | {COMPANY_ID}     |
#      | permission_id | s247pfyl7gdcetlu |
#    When I send a "GET" request to "/portfolio-v2/v1/variable-collection"
#    Then the response status code should be 200
#
#
#  @negative
#  Scenario Outline: Fetch variable collection with invalid query parameters - Portfolio Customization
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id    | <company_id>    |
#      | permission_id | <permission_id> |
#    When I send a "GET" request to "/portfolio-v2/v1/variable-collection"
#    Then the response status code should be <status_code>
#
#    Examples:
#      | company_id    | permission_id    | status_code |
#      |               | s247pfyl7gdcetlu | 400         |
#      | {COMPANY_ID}  |                  | 400         |
#      | invalid       | s247pfyl7gdcetlu | 400         |
#      | {COMPANY_ID}  | invalid          | 400         |
#
#
# @positive
#  Scenario Outline: Fetch recovery variables with different filter combinations
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#      | variable_type              | text         |
#      | is_default_variable        | <is_default_variable> |
#      | include_computed_variables | <include_computed_variables> |
#      | include_meta_data          | <include_meta_data> |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 200
#
#    Examples:
#      | is_default_variable | include_computed_variables | include_meta_data |
#      | false               | true                       | true              |
#      | false               | false                      | true              |
#      | false               | true                       | false             |
#      | true                | true                       | true              |
#
#
## @positive
#  Scenario: Fetch recovery variables without optional query parameters
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id    | {COMPANY_ID} |
#      | variable_type | text         |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 200
#
#
## @negative
#  Scenario: Fetch recovery variables with authentication issues
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | invalid-token   |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#      | variable_type              | text         |
#      | include_computed_variables | true         |
#      | include_meta_data          | true         |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 400
#
#
## @negative
#  Scenario: Fetch recovery variables without company_id
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | variable_type              | text |
#      | include_computed_variables | true |
#      | include_meta_data          | true |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 400
#
#
## @negative
#  Scenario Outline: Fetch recovery variables with invalid company information
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | <x_company_id>   |
#    And I set the query parameters:
#      | company_id                 | <company_id> |
#      | variable_type              | text         |
#      | include_computed_variables | true         |
#      | include_meta_data          | true         |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be <status_code>
#
#    Examples:
#      | company_id         | x_company_id        | status_code |
#      | invalid-company-id | invalid-company-id  | 400         |
#      | another-company-id | {COMPANY_ID}        | 400         |
#      | {COMPANY_ID}       | invalid-company-id  | 200         |
#
#
## @negative
#  Scenario: Fetch recovery variables with empty company_id
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id                 | |
#      | variable_type              | text |
#      | include_computed_variables | true |
#      | include_meta_data          | true |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 400
#
#
## @negative
#  Scenario: Fetch recovery variables with empty variable_type
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#      | variable_type              | |
#      | include_computed_variables | true |
#      | include_meta_data          | true |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 200
#
#
## @negative
#  Scenario: Fetch recovery variables with invalid variable_type
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#      | variable_type              | invalid |
#      | include_computed_variables | true |
#      | include_meta_data          | true |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 200
#
#
## @negative
#  Scenario: Fetch recovery variables with invalid boolean parameter
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN} |
#      | x-company-id        | {COMPANY_ID} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#      | variable_type              | text |
#      | is_default_variable        | invalid |
#      | include_computed_variables | true |
#      | include_meta_data          | true |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 500
#
#
#  Scenario Outline: Validate recovery variables with invalid or boundary query parameters
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | <x_company_id>   |
#    And I set the query parameters:
#      | company_id                 | <company_id> |
#      | variable_type              | <variable_type> |
#      | include_computed_variables | true         |
#      | include_meta_data          | true         |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be <status_code>
#
#    Examples:
#      | company_id      | variable_type   | x_company_id       | status_code |
#      | {COMPANY_ID}    | text            | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | bool            | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | amount          | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | percentage      | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | number          | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | mobile number   | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | email address   | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | link            | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | datetime        | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    | list            | {COMPANY_ID}       | 200         |
#      | {COMPANY_ID}    |                 | {COMPANY_ID}       | 200         |
#      |                 | text            | {COMPANY_ID}       | 400         |
#
#
#  @negative @create @creator
#  Scenario: Create recovery variable with duplicate variable name
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And scenario variable name is unique
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#    And I set the request body from file "test-data/UserVariable_Duplicate_Variable_Payload.json"
#    When I send a "POST" request to "/recovery/variables"
#    Then the response status code should be 201
#
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json              |
#      | authenticationtoken | {AUTH_TOKEN}                 |
#      | x-company-id        | {COMPANY_ID}                 |
#      | Content-Type        | application/json              |
#    And I set the request body from file "test-data/UserVariable_Duplicate_Variable_Payload.json"
#    When I send a "POST" request to "/recovery/variables"
#    Then the response status code should be 400
#
#
#  @edgecase @positive
#  Scenario Outline: Fetch recovery variables with whitespace in variable type
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id    | {COMPANY_ID}     |
#      | variable_type | <variable_type>  |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be <status_code>
#
#    Examples:
#      | variable_type | status_code |
#      | " text"       | 200 |
#      | "text "       | 200 |
#      | " text "      | 200 |
#
#
#  @edgecase @positive
#  Scenario Outline: Fetch recovery variables with different variable type casing
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id    | {COMPANY_ID}    |
#      | variable_type | <variable_type> |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be <status_code>
#
#    Examples:
#      | variable_type | status_code |
#      | text          | 200 |
#      | TEXT          | 200 |
#      | Text          | 200 |
#      | tExT          | 200 |
#
#
#  @negative @create @creator
#  Scenario Outline: Create recovery variable with missing variable name for different variable types
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And scenario variable name is unique
#    And I set the request headers:
#      | accept              | application/json              |
#      | authenticationtoken | {AUTH_TOKEN}                  |
#      | Content-Type        | application/json              |
#    And I set the request body:
#      """
#        {
#          "company_id": "{COMPANY_ID}",
#          "variable_type": "<variable_type>"
#        }
#      """
#    When I send a "POST" request to "/recovery/variables"
#    Then the response status code should be 400
#
#    Examples:
#      | variable_type |
#      | text          |
#      | number        |
#      | amount        |
#      | bool          |
#      | email address |
#      | pincode       |
#      | mobile number |
#      | link          |
#      | datetime      |
#
#
#  @positive
#  Scenario Outline: Fetch recovery variables and validate response schema for different variable types
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID}     |
#      | variable_type              | <variable_type>  |
#      | is_default_variable        | false             |
#      | include_computed_variables | true              |
#      | include_meta_data          | true              |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 200
#    And the response should match json schema "schemas/FilterAndSort/FilterAndSort.json"
#
#    Examples:
#      | variable_type |
#      | text          |
#      | number        |
#      | amount        |
#      | bool          |
#      | email address |
#      | pincode       |
#      | mobile number |
#      | link          |
#      | datetime      |
#      | list          |
#      | percentage    |
#
#
#  @positive
#  Scenario Outline: Fetch recovery variables with multiple filter combinations
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID}             |
#      | variable_type              | <variable_type>           |
#      | is_default_variable        | <is_default_variable>     |
#      | is_allocation_variable     | <is_allocation_variable> |
#      | is_trackable               | <is_trackable>            |
#      | is_casing_enabled          | <is_casing_enabled>      |
#      | is_mandatory               | <is_mandatory>            |
#      | include_computed_variables | <include_computed_variables> |
#      | include_meta_data          | <include_meta_data>      |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 200
#
#    Examples:
#      | variable_type | is_default_variable | is_allocation_variable | is_trackable | is_casing_enabled | is_mandatory | include_computed_variables | include_meta_data |
#      | text          | false               | false                  | false        | false             | false        | true                        | true              |
#      | text          | false               | false                  | true         | false             | false        | true                        | true              |
#      | text          | false               | false                  | false        | true              | false        | true                        | true              |
#      | text          | false               | false                  | false        | false             | true         | true                        | true              |
#      | text          | false               | false                  | true         | true              | true         | true                        | true              |
#      | text          | false               | true                   | true         | true              | true         | true                        | true              |
#      | text          | true                | false                  | false        | false             | false        | true                        | true              |
#      | number        | false               | false                  | false        | false             | false        | true                        | true              |
#      | amount        | false               | false                  | false        | false             | false        | true                        | true              |
#      | bool          | false               | false                  | false        | false             | false        | true                        | true              |
#      | email address | false               | false                  | false        | false             | false        | true                        | true              |
#      | pincode       | false               | false                  | false        | false             | false        | true                        | true              |
#      | mobile number | false               | false                  | false        | false             | false        | true                        | true              |
#      | link          | false               | false                  | false        | false             | false        | true                        | true              |
#      | datetime      | false               | false                  | false        | false             | false        | true                        | true              |
#      | list          | false               | false                  | false        | false             | false        | true                        | true              |
#      | percentage    | false               | false                  | false        | false             | false        | true                        | true              |
#
#
#  @positive @filter
#  Scenario: Fetch recovery variables with multiple boolean filters
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#      | x-company-id        | {COMPANY_ID}     |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#      | variable_type              | text         |
#      | is_allocation_variable     | false        |
#      | is_trackable               | true         |
#      | is_casing_enabled          | true         |
#      | is_mandatory               | true         |
#      | include_computed_variables | true         |
#      | include_meta_data          | true         |
#    When I send a "GET" request to "/recovery/variables"
#    Then the response status code should be 200