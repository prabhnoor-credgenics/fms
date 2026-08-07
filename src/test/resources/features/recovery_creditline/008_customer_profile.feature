@api @creditline @creditline-customer-profile @recovery
Feature: Credit-line Customer Profile — GET & PATCH /recovery/customer/profile/<client_customer_id>

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |


  @negative @creditline
  Scenario: GET without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: GET with invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: GET without company_id returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @smoke @creditline
  Scenario: Fetch the profile of a freshly created customer returns 200 with success and output
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    And I wait for 5 seconds
    When I send a "GET" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/customer_profile_get_success_schema.json"


  @negative @creditline
  Scenario: GET an unknown client_customer_id returns 400 Invalid client customer id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | client_customer_id | CUST_MISSING_{UUID} |
    When I send a "GET" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 400
    And the response message should be "Invalid client customer id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @creditline
  Scenario Outline: GET honours allocation_month and loan_details_meta_data query params (200)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id             | {COMPANY_ID}             |
      | allocation_month       | <allocation_month>       |
      | loan_details_meta_data | <loan_details_meta_data> |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    And I wait for 5 seconds
    When I send a "GET" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/customer_profile_get_success_schema.json"

    Examples:
      | allocation_month | loan_details_meta_data |
      | Overall          | false                  |
      | Overall          | true                   |
      | 2026-7-01        | false                  |


  @negative @creditline
  Scenario: PATCH without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/creditline/customer_profile_patch.json"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "PATCH" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: PATCH without company_id returns 403
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/customer_profile_patch.json"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "PATCH" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 403
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @smoke @creditline
  Scenario: Update a customer variable on a freshly created customer returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/creditline/customer_profile_patch.json"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    And I wait for 5 seconds
    When I send a "PATCH" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 200
    And the response body should not be empty
    And the response should match json schema "schemas/creditline/success/customer_profile_patch_success_schema.json"

  @positive @creditline
  Scenario Outline: PATCH honours the append query param (200)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | append     | <append>     |
    And I set the request body from file "test-data/creditline/customer_profile_patch.json"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    And I wait for 5 seconds
    When I send a "PATCH" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/creditline/success/customer_profile_patch_success_schema.json"

    Examples:
      | append |
      | false  |
      | true   |


  @negative @creditline
  Scenario: PATCH with an empty body returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      {}
      """
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "PATCH" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @negative @creditline
  Scenario: PATCH an unknown client_customer_id returns 400 customer not found
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/customer_profile_patch.json"
    And I set the path parameters:
      | client_customer_id | CUST_MISSING_{UUID} |
    When I send a "PATCH" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 400
    And the response message should be "customer not found"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"
