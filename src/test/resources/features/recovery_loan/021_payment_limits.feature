@api @payment-limits @recovery
Feature: Payment Limits API

  @positive @smoke @creator
  Scenario: POST payment limits for loan IDs with cash payment method
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      { "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "payment_method": "cash",
        "loan_ids": ["Loan047122", "Loan652491"]
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
    Then the response status code should be 200
    And the response message should be "restriction details fetched"
    And the response should match json schema "schemas/recovery/success/payment_limits_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "success"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST payment limits for a single loan ID
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the request body:
      """
      { "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "payment_method": "cash",
        "loan_ids": [ "Loan047122"]
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
    Then the response status code should be 200
    And the response message should be "restriction details fetched"
    And the response should match json schema "schemas/recovery/success/payment_limits_success_schema.json"
    And the response body should contain field "data"
    And the response body should contain field "success"
    And the response body should contain field "message"

  @positive @performance @creator
  Scenario: Payment limits response time should be within threshold
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the request body:
      """
      {   "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "payment_method": "cash",
        "loan_ids": ["Loan652491"]
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds

  @negative @creator
  Scenario: POST payment limits should fail with an empty body
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
    Then the response status code should be one of "400"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "invalid company id"

  @negative @creator
  Scenario: POST payment limits should fail when payment_method is missing
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the request body:
      """
      {"company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "loan_ids": ["Loan652491"]
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Provide payment_method"

  @negative @creator
  Scenario: POST payment limits should fail when no loan IDs are provided
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the request body:
      """
      { "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "payment_method": "cash",
        "loan_ids": []
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Provide loan id"

  @negative @creator
  Scenario: POST payment limits should fail for an invalid payment_method
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the request body:
      """
      { "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "payment_method": "bitcoin",
        "loan_ids": ["Loan652491"]
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid payment method provided"

  @negative @auth @creator @bug
  Scenario: POST payment limits should fail when authentication token is missing
    Given I prepare a request
    And I set the request headers:
      | accept       | application/json, text/plain, */*    |
      | Content-Type | application/json                     |
    And I set the request body:
      """
      {"company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "payment_method": "cash",
        "loan_ids": ["Loan652491"]
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
   Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Session expired, please login again"

  @negative @auth @creator @bug
  Scenario: POST payment limits should fail with an invalid authentication token
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | invalid_token_12345                  |
      | Content-Type        | application/json                     |
    And I set the request body:
      """
      {"company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "payment_method": "cash",
        "loan_ids": ["Loan652491"]
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
     Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Session expired, please login again"

  @negative @auth @creator @bug
  Scenario: POST payment limits should fail with an invalid loan_id
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                     |
    And I set the request body:
      """
      {"company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "payment_method": "cash",
        "loan_ids": ["Loan65249177888"]
      }
      """
    When I send a "POST" request to "/recovery/loan/payment-limits"
    Then the response status code should be one of "401,403"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
  
