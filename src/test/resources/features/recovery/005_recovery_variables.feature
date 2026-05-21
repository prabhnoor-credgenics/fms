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
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response should match json schema "schemas/recovery_variables_success_schema.json"
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
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | false        |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response should match json schema "schemas/recovery_variables_success_schema.json"
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
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And recovery variables meta data should be included
    And recovery variables response is saved for meta data comparison
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
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
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | false        |
      | include_meta_data            | false        |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response should match json schema "schemas/recovery_variables_success_schema.json"
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
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And recovery variables computed variables should be included
    And recovery variables meta data should be included
    And recovery variables response is saved for full payload comparison
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
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
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | false        |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response should match json schema "schemas/recovery_variables_success_schema.json"
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
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And recovery variables computed variables should be included
    And recovery variables response is saved for computed variables comparison
    And I prepare a request
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
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
      | x-company-id         | {COMPANY_ID}                      |
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
      | x-company-id | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be one of "401,403"
    And the response should match json schema "schemas/recovery_variables_error_schema.json"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be one of "401,403"
    And the response should match json schema "schemas/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | {COMPANY_ID}                      |
    And I set the query parameters:
      | include_computed_variables   | true |
      | include_meta_data            | true |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be one of "400,401,403,422"
    And the response should match json schema "schemas/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | invalid-company-id                |
    And I set the query parameters:
      | company_id                   | invalid-company-id |
      | include_computed_variables   | true               |
      | include_meta_data            | true               |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/recovery_variables_error_schema.json"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | x-company-id         | 00000000-0000-0000-0000-000000000000 |
    And I set the query parameters:
      | company_id                   | 00000000-0000-0000-0000-000000000000 |
      | include_computed_variables   | true                                 |
      | include_meta_data            | true                                 |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/recovery_variables_error_schema.json"

  @negative @auth @creator
  Scenario: API should fail when x-company-id header is missing
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                   | {COMPANY_ID} |
      | include_computed_variables   | true         |
      | include_meta_data            | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be one of "400,401,403,422"
    And the response should match json schema "schemas/recovery_variables_error_schema.json"
