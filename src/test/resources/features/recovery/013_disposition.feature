Feature: Disposition API

  @positive
  Scenario: Verify get disposition request
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response message should be "Dispositions Fetched"
    And the response should match json schema "schemas/recovery/success/recovery_get_disposition_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "data[0].id"
    And the response body should contain field "data[0].company_id"
    And the response body should contain field "data[0].name"
    And the response body should contain field "data[0].key"
    And the response body should contain field "data[0].sub_dispositions"
    And the response body should contain field "data[0].active"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be one of "400"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "invalid company id"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be one of "401"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "forbidden: invalid company id"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be one of "401"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Session expired, please login again"

  @positive
  Scenario: Verify get disposition request with product_type and service_type
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | service_type | recovery                             |
      | product_type | car-accessories_1                    |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response message should be "Dispositions Fetched"
    And the response should match json schema "schemas/recovery/success/recovery_get_disposition_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "data[0].company_id"
    And the response body should contain field "data[0].product_type"
    And the response body should contain field "data[0].is_recovery_enabled"

  @positive
  Scenario: Verify get disposition request with valid product_type and no service_type
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | product_type | car-accessories_1                    |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response message should be "Dispositions Fetched"
    And the response should match json schema "schemas/recovery/success/recovery_get_disposition_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "data[0].company_id"
    And the response body should contain field "data[0].product_type"

  @positive
  Scenario: Verify get disposition request with no product_type and valid service_type
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | service_type | recovery                             |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response message should be "Dispositions Fetched"
    And the response should match json schema "schemas/recovery/success/recovery_get_disposition_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "data[0].company_id"
    And the response body should contain field "data[0].is_recovery_enabled"

  @negative @creator
  Scenario: API should fail when service_type is invalid
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | service_type | invalid-service-type                 |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be one of "400"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid service_type provided"

  @negative @creator
  Scenario: API should fail when product_type is invalid
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | product_type | invalid-product_type                 |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be one of "200"
    And the response should match json schema "schemas/recovery/success/recovery_get_disposition_success_schema.json"
    And the response body should contain field "data" with value "empty"

  @negative @creator4
  Scenario: API should fail when service_type is invalid and product_type is invalid
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | service_type | invalid-service-type                 |
      | product_type | invalid-product_type                 |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be one of "400"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid service_type provided"
