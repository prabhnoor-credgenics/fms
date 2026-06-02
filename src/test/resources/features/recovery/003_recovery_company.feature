@api @recovery-company @testyop
Feature: Recovery Company API and Company Creation Flow

  Background:
    Given scenario company id is from configuration
    And I prepare a request

  @chief-admin @smoke @e2e @requires-clean-state
  Scenario: End-to-end company creation and validation
    Given company creation test data is prepared
    When I create company with validation step 1
    Then company creation step 1 request should match json schema
    And the response status code should be 201
    And the response body should contain field "message"
    And the response should match json schema "schemas/company_creation/success/company_creation_step1_success_schema.json"
    Then company creation step 1 should be successful
    And company creation stored identifiers should be present
    When I create company with validation step 2
    Then company creation step 2 request should match json schema
    And the response status code should be 201
    And the response message should be "Permissions validated and saved."
    And the response should match json schema "schemas/company_creation/success/company_creation_step2_success_schema.json"
    Then company creation step 2 should be successful
    When I create company with validation step 3
    Then company creation step 3 request should match json schema
    And the response status code should be 201
    And the response message should be "Admin details validated and saved."
    And the response should match json schema "schemas/company_creation/success/company_creation_step3_success_schema.json"
    Then company creation step 3 should be successful
    When I create company with validation step 4
    Then company creation step 4 request should match json schema
    And the response status code should be 201
    And the response message should be "company created successfully"
    And the response should match json schema "schemas/company_creation/success/company_creation_step4_success_schema.json"
    Then company creation step 4 should be successful

  @negative @company-creation-step1 @chief-admin
  Scenario Outline: Step 1 should fail when mandatory field <field_name> is missing
    Given company creation test data is prepared
    When I create company with validation step 1 without mandatory field "<field_name>"
    Then the response status code should be 400
    And the response should match json schema "schemas/company_creation/error/company_creation_error_schema.json"

    Examples:
      | field_name                        |
      | company_name                      |
      | trademark                         |
      | company_type                      |
      | company_code                      |
      | gst_number                        |
      | is_test_company                   |
      | authorized_representative_name    |
      | authorized_representative_email   |

  @negative @company-creation-step3 @chief-admin @requires-clean-state
  Scenario Outline: Step 3 should fail when mandatory admin field <field_name> is missing
    Given company creation steps 1 and 2 are completed
    When I create company with validation step 3 without mandatory admin field "<field_name>"
    Then the response status code should be 400
    And the response should match json schema "schemas/company_creation/error/company_creation_error_schema.json"

    Examples:
      | field_name  |
      | first_name  |

  @negative @company-creation-step3 @chief-admin @requires-clean-state
  Scenario: Step 3 should fail when email is missing and mobile is not provided
    Given company creation steps 1 and 2 are completed
    When I create company with validation step 3 without email only
    Then the response status code should be 400
    And the response should match json schema "schemas/company_creation/error/company_creation_error_schema.json"

  @negative @company-creation-step3 @chief-admin @requires-clean-state
  Scenario: Step 3 should fail when both email and mobile are missing
    Given company creation steps 1 and 2 are completed
    When I create company with validation step 3 without email and mobile
    Then the response status code should be 400
    And the response should match json schema "schemas/company_creation/error/company_creation_error_schema.json"



  @positive @creator @get-company
  Scenario: Get full company details with bifurcation prefix true
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | {COMPANY_ID} |
      | bifurcation_prefix  | true         |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_company_success_schema.json"
    And the response body should contain field "company_details.custom_dpd_bucket"
    And the response body should contain field "company_details.show_balance_claim_amount"

  @positive @creator @get-company
  Scenario: Get full company details with bifurcation prefix false
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | {COMPANY_ID} |
      | bifurcation_prefix  | false        |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_company_success_schema.json"

  @positive @creator @get-company
  Scenario: Get company details with specific company_key is_amount_bifurcation_enabled
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id    | {COMPANY_ID}                  |
      | company_keys  | is_amount_bifurcation_enabled |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_filtered_success_schema.json"
    And the response body should contain field "company_details.is_amount_bifurcation_enabled"

  @positive @creator @get-company
  Scenario: Get company details with is_amount_bifurcation_enabled and bifurcation prefix
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id    | {COMPANY_ID}                  |
      | company_keys  | is_amount_bifurcation_enabled |
      | bifurcation_prefix | false                    |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_filtered_success_schema.json"
    And the response body should contain field "company_details.is_amount_bifurcation_enabled"

  @positive @creator @get-company
  Scenario: Get company details filtered by module_name payment
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | module_name  | payment      |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_filtered_success_schema.json"

  @positive @creator @get-company
  Scenario: Get company details filtered by module_name fos
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | module_name  | fos          |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_filtered_success_schema.json"

  @positive @creator @get-company
  Scenario: Get company details filtered by module_name settlement
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | module_name  | settlement   |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_filtered_success_schema.json"

  @positive @creator @get-company
  Scenario: Get company details with company_key and bifurcation_prefix combined
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}              |
      | company_keys        | is_amount_bifurcation_enabled |
      | bifurcation_prefix  | true                      |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_filtered_success_schema.json"



  @negative @auth @get-company
  Scenario: GET should fail with invalid authentication token
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | invalid_token_12345 |
    And I set the query parameters:
      | company_id          | {COMPANY_ID} |
      | bifurcation_prefix  | true         |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_company_error_schema.json"

  @negative @get-company @creator
  Scenario: GET should fail when company_id is missing
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | bifurcation_prefix  | true |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/error/recovery_company_error_schema.json"

  @negative @get-company @creator
  Scenario: GET should fail when company_id is invalid UUID format
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | invalid-company-id |
      | bifurcation_prefix  | true               |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_company_error_schema.json"

  @negative @get-company @creator
  Scenario: GET should fail when company_id does not exist
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | 00000000-0000-0000-0000-000000000000 |
      | bifurcation_prefix  | true                                 |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_company_error_schema.json"

  @negative @get-company @creator
  Scenario: GET should fail with invalid company_keys value
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id    | {COMPANY_ID}        |
      | company_keys  | invalid_key_xyz     |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @get-company @creator
  Scenario: GET should fail with invalid module_name value
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}  |
      | module_name  | invalid_module |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @get-company @creator
  Scenario Outline: GET should return 200 for non-boolean bifurcation_prefix string values
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}         |
      | bifurcation_prefix  | <bifurcation_prefix> |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

    Examples:
      | bifurcation_prefix |
      | yes                |
      | 1                  |

  @negative @get-company @creator
  Scenario: GET should return 400 when bifurcation_prefix is null
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}   |
      | bifurcation_prefix  | null           |
    When I send a "GET" request to "/recovery/company"
    Then the response status code should be 400
    And the response body should not be empty



  @positive @creator @put-company
  Scenario: Update company enable_auto_calculation to true
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "enable_auto_calculation": true
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_put_success_schema.json"
    And the response body should contain field "message"

  @positive @creator @put-company
  Scenario: Update company enable_auto_calculation to false
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "enable_auto_calculation": false
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_put_success_schema.json"

  @positive @creator @put-company
  Scenario: Update company show_balance_claim_amount flag
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "show_balance_claim_amount": true
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_put_success_schema.json"

  @positive @creator @put-company
  Scenario: Update company payment_allocation_month
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "payment_allocation_month": "current"
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_put_success_schema.json"

  @positive @creator @put-company
  Scenario: Enable amount bifurcation with payment module
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": [
          {
            "module_name": "payment",
            "is_enabled": true
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator @put-company
  Scenario: Enable amount bifurcation with multiple modules
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": [
          {
            "module_name": "payment",
            "is_enabled": true
          },
          {
            "module_name": "fos",
            "is_enabled": true
          },
          {
            "module_name": "settlement",
            "is_enabled": false
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator @put-company
  Scenario: Update multiple company fields in single request
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "enable_auto_calculation": true,
        "show_balance_claim_amount": false,
        "payment_allocation_month": "current"
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_company_put_success_schema.json"



  @negative @put-company @creator
  Scenario: PUT should fail when company_id is missing from body
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "enable_auto_calculation": true
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/error/recovery_company_error_schema.json"

  @negative @put-company @creator
  Scenario: PUT should fail when company_id is invalid UUID
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "not-a-valid-uuid",
        "enable_auto_calculation": true
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_company_error_schema.json"

  @negative @put-company @creator
  Scenario: PUT should fail or error when amount_bifurcation_modules has invalid module_name
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": [
          {
            "module_name": "invalid_module",
            "is_enabled": true
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @negative @auth @put-company
  Scenario: PUT should fail without authentication token
    And I set the request headers:
      | Content-Type  | application/json |
      | accept        | application/json |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "enable_auto_calculation": true
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_company_error_schema.json"

  @negative @auth @put-company
  Scenario: PUT should fail with invalid authentication token
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | invalid_token_xyz |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "enable_auto_calculation": true
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/recovery_company_error_schema.json"

  @additional_scenario @negative @put-company @creator
  Scenario: PUT should return 500 when enabling bifurcation with fos module only
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": [
          {
            "module_name": "fos",
            "is_enabled": true
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @additional_scenario @negative @put-company @creator
  Scenario: PUT should return 500 when enabling bifurcation with settlement module only
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": [
          {
            "module_name": "settlement",
            "is_enabled": true
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @additional_scenario @negative @put-company @creator
  Scenario: PUT should return 500 when enabling bifurcation with all modules disabled
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": [
          {
            "module_name": "payment",
            "is_enabled": false
          },
          {
            "module_name": "fos",
            "is_enabled": false
          },
          {
            "module_name": "settlement",
            "is_enabled": false
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @additional_scenario @negative @put-company @creator
  Scenario: PUT should return 500 when bifurcation enabled with empty modules array
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": []
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @additional_scenario @negative @put-company @creator
  Scenario: PUT should return 500 when bifurcation modules array contains duplicate module names
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": [
          {
            "module_name": "payment",
            "is_enabled": true
          },
          {
            "module_name": "payment",
            "is_enabled": false
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @additional_scenario @negative @put-company @creator
  Scenario: PUT should return 500 when bifurcation module_name is null
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": true,
        "amount_bifurcation_modules": [
          {
            "module_name": null,
            "is_enabled": true
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty

  @additional_scenario @negative @put-company @creator
  Scenario: PUT should return 500 when disabling bifurcation while providing modules array
    And I set the request headers:
      | Content-Type         | application/json |
      | accept               | application/json |
      | authenticationtoken  | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_amount_bifurcation_enabled": false,
        "amount_bifurcation_modules": [
          {
            "module_name": "payment",
            "is_enabled": true
          }
        ]
      }
      """
    When I send a "PUT" request to "/recovery/company"
    Then the response status code should be 200
    And the response body should not be empty
