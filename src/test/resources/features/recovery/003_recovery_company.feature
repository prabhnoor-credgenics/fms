@api @recovery-company
Feature: Recovery Company API and Company Creation Flow



   @chief-admin @smoke @e2e
  Scenario: End-to-end company creation and validation
    Given company creation test data is prepared
    When I create company with validation step 1
    Then the response status code should be 201
    And the response body should contain field "message"
    And the response should match json schema "schemas/company_creation_step1_success_schema.json"
    Then company creation step 1 should be successful
    And company creation stored identifiers should be present
    When I create company with validation step 2
    Then the response status code should be 201
    And the response message should be "Permissions validated and saved."
    And the response should match json schema "schemas/company_creation_step2_success_schema.json"
    Then company creation step 2 should be successful
    When I create company with validation step 3
    Then the response status code should be 201
    And the response message should be "Admin details validated and saved."
    And the response should match json schema "schemas/company_creation_step3_success_schema.json"
    Then company creation step 3 should be successful
    When I create company with validation step 4
    Then the response status code should be 201
    And the response message should be "company created successfully"
    And the response should match json schema "schemas/company_creation_step4_success_schema.json"
    Then company creation step 4 should be successful



  @positive
  Scenario: Get company details with bifurcation prefix true
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | bifurcation_prefix  | true                                 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery_company_success_schema.json"
    And the response body should contain field "company_details.custom_dpd_bucket"
    And the response body should contain field "company_details.show_balance_claim_amount"

  @positive
  Scenario: Get company details with bifurcation prefix false
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | bifurcation_prefix  | false                                |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery_company_success_schema.json"

  @negative @auth
  Scenario: API should fail with invalid authentication token
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
    And I set the query parameters:
      | company_id          | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | bifurcation_prefix  | true                                 |
    And I set the request headers:
      | authenticationtoken  | invalid_token_12345 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "400,401,403"
    And the response should match json schema "schemas/recovery_company_error_schema.json"

  @negative
  Scenario: API should fail when company_id is missing
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | bifurcation_prefix  | true |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "400,401,403,422"
    And the response should match json schema "schemas/recovery_company_error_schema.json"

  @negative
  Scenario: API should fail when company_id is invalid UUID format
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | invalid-company-id |
      | bifurcation_prefix  | true               |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/recovery_company_error_schema.json"

  @negative
  Scenario: API should fail when company_id does not exist
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | 00000000-0000-0000-0000-000000000000 |
      | bifurcation_prefix  | true                                 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/recovery_company_error_schema.json"

  @negative
  Scenario Outline: API should handle invalid bifurcation_prefix values
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
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
