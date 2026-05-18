@api @recovery-company
Feature: Recovery Company API validation
  As an API automation engineer
  I want to validate create and get company endpoint behaviour
  So that response structure and access checks are stable

  Background:
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |

  @positive
  Scenario: Get company details with bifurcation prefix true
    Given I set the query parameters:
      | company_id          | 43eb0d02-ef8f-48cb-b0e0-c1268926a0a3 |
      | bifurcation_prefix  | true                                 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery_company_success_schema.json"
    And the response body should contain field "company_details.custom_dpd_bucket"
    And the response body should contain field "company_details.default_portfolio_month"












  @positive
  Scenario: Get company details with bifurcation prefix true
    Given I set the query parameters:
      | company_id          | 43eb0d02-ef8f-48cb-b0e0-c1268926a0a3 |
      | bifurcation_prefix  | true                                 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery_company_success_schema.json"
    And the response body should contain field "company_details.custom_dpd_bucket"
    And the response body should contain field "company_details.default_portfolio_month"

  @positive
  Scenario: Get company details with bifurcation prefix false
    Given I set the query parameters:
      | company_id          | 43eb0d02-ef8f-48cb-b0e0-c1268926a0a3 |
      | bifurcation_prefix  | false                                |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery_company_success_schema.json"

  @negative @auth
  Scenario: API should fail with invalid authentication token
    Given I set the query parameters:
      | company_id          | 43eb0d02-ef8f-48cb-b0e0-c1268926a0a3 |
      | bifurcation_prefix  | true                                 |
    And I set the request headers:
      | authenticationtoken  | invalid_token_12345 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "400,401,403"
    And the response should match json schema "schemas/recovery_company_error_schema.json"

  @negative
  Scenario: API should fail when company_id is missing
    Given I set the query parameters:
      | bifurcation_prefix  | true |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "400,401,403,422"
    And the response should match json schema "schemas/recovery_company_error_schema.json"

  @negative
  Scenario: API should fail when company_id is invalid UUID format
    Given I set the query parameters:
      | company_id          | invalid-company-id |
      | bifurcation_prefix  | true               |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/recovery_company_error_schema.json"

  @negative
  Scenario: API should fail when company_id does not exist
    Given I set the query parameters:
      | company_id          | 00000000-0000-0000-0000-000000000000 |
      | bifurcation_prefix  | true                                 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/recovery_company_error_schema.json"

  @negative
  Scenario Outline: API should handle invalid bifurcation_prefix values
    Given I set the query parameters:
      | company_id          | 43eb0d02-ef8f-48cb-b0e0-c1268926a0a3 |
      | bifurcation_prefix  | <bifurcation_prefix>                 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "200,400,401,403,422"
    And the response body should not be empty

    Examples:
      | bifurcation_prefix |
      | yes                |
      | 1                  |
      | null               |
      |                    |
