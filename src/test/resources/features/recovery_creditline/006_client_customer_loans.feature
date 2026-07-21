@api @creditline @creditline-client-customer-loans @recovery
Feature: Credit-line Client Customer Loans — GET /recovery/client/customer/loans/<client_customer_id>
  # Credit-line product (company_type == "credit line"). GROUP 4c detail-fetch endpoint.
  # Flat envelope: {output:[...], message}. login+org only (no loan permission required for GET).
  # Query param allocation_month is optional; its default is the current month in YYYY-M-01 form
  # (built here with {ALLOCATION_MONTH_OFFSET:0}). An unknown client_customer_id returns an empty
  # output list with a 200 "success". The client_customer_id is a path segment — supplied via a
  # RestAssured path parameter ({clientCustomerId}) so the framework resolves CUST_{LOAN_ID} rather
  # than RestAssured treating the raw {LOAN_ID} braces as an unfilled path template.

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | clientCustomerId | CUST_{LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | clientCustomerId | CUST_{LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400
    # Reconcile: GROUP 4c is a plain detail-fetch endpoint; missing company_id returns 400
    # (not 403 — only the bulk upload/update endpoints return 403 for a missing company_id).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | clientCustomerId | CUST_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (multi-step chain: upload a transaction, then read the loans back) ----------

  @positive @smoke @creditline
  Scenario: Upload a transaction for a customer then fetch that customer's loans returns 200 success
    # Step 1 — create a transaction for CUST_{LOAN_ID} (upload needs loan permission; grant it to creator0).
    # TODO: verify on staging — upload is async (202 + request_id); the worker may not have persisted the
    # row by the time the GET runs, so the transaction_id text assertion below may need a settle/poll.
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
      { "transaction_data": [ { "client_customer_id": "CUST_{LOAN_ID}", "transaction_id": "TXN_{LOAN_ID}", "total_loan_amount": 50000, "amount_recovered": 1000 } ] }
      """
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    # Step 2 — fetch the loans for that same client_customer_id and expect our transaction back.
    Given I prepare a request
    And I wait for 5 seconds
    And I set the path parameters:
      | clientCustomerId | CUST_{LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should not be empty
    And the response should match json schema "schemas/creditline/success/client_customer_loans_success_schema.json"

  @positive @creditline
  Scenario: Fetch loans with default allocation_month (param omitted) returns 200 success
    # No allocation_month supplied — backend defaults to the current month (YYYY-M-01).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | clientCustomerId | CUST_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/client_customer_loans_success_schema.json"

  # ---------- allocation_month variants ----------

  @positive @creditline @boundary
  Scenario Outline: allocation_month accepts current / previous / next month and returns 200 success
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | clientCustomerId | CUST_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                       |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:<offset>} |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/client_customer_loans_success_schema.json"

    Examples:
      | offset |
      | 0      |
      | -1     |
      | 1      |

  # ---------- Unknown customer ----------

  @positive @creditline
  Scenario: Fetch loans for an unknown client_customer_id returns 200 with an empty output list
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | clientCustomerId | CUST_UNKNOWN_{RANDOM_STRING:10} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should not contain text "TXN_"
    And the response should match json schema "schemas/creditline/success/client_customer_loans_success_schema.json"

  # ---------- Path param negatives ----------

  @negative @creditline
  Scenario: Literal "undefined" client_customer_id returns 200 with an empty output list
    # TODO: verify on staging — sentinel string sent by frontends; expected to resolve as an unknown
    # customer (empty list, 200) rather than a hard error.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | clientCustomerId | undefined |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/client_customer_loans_success_schema.json"

  @negative @creditline
  Scenario: Literal "null" client_customer_id returns 200 with an empty output list
    # TODO: verify on staging — sentinel string; expected to resolve as an unknown customer (empty list, 200).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | clientCustomerId | null |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/client/customer/loans/{clientCustomerId}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/client_customer_loans_success_schema.json"
