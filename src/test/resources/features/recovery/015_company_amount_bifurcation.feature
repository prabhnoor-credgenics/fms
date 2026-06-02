@api @amount-bifurcation @recovery
Feature: Company Amount Bifurcation Variables API

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  # =====================================================================
  # GET /company/amount-bifurcation
  # =====================================================================

  @positive @smoke @chief-admin
  Scenario: Get amount bifurcation variables for configured company_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/amount_bifurcation_success_schema.json"
    And the response body should contain field "message"

  @positive @chief-admin
  Scenario: Get amount bifurcation variables with bifurcation_prefix true
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id         | {COMPANY_ID} |
      | bifurcation_prefix | true         |
    When I send a "GET" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/amount_bifurcation_success_schema.json"

  @positive @chief-admin
  Scenario: Get amount bifurcation variables with include_deleted true
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | include_deleted | true         |
    When I send a "GET" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/amount_bifurcation_success_schema.json"

  @positive @performance @chief-admin
  Scenario: Amount bifurcation GET response time should be within threshold
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @auth @creator
  Scenario: GET amount bifurcation should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @creator
  Scenario: GET amount bifurcation should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: GET amount bifurcation should fail when company_id is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    When I send a "GET" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  # =====================================================================
  # POST /company/amount-bifurcation
  # =====================================================================

  @positive @create @chief-admin
  Scenario: Add a variable to amount bifurcation
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "00000000-0000-0000-0000-000000000001"
      }
      """
    When I send a "POST" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/amount_bifurcation_write_success_schema.json"
    And the response body should contain field "message"

  @negative @create @chief-admin
  Scenario: POST amount bifurcation should fail when variable_id is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"
    And the response message should be "Please provide valid variable id"

  @negative @auth @create @creator
  Scenario: POST amount bifurcation should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variable_id": "00000000-0000-0000-0000-000000000001"
      }
      """
    When I send a "POST" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  # =====================================================================
  # PATCH /company/amount-bifurcation (reorder)
  # =====================================================================

  @positive @update @chief-admin
  Scenario: Reorder amount bifurcation variables via PATCH
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variables_order": ["00000000-0000-0000-0000-000000000001", "00000000-0000-0000-0000-000000000002"]
      }
      """
    When I send a "PATCH" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/amount_bifurcation_write_success_schema.json"

  @negative @update @chief-admin
  Scenario: PATCH amount bifurcation should fail when variables_order is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "PATCH" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"
    And the response message should be "Priority order is required."

  @negative @update @chief-admin
  Scenario: PATCH amount bifurcation should fail when variables_order is empty
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variables_order": []
      }
      """
    When I send a "PATCH" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @update @creator
  Scenario: PATCH amount bifurcation should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "variables_order": ["00000000-0000-0000-0000-000000000001"]
      }
      """
    When I send a "PATCH" request to "/recovery/company/amount-bifurcation"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  # =====================================================================
  # PATCH /company/amount-bifurcation/<variable_id>
  # =====================================================================

  @positive @update @chief-admin
  Scenario: Update a specific amount bifurcation variable properties via PATCH
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
      | Content-Type         | application/json                  |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000001 |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_active": true
      }
      """
    When I send a "PATCH" request to "/recovery/company/amount-bifurcation/{variable_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/amount_bifurcation_write_success_schema.json"

  @negative @auth @update @creator
  Scenario: PATCH amount bifurcation variable should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
      | Content-Type | application/json                  |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000001 |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_active": true
      }
      """
    When I send a "PATCH" request to "/recovery/company/amount-bifurcation/{variable_id}"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  # =====================================================================
  # DELETE /company/amount-bifurcation/<variable_id>
  # =====================================================================

  @positive @delete @chief-admin
  Scenario: Delete a specific amount bifurcation variable
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000001 |
    When I send a "DELETE" request to "/recovery/company/amount-bifurcation/{variable_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/amount_bifurcation_write_success_schema.json"

  @negative @delete @chief-admin
  Scenario: DELETE amount bifurcation variable should fail for non-existent variable_id
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "DELETE" request to "/recovery/company/amount-bifurcation/{variable_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"

  @negative @auth @delete @creator
  Scenario: DELETE amount bifurcation variable should fail when authentication token is missing
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | variable_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "DELETE" request to "/recovery/company/amount-bifurcation/{variable_id}"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_variables_error_schema.json"
