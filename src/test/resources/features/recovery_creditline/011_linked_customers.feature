@api @creditline @creditline-linked-customers @recovery
Feature: Credit-line Linked Customers — GET/POST /recovery/internal[/bulk]/client-customer/linked-loans
  # Credit-line product (company_type == "credit line"). These two endpoints are LOAN-ONLY:
  # they exist to resolve loans linked to a customer for lending company types. For a credit-line
  # company BOTH endpoints ALWAYS return 400 REC_0008 INVALID_COMPANY_TYPE
  # ("...non lending company types") — that is the PRIMARY assertion of this feature.
  # ResponseHandler envelope: {success,message,data,error:{code,detail,data},...}.
  #
  # GET  serializer LinkedCustomerDetails:      loan_id  XOR client_customer_id  (exactly one), source?, allocation_month?
  # POST serializer BulkLinkedCustomerDetails:  loan_ids XOR client_customer_ids (list min 1 / max 50), source?, allocation_month?
  # Serializer XOR / list-size validation runs before the company-type gate, so those negatives
  # return 400 REC_0053 rather than REC_0008.

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ================================================================
  # GET /recovery/internal/client-customer/linked-loans
  # ================================================================

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: GET without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | loan_id    | LOAN_{LOAN_ID} |
    When I send a "GET" request to "/recovery/internal/client-customer/linked-loans"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: GET with invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | loan_id    | LOAN_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    When I send a "GET" request to "/recovery/internal/client-customer/linked-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: GET without company_id returns 400
    # Observed on staging: missing company_id returns 400 (not 403) on this endpoint.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | loan_id | LOAN_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/internal/client-customer/linked-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- PRIMARY assertion: LOAN-only endpoint rejects credit-line company ----------

  @positive @smoke @creditline
  Scenario: GET with loan_id on a credit-line company returns 400 REC_0008 INVALID_COMPANY_TYPE
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | loan_id    | LOAN_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/internal/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0008"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @positive @creditline
  Scenario: GET with client_customer_id on a credit-line company returns 400 REC_0008 INVALID_COMPANY_TYPE
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id         | {COMPANY_ID}   |
      | client_customer_id | CUST_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/internal/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0008"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- XOR validation (exactly one of loan_id / client_customer_id) ----------

  @negative @creditline
  Scenario: GET with BOTH loan_id and client_customer_id returns 400 REC_0053
    # TODO: verify on staging — serializer XOR error expected before the company-type gate.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id         | {COMPANY_ID}   |
      | loan_id            | LOAN_{LOAN_ID} |
      | client_customer_id | CUST_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/internal/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0053"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: GET with NEITHER loan_id nor client_customer_id returns 400 REC_0053
    # TODO: verify on staging — serializer XOR error expected before the company-type gate.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/internal/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0053"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ================================================================
  # POST /recovery/internal/bulk/client-customer/linked-loans
  # ================================================================

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: POST without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": [ "LOAN_{LOAN_ID}" ] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: POST with invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the request body:
      """
      { "loan_ids": [ "LOAN_{LOAN_ID}" ] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: POST without company_id returns 400
    # Observed on staging: missing company_id returns 400 (not 403) on this endpoint.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "loan_ids": [ "LOAN_{LOAN_ID}" ] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- PRIMARY assertion: LOAN-only endpoint rejects credit-line company ----------

  @positive @smoke @creditline
  Scenario: POST with loan_ids on a credit-line company returns 400 REC_0008 INVALID_COMPANY_TYPE
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "loan_ids": [ "LOAN_{LOAN_ID}" ] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0008"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @positive @creditline
  Scenario: POST with client_customer_ids on a credit-line company returns 400 REC_0008 INVALID_COMPANY_TYPE
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "client_customer_ids": [ "CUST_{LOAN_ID}" ] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0008"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- XOR / list-size validation (exactly one non-empty list, min 1 / max 50) ----------

  @negative @creditline
  Scenario: POST with BOTH loan_ids and client_customer_ids returns 400 REC_0053
    # TODO: verify on staging — serializer XOR error expected before the company-type gate.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "loan_ids": [ "LOAN_{LOAN_ID}" ], "client_customer_ids": [ "CUST_{LOAN_ID}" ] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0053"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: POST with NEITHER list returns 400 REC_0053
    # TODO: verify on staging — serializer XOR error expected before the company-type gate.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "source": "unknown" }
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0053"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline @boundary
  Scenario: POST with an empty loan_ids list returns 400 REC_0053 (min_length 1)
    # TODO: verify on staging — serializer min_length error expected before the company-type gate.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "loan_ids": [] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0053"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline @boundary
  Scenario: POST with more than 50 loan_ids returns 400 REC_0053 (max_length 50)
    # TODO: verify on staging — serializer max_length error expected before the company-type gate.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/linked_customers_bulk_over_limit.json"
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0053"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: POST with an empty body returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/internal/bulk/client-customer/linked-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"
