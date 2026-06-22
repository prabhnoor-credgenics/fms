@api @ai-rules-variables @recovery
Feature: AI Rules Variables

  @positive1
  Scenario: Verify AI rules variables request
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id                    | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | exclude_non_ai                | true                                 |
      | only_customer_level_variables | False                                |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 200
    And the response message should be "success"

    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "output[0].variable"
    And the response body should contain field "output[0].variable_type"
    And the response body should contain field "output[0].is_default"
    And the response body should contain field "output[0].variable_category"
    And the response body should contain field "output[0].type"
    And the response body should contain field "output[0].operators"
    And the response body should contain field "output[0].operators[0]"
    And the response body should contain field "message"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @negative @auth @creator
  Scenario: API should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "company_id: company_id is required"

  @negative2 @creator
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "one or more companies not found"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid company_id"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "company_id: company_id is required"

  @negative @creator @500
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "forbidden: invalid company id"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/ai-rules/variables"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid company_id"



  @positive
  Scenario: Verify variable values for key=recovery_status
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | recovery_status                      |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=calling_status
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | calling_status                       |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=global_status
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | global_status                        |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=settlement_status
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | settlement_status                    |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=legal_status
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | legal_status                         |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=fos_status
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | fos_status                           |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=fos_collections_status
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | fos_collections_status               |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=communication_status
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | communication_status                 |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=tags (remapped to tag_name internally)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | tags                                 |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=applicant_state
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | applicant_state                      |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=applicant_city
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | applicant_city                       |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values for key=applicant_language returns additional_mapping
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | applicant_language                   |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "additional_mapping"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values with explicit company_type=loan
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key          | recovery_status                      |
      | company_type | loan                                 |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @positive
  Scenario: Verify variable values with company_type=credit_line
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key          | recovery_status                      |
      | company_type | credit_line                          |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @negative @auth @creator
  Scenario: Variables values API should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | recovery_status                      |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @auth @creator
  Scenario: Variables values API should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | recovery_status                      |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"

  @negative @creator
  Scenario: Variables values API should fail when company_id is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | key | recovery_status |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "company_id: field is required"

  @negative @creator
  Scenario: Variables values API should fail when key is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "key: field is required"

  @negative @creator
  Scenario: Variables values API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
      | key        | recovery_status                      |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "one or more companies not found"

  @negative @creator
  Scenario: Variables values API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
      | key        | recovery_status    |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid company_id"

  @negative @creator
  Scenario: Variables values API should return empty output for invalid key
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key        | invalid_key_xyz                      |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_ai_rules_variables_values_success_schema.json"
    And the response body should contain field "output" with value "empty"

  @negative @creator @bug @500
  Scenario: Variables values API with should fail when invalid company_type
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | key          | recovery_status                      |
      | company_type | invalid_type                         |
    When I send a "GET" request to "/recovery/ai-rules/variables/values"
    Then the response status code should be 400
    
      
