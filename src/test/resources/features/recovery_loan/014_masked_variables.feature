@api @masked-variables @recovery
Feature: Masked Variables API

  Background:
    Given scenario company id is from configuration
    And I prepare a request


  @positive @smoke @creator
  Scenario: Get masked variables for configured company_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/masked-variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/masked_variables_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: Get masked variables with return_variable_names true
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | return_variable_names | true         |
    When I send a "GET" request to "/recovery/masked-variables"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/masked_variables_with_names_success_schema.json"
    And the response body should contain field "output"

  @positive @performance @creator
  Scenario: Masked variables GET response time should be within threshold
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/masked-variables"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @auth @creator
  Scenario: GET masked variables should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @creator
  Scenario: GET masked variables should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: GET masked variables should fail when company_id is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"



  @positive @create @creator
  Scenario: Add masked variable for a permission group
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": ["pg-automation-test"]
      }
      """
    When I send a "POST" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/success/masked_variables_write_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "status"

  @positive @create @creator
  Scenario: Add masked variable with complete_masking_enabled true
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": ["pg-automation-test"],
        "complete_masking_enabled": true
      }
      """
    When I send a "POST" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/success/masked_variables_write_success_schema.json"

  @negative @create @creator
  Scenario: POST masked variables should fail when permission_group_id is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @create @creator
  Scenario: POST masked variables should fail when permission_group_id is empty list
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": []
      }
      """
    When I send a "POST" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @create @creator
  Scenario: POST masked variables should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": ["pg-automation-test"]
      }
      """
    When I send a "POST" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"



  @positive @delete @creator
  Scenario: Delete masked variables by permission_group_id in request body
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": ["pg-automation-test"]
      }
      """
    When I send a "DELETE" request to "/recovery/masked-variables"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/success/masked_variables_write_success_schema.json"

  @negative @delete @creator
  Scenario: DELETE masked variables should fail when permission_group_id is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "DELETE" request to "/recovery/masked-variables"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @delete @creator
  Scenario: DELETE masked variables should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": ["pg-automation-test"]
      }
      """
    When I send a "DELETE" request to "/recovery/masked-variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"



  @positive @update @creator
  Scenario: Update masked variable complete_masking_enabled via PATCH
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000001 |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": ["pg-automation-test"],
        "complete_masking_enabled": false
      }
      """
    When I send a "PATCH" request to "/recovery/masked-variables/{variable_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/masked_variables_write_success_schema.json"

  @negative @update @creator
  Scenario: PATCH masked variable should fail when permission_group_id is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000001 |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "complete_masking_enabled": false
      }
      """
    When I send a "PATCH" request to "/recovery/masked-variables/{variable_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @update @creator
  Scenario: PATCH masked variable should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | Content-Type | application/json                  |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000001 |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": ["pg-automation-test"],
        "complete_masking_enabled": false
      }
      """
    When I send a "PATCH" request to "/recovery/masked-variables/{variable_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"



  @positive @delete @chief-admin
  Scenario: Delete a single masked variable by variable_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000001 |
    When I send a "DELETE" request to "/recovery/masked-variables/{variable_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/masked_variables_write_success_schema.json"

  @negative @delete @chief-admin
  Scenario: DELETE single masked variable should fail for non-existent variable_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "DELETE" request to "/recovery/masked-variables/{variable_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @delete @creator
  Scenario: DELETE single masked variable should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "DELETE" request to "/recovery/masked-variables/{variable_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"



  @positive @delete @deprecated @chief-admin
  Scenario: Delete masked variables by permission_group path param (deprecated endpoint)
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | permission_group_id | pg-automation-test |
    When I send a "DELETE" request to "/recovery/masked-variables/permission-group/{permission_group_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/masked_variables_write_success_schema.json"

  @negative @auth @delete @creator
  Scenario: DELETE permission-group masked variables should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | permission_group_id | pg-automation-test |
    When I send a "DELETE" request to "/recovery/masked-variables/permission-group/{permission_group_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"
