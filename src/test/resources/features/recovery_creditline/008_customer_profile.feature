@api @creditline @creditline-customer-profile @recovery
Feature: Credit-line Customer Profile — GET & PATCH /recovery/customer/profile/<client_customer_id>
  # Credit-line product (company_type == "credit line"). Flat envelope
  # {output|data, message, message_template, message_placeholder} — no success/error keys.
  # GET (Group 5b) is permission-exempt (login+org only): 200 {output:<customer_details>, message:"success"};
  #   query allocation_month, loan_details_meta_data (bool). Unknown customer -> 400 {message:"Invalid client customer id"}.
  # PATCH (Group 5c) needs loan_update:write: body nested under "customer" as
  #   {"source":"api","customer":{...}}; query append (default "false").
  #   200 {output:"Customer successfully updated", message:"success"} or {message:"no data to update"};
  #   empty body -> 400; unknown customer -> 400 {message:"customer not found"}.
  # Happy paths chain off POST /recovery/v1/bulk/transaction-upload to create CUST_{LOAN_ID} first.
  # NOTE: the <client_customer_id> path segment is supplied via "I set the path parameters:"
  #   ({client_customer_id}); putting CUST_{LOAN_ID} directly in the URL makes RestAssured treat
  #   {LOAN_ID} as an (undefined) path-param template.

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ===================================================================
  # GET /recovery/customer/profile/<client_customer_id>
  # ===================================================================

  # ---------- Auth (GET is permission-exempt) ----------

  @negative @creditline
  Scenario: GET without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
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
    # Reconciled: GET customer/profile (perm-exempt) returns 400 for a missing company_id,
    # not 403 (only the bulk upload/update endpoints return 403 — contract §6 rule 1).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (multi-step chain: create -> read back) ----------

  @positive @smoke @creditline
  Scenario: Fetch the profile of a freshly created customer returns 200 with success and output
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    # step 1 — create the customer via a transaction upload
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    # step 2 — read back that customer's profile (GET is permission-exempt)
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

  # ---------- Business/domain: unknown customer ----------

  @negative @creditline
  Scenario: GET an unknown client_customer_id returns 400 Invalid client customer id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
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

  # ---------- Query parameter variants (allocation_month / loan_details_meta_data) ----------

  @positive @creditline
  Scenario Outline: GET honours allocation_month and loan_details_meta_data query params (200)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
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

  # ===================================================================
  # PATCH /recovery/customer/profile/<client_customer_id>
  # ===================================================================

  # ---------- Auth ----------

  @negative @creditline
  Scenario: PATCH without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
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
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/customer_profile_patch.json"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "PATCH" request to "/recovery/customer/profile/{client_customer_id}"
    Then the response status code should be 403
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (multi-step chain: create -> update) ----------

  @positive @smoke @creditline
  Scenario: Update a customer variable on a freshly created customer returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    # step 1 — create the customer via a transaction upload
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/transaction_bulk_upload.json"
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    # step 2 — patch a customer variable (body nested under "customer")
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
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
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

  # ---------- Required-field / body validation ----------

  @negative @creditline
  Scenario: PATCH with an empty body returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
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

  # ---------- Business/domain: unknown customer ----------

  @negative @creditline
  Scenario: PATCH an unknown client_customer_id returns 400 customer not found
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
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
