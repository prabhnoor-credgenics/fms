@api @emi-schedule @recovery
Feature: EMI Schedule API

  @positive1 @create @creator 
  Scenario: POST upserts an EMI schedule entry
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | Loan806595 |
    And I set the request body:
      """
  {
    "date__c": "2024-12-01",
  "net_payment__c": 10000,
  "mode_of_payment__c": "Online",
  "payment_received_date__c": "2024-11-15",
  "clearance__c": true,
  "company_id":"3e561a13-3be3-4672-85b0-e1c49a35d8fb",
  "recovery_method":"Communication"
}

      """
    When I send a "POST" request to "/recovery/loan/emi-schedule/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/emi_schedule_write_success_schema.json"
    And the response body should contain field "message"
    And the response body should contain field "success"

  @positive @create @creator
  Scenario: POST upserts an EMI schedule entry with minimal required fields
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | Loan806595 |
    And I set the request body:
      """
      {
        "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "date__c": "2026-06-15"
      }
      """
    When I send a "POST" request to "/recovery/loan/emi-schedule/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/emi_schedule_write_success_schema.json"

  @negative @create @creator @bug
  Scenario: POST EMI schedule should fail with an empty body
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | Loan806595 |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/loan/emi-schedule/{loan_id}"
    Then the response status code should be one of "400,422"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"

  @negative @create @creator
  Scenario: POST EMI schedule should fail when required field date__c is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | Loan806595 |
    And I set the request body:
      """
      {
        "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb"
      }
      """
    When I send a "POST" request to "/recovery/loan/emi-schedule/{loan_id}"
    Then the response status code should be one of "400"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid request data"

  @negative @create @creator 
  Scenario: POST EMI schedule should fail when required field company_id is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
     
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | vhgvjhbjhb |
    And I set the request body:
      """
      {
        "date__c": "2026-06-01"
      }
      """
    When I send a "POST" request to "/recovery/loan/emi-schedule/{loan_id}"
    Then the response status code should be one of "400,422"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"

  @negative @auth @create @creator @bug
  Scenario: POST EMI schedule should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept       | application/json, text/plain, */*    |
      | Content-Type | application/json                     |
    And I set the path parameters:
      | loan_id | Loan806595 |
    And I set the request body:
      """
      {
        "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "date__c": "2026-06-01",
        "clearance__c": true,
        "net_payment__c": 1500.0,
        "payment_received_date__c": "2026-06-01"
      }
      """
    When I send a "POST" request to "/recovery/loan/emi-schedule/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
      And the response body should contain field "message" with value "invalid authentication token"
 
  @negative @create @creator 
  Scenario: POST EMI schedule should fail for an invalid loan_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | undefined |
    And I set the request body:
      """
      {
        "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb",
        "date__c": "2026-06-01"
      }
      """
    When I send a "POST" request to "/recovery/loan/emi-schedule/{loan_id}"
    Then the response status code should be one of "400,401,403,404"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
