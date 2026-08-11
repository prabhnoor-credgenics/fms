#@api @creator
Feature: Filter & Sort

    Scenario: Fetch the users for a company with valid authentication token
        And I authenticate as "creator" slot 0 and remember as "creator0"
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


  @positive @create @creator
  Scenario Outline: Create recovery variable with different variable types
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And scenario variable name is unique
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
    """
    {
      "company_id": "{COMPANY_ID}",
      "variable_name": "{VARIABLE_NAME}",
      "variable_type": "<variable_type>"
    }
    """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables create response should be valid

    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID}       |
      | variable_type              | <variable_type>    |
      | is_default_variable        | false              |
      | include_computed_variables | true               |
      | include_meta_data          | true               |
    When I send a "GET" request to "/recovery/variables"
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


  @positive @create @creator
  Scenario: Create recovery variable with different variable types - List
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And scenario variable name is unique
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body from file "test-data/UserVariableList_Variable_Creation1.json"
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables create response should be valid

    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | x-company-id        | {COMPANY_ID}     |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | variable_type              | list |
      | is_default_variable        | false|
      | include_computed_variables | true |
      | include_meta_data          | true |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain text "{VARIABLE_NAME}"



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
##
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
#      | {COMPANY_ID}    | bool            | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | amount          | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | percentage      | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | number          | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | mobile number   | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | email address   | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | link            | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | datetime        | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | list            | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    |                 | {COMPANY_ID}       | 400         |
#      |                 | text            | {COMPANY_ID}       | 400         |
#      | {COMPANY_ID}    | text            | invalid-company-id | 400         |
