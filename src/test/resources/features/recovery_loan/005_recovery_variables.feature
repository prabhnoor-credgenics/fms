@api @recovery-variables @recovery
Feature: Recovery Variables API

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  @positive @smoke @creator
  Scenario: Get recovery variables for configured company_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response content type should be "text/html; charset=utf-8"
    And the response should match json schema "schemas/recovery/success/recovery_variables_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"
   # And recovery variables response mandatory fields should be valid
   # And recovery variables should match requested company
   # And recovery variables computed variables should be included
  #  And recovery variables meta data should be included
  #  And the response time should be within configured limit

  @positive @meta-data @creator
  Scenario: Get recovery variables with include_meta_data false
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | false        |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response content type should be "text/html; charset=utf-8"
    And the response should match json schema "schemas/recovery/success/recovery_variables_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"
    And recovery variables response mandatory fields should be valid
    And recovery variables should match requested company
    And recovery variables meta data should be excluded

  @positive @meta-data @creator
  Scenario: Response differs when include_meta_data changes from true to false
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    And recovery variables meta data should be included
    And recovery variables response is saved for meta data comparison
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | false        |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And recovery variables meta data should be excluded
    And recovery variables response should differ from saved when meta data is disabled

  @positive @minimal-payload @creator
  Scenario: Get recovery variables with computed variables and meta data disabled
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | false        |
      | include_meta_data            | false        |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response content type should be "text/html; charset=utf-8"
    And the response should match json schema "schemas/recovery/success/recovery_variables_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"
    And recovery variables response mandatory fields should be valid
    And recovery variables should match requested company
    And recovery variables computed variables should be excluded
    And recovery variables meta data should be excluded

  @positive @minimal-payload @creator
  Scenario: Response differs when both include_computed_variables and include_meta_data are disabled
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    And recovery variables computed variables should be included
    And recovery variables meta data should be included
    And recovery variables response is saved for full payload comparison
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | false        |
      | include_meta_data            | false        |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And recovery variables computed variables should be excluded
    And recovery variables meta data should be excluded
    And recovery variables response should differ from saved when computed variables and meta data are disabled

  @positive @computed-variables @creator
  Scenario: Get recovery variables with include_computed_variables false
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | false        |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response content type should be "text/html; charset=utf-8"
    And the response should match json schema "schemas/recovery/success/recovery_variables_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"
    And recovery variables response mandatory fields should be valid
    And recovery variables should match requested company
    And recovery variables computed variables should be excluded

  @positive @computed-variables @creator
  Scenario: Response differs when include_computed_variables changes from true to false
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    And recovery variables computed variables should be included
    And recovery variables response is saved for computed variables comparison
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | false        |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And recovery variables computed variables should be excluded
    And recovery variables response should differ from saved when computed variables are disabled

  @positive @performance @creator
  Scenario: Recovery variables API response time should be within threshold
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @auth @creator
  Scenario: API should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | include_computed_variables   | true |
      | include_meta_data            | true |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | invalid-company-id |
      | include_computed_variables   | true               |
      | include_meta_data            | true               |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | 00000000-0000-0000-0000-000000000000 |
      | include_computed_variables   | true                                 |
      | include_meta_data            | true                                 |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"





  @positive @smoke @create @creator
  Scenario: Create a new text variable with minimum required fields
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autotest{RANDOM_STRING:8}",
        "variable_type": "text"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response content type should be "text/html; charset=utf-8"
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And the response body should contain field "message_template"
    And the response body should contain field "message"
    And recovery variables create response should be valid

  @positive @create @creator
  Scenario: Create an amount variable with optional fields
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autoamt{RANDOM_STRING:8}",
        "variable_type": "amount",
        "description": "Automation test amount variable",
        "is_mandatory": false,
        "allow_negative": false
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables create response should be valid

  @positive @create @creator
  Scenario: Create a text variable with dropdown values
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autodrop{RANDOM_STRING:6}",
        "variable_type": "text",
        "is_dropdown": true,
        "dropdown_values": ["opt_one", "opt_two", "opt_three"]
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables create response should be valid

  @positive @create @creator
  Scenario: Create a number variable with is_mandatory true
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autonumber{RANDOM_STRING:6}",
        "variable_type": "number",
        "is_mandatory": true,
        "description": "Automation test mandatory number variable"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables create response should be valid
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "autonumber{RANDOM_STRING:6}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "is_mandatory": false
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables update response should be valid

  @negative @create @creator
  Scenario: POST should fail when variable_name is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_type": "text"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @create @creator
  Scenario: POST should fail when variable_type is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autotest{RANDOM_STRING:8}"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @create @creator
  Scenario: POST should fail when variable_name starts with a digit
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "1invalidname",
        "variable_type": "text"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @create @creator
  Scenario: POST should fail when variable_name contains spaces
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "invalid name with spaces",
        "variable_type": "text"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @create @creator
  Scenario: POST should fail when variable_type is invalid
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autotest{RANDOM_STRING:8}",
        "variable_type": "invalid_type"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @create @creator
  Scenario: POST should fail when is_dropdown is true but dropdown_values is empty
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autotest{RANDOM_STRING:8}",
        "variable_type": "text",
        "is_dropdown": true,
        "dropdown_values": []
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @create @creator
  Scenario: POST should fail when is_derivable is true but calculation_formula is absent
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autotest{RANDOM_STRING:8}",
        "variable_type": "number",
        "is_derivable": true
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @create @creator
  Scenario: POST should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autotest{RANDOM_STRING:8}",
        "variable_type": "text"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @create @creator
  Scenario: POST should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autotest{RANDOM_STRING:8}",
        "variable_type": "text"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"



  @positive @update @creator
  Scenario: Update variable description via PATCH
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autopatch{RANDOM_STRING:8}",
        "variable_type": "text",
        "description": "initial description"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "autopatch{RANDOM_STRING:8}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "description": "updated description via automation"
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And the response body should contain field "message"
    And recovery variables update response should be valid

  @positive @update @creator
  Scenario: Update variable is_mandatory flag via PATCH
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autopatch{RANDOM_STRING:8}",
        "variable_type": "number",
        "is_mandatory": false
      }
      """
    When I send a "POST" request to "/recovery/variables"
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "autopatch{RANDOM_STRING:8}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "is_mandatory": true
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables update response should be valid
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "is_mandatory": false
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables update response should be valid

  @positive @update @creator
  Scenario: Disable dropdown on variable via PATCH clears dropdown values
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autopatch{RANDOM_STRING:8}",
        "variable_type": "text",
        "is_dropdown": true,
        "dropdown_values": ["val_a", "val_b"]
      }
      """
    When I send a "POST" request to "/recovery/variables"
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "autopatch{RANDOM_STRING:8}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "is_dropdown": false
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_variables_write_success_schema.json"
    And recovery variables update response should be valid

  @negative @update @creator
  Scenario: PATCH should fail when variable_id is missing from body
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "description": "update without variable_id"
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"
    And the response message should be "Data validation failed"

  @negative @update @creator
  Scenario: PATCH should fail when trying to set is_derivable to true
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autopatch{RANDOM_STRING:8}",
        "variable_type": "number",
        "is_mandatory": false
      }
      """
    When I send a "POST" request to "/recovery/variables"
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "autopatch{RANDOM_STRING:8}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "is_derivable": true
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @update @creator
  Scenario: PATCH should fail when trying to set calculation_formula
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autopatch{RANDOM_STRING:8}",
        "variable_type": "number"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "autopatch{RANDOM_STRING:8}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "calculation_formula": "dpd + 1"
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @update @creator
  Scenario: PATCH should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "some-variable-id",
        "description": "update without auth"
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @update @creator
  Scenario: PATCH should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "some-variable-id",
        "description": "update with bad token"
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"



  @positive @delete @chief-admin
  Scenario: Delete a variable that was just created
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autodel{RANDOM_STRING:8}",
        "variable_type": "text"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "autodel{RANDOM_STRING:8}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | {VARIABLE_ID} |
    When I send a "DELETE" request to "/recovery/variables/{variable_id}"
    Then the response status code should be 200
    And recovery variables delete response should be valid

  @negative @delete @creator
  Scenario: DELETE should fail for a non-existent variable id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "DELETE" request to "/recovery/variables/{variable_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @delete @creator
  Scenario: DELETE should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "DELETE" request to "/recovery/variables/{variable_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"


  @positive @smoke @categorisation @creator
  Scenario: Get variable categorisation for configured company_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/variables/categorisation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/variables_categorisation_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @categorisation @creator
  Scenario: Get variable categorisation with transaction target
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | target     | transaction  |
    When I send a "GET" request to "/recovery/variables/categorisation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/variables_categorisation_success_schema.json"
    And the response body should contain field "output"

  @positive @categorisation @creator
  Scenario: Get variable categorisation with include_computed_variables true
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
    When I send a "GET" request to "/recovery/variables/categorisation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/variables_categorisation_success_schema.json"

  @positive @categorisation @creator
  Scenario: Get variable categorisation with include_all_variables and include_derivable_variables
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                  | {COMPANY_ID} |
      | include_all_variables       | true         |
      | include_derivable_variables | true         |
    When I send a "GET" request to "/recovery/variables/categorisation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/variables_categorisation_success_schema.json"

  @negative @auth @categorisation @creator
  Scenario: Variable categorisation should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/variables/categorisation"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @categorisation @creator
  Scenario: Variable categorisation should fail when company_id is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/variables/categorisation"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @categorisation @creator
  Scenario: Variable categorisation should fail when company_id does not exist
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/variables/categorisation"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"



  @negative @server-error @expected-200 @creator
  Scenario: POST should handle an invalid calculation_formula for a derivable variable
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autoerr{RANDOM_STRING:8}",
        "variable_type": "number",
        "is_derivable": true,
        "calculation_formula": "((dpd + * / "
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @server-error @expected-200 @creator
  Scenario: POST should handle is_dropdown sent as a string instead of a boolean
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autoerr{RANDOM_STRING:8}",
        "variable_type": "text",
        "is_dropdown": "yes",
        "dropdown_values": ["a", "b"]
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should not be empty

  @negative @server-error @expected-200 @creator
  Scenario: PATCH should handle dropdown_values sent as an object instead of an array
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_name": "autoerr{RANDOM_STRING:8}",
        "variable_type": "text",
        "is_dropdown": true,
        "dropdown_values": ["x", "y"]
      }
      """
    When I send a "POST" request to "/recovery/variables"
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | false        |
      | include_meta_data          | false        |
    When I send a "GET" request to "/recovery/variables"
    And I find and store variable id for name "autoerr{RANDOM_STRING:8}" from variables response
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "{VARIABLE_ID}",
        "dropdown_values": {"unexpected": "object"}
      }
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @server-error @expected-200 @creator
  Scenario: GET should handle include_computed_variables sent as an array parameter
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_computed_variables | false        |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should not be empty

  @negative @server-error @expected-200 @creator
  Scenario: GET categorisation should handle a malformed boolean for include_all_variables
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id            | {COMPANY_ID}        |
      | include_all_variables | {malformed-boolean} |
    When I send a "GET" request to "/recovery/variables/categorisation"
    Then the response status code should be 200
    And the response body should not be empty
