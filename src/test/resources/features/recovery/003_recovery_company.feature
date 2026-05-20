@api @recovery-company
Feature: Recovery Company API and Company Creation Flow



   @chief-admin @smoke @e2e
  Scenario: End-to-end company creation and validation
    Given company creation test data is prepared
    When I create company with validation step 1
    Then company creation step 1 should be successful
    And company creation stored identifiers should be present
    When I create company with validation step 2
    Then company creation step 2 should be successful
    When I create company with validation step 3
    Then company creation step 3 should be successful
    When I create company with validation step 4
    Then company creation step 4 should be successful
    And company creation final identifiers should be present
    When I get user company details for the created company
    Then the created company details should match test context
    When I get recovery company details for the created company
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery_company_success_schema.json"

  @chief-admin @company-creation-step1
  Scenario: Create Company Step 1 - Basic details
    Given company creation test data is prepared
    When I create company with validation step 1
    Then company creation step 1 should be successful
    And company creation stored identifiers should be present

  @chief-admin @company-creation-step2
  Scenario: Create Company Step 2 - Permissions setup
    Given company creation step 1 is completed
    When I create company with validation step 2
    Then company creation step 2 should be successful

  @chief-admin @company-creation-step3
  Scenario: Create Company Step 3 - Admin setup
    Given company creation steps 1 and 2 are completed
    When I create company with validation step 3
    Then company creation step 3 should be successful

  @chief-admin @company-creation-step4
  Scenario: Create Company Step 4 - Finalize company creation
    Given company creation steps 1, 2 and 3 are completed
    When I create company with validation step 4
    Then company creation step 4 should be successful
    And company creation final identifiers should be present

  @chief-admin @company-creation-get
  Scenario: Get Company Details after creation
    Given company creation steps 1, 2 and 3 are completed
    When I create company with validation step 4
    Then company creation step 4 should be successful
    When I get user company details for the created company
    Then the created company details should match test context



  @positive
  Scenario: Get company details with bifurcation prefix true
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
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
    Given I prepare a request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | 43eb0d02-ef8f-48cb-b0e0-c1268926a0a3 |
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
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | 43eb0d02-ef8f-48cb-b0e0-c1268926a0a3 |
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
