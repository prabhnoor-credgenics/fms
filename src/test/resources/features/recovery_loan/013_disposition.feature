@api @disposition @recovery
Feature: Disposition API

  @positive
  Scenario: Verify get disposition request
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "invalid company id"

  @negative @creator
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "one or more companies not found"

  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "Invalid company_id"

  @positive
  Scenario: Verify get disposition request with product_type and service_type
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "product_type" as "auto" to "car-accessories_1"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}      |
      | service_type | recovery          |
      | product_type | car-accessories_1 |
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | service_type | invalid-service-type                 |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "Invalid service_type provided"

  @negative @creator
  Scenario: API should fail when product_type is invalid
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | product_type | invalid-product_type                 |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_get_disposition_success_schema.json"
    And the response body should contain field "data" as "auto" with value "empty"

  @negative @creator4
  Scenario: API should fail when service_type is invalid and product_type is invalid
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | service_type | invalid-service-type                 |
      | product_type | invalid-product_type                 |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "Invalid service_type provided"
