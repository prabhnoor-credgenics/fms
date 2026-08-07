@api @loan-upload @loan-recovery @recovery @additional-variables
Feature: Loan Upload — additional (company-created) variable types

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @creator @additional-variable
  Scenario Outline: <tc> — Additional "<type>" variable (allocation=<alloc>) uploads and reads back
    Given scenario loan id is unique
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "{VARIABLE_NAME}",
        "variable_type": "<type>",
        "is_allocation_variable": <alloc>,
        "is_mandatory": false
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "{VARIABLE_NAME}" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,404"
    And the response body should contain text "<value>"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "{VARIABLE_NAME}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | {VARIABLE_ID} |
    When I send a "DELETE" request to "/recovery/variables/{variable_id}"
    Then the response status code should be one of "200,400"

    Examples:
      | tc         | type          | alloc | value                                 |
      | TC_LUU_044 | text          | false | AutoQAAddText44                       |
      | TC_LUU_045 | text          | true  | AutoQAAddText45                       |
      | TC_LUU_048 | number        | false | 987654001                             |
      | TC_LUU_049 | number        | true  | 987654002                             |
      | TC_LUU_050 | decimal       | false | 1234.51                               |
      | TC_LUU_051 | decimal       | true  | 1234.52                               |
      | TC_LUU_052 | amount        | false | 98765.11                              |
      | TC_LUU_053 | amount        | true  | 98765.22                              |
      | TC_LUU_054 | percentage    | false | 63.11                                 |
      | TC_LUU_055 | percentage    | true  | 63.22                                 |
      | TC_LUU_058 | email address | false | autoqa.addvar58@example.com           |
      | TC_LUU_059 | email address | true  | autoqa.addvar59@example.com           |
      | TC_LUU_060 | pincode       | false | 560101                                |
      | TC_LUU_061 | pincode       | true  | 560102                                |
      | TC_LUU_064 | link          | false | https://example.com/autoqa-addvar-64  |
      | TC_LUU_065 | link          | true  | https://example.com/autoqa-addvar-65  |
      | TC_LUU_066 | date          | false | 2025-03-11                            |
      | TC_LUU_067 | date          | true  | 2025-03-12                            |
      | TC_LUU_140 | text          | false | AutoQAAddText140                      |
      | TC_LUU_167 | number        | false | 987654167                             |
      | TC_LUU_169 | number        | true  | 987654169                             |
      | TC_LUU_185 | amount        | false | 98765.85                              |
      | TC_LUU_187 | amount        | true  | 98765.87                              |
      | TC_LUU_199 | email address | false | autoqa.addvar199@example.com          |
      | TC_LUU_205 | pincode       | false | 560205                                |
      | TC_LUU_209 | link          | false | https://example.com/autoqa-addvar-209 |
      | TC_LUU_220 | date          | false | 2025-03-20                            |


  @positive @creator @additional-variable
  Scenario Outline: <tc> — Additional "<type>" variable (allocation=<alloc>) uploads and reads back
    Given scenario loan id is unique
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "{VARIABLE_NAME}",
        "variable_type": "<type>",
        "is_allocation_variable": <alloc>,
        "is_mandatory": false
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "{VARIABLE_NAME}" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "{VARIABLE_NAME}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | {VARIABLE_ID} |
    When I send a "DELETE" request to "/recovery/variables/{variable_id}"
    Then the response status code should be one of "200,400"

    Examples:
      | tc         | type | alloc | value |
      | TC_LUU_046 | bool | false | true  |
      | TC_LUU_047 | bool | true  | true  |
      | TC_LUU_158 | bool | false | false |


  @positive @creator @additional-variable @mobile
  Scenario Outline: <tc> — Additional "mobile number" variable (allocation=<alloc>) uploads and reads back
    Given scenario loan id is unique
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "{VARIABLE_NAME}",
        "variable_type": "mobile number",
        "is_allocation_variable": <alloc>,
        "is_mandatory": false
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "{VARIABLE_NAME}" as "string" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,404"
    And the response body should contain text "<value>"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "{VARIABLE_NAME}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | {VARIABLE_ID} |
    When I send a "DELETE" request to "/recovery/variables/{variable_id}"
    Then the response status code should be one of "200,400"

    Examples:
      | tc         | alloc | value      |
      | TC_LUU_056 | false | 9876501101 |
      | TC_LUU_057 | true  | 9876501102 |
      | TC_LUU_193 | false | 9876501193 |