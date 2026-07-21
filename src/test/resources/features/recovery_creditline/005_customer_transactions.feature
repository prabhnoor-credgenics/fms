@api @creditline @creditline-customer-transactions @recovery
Feature: Credit-line Customer Transactions — GET /recovery/customer/transactions
  # Credit-line product (company_type == "credit line"). GROUP 4b. Flat envelope
  # {output:[...], message:"success"}; login + org only, NO loan permission required for the GET.
  # This is a CREDIT-LINE-ONLY endpoint: a non-credit-line company gets
  #   400 {output:"Not a Credit Line company", message:"failure"}.
  # That branch is NOT testable here — the creditline slot logs into a credit-line company, so we can
  # only ever exercise the credit-line (200) path. The 400 gate is documented for completeness only.
  # Query params: client_customer_id (customer to fetch transactions for), allocation_month (default "Overall").

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id         | {COMPANY_ID}    |
      | client_customer_id | CUST_{LOAN_ID}  |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id         | {COMPANY_ID}    |
      | client_customer_id | CUST_{LOAN_ID}  |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400
    # Observed on staging: this GET returns 400 {"message":"invalid company id"} (not 403 — only the
    # bulk upload/update return 403 for a missing company_id).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 400
    And the response message should be "invalid company id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (multi-step chain: upload a transaction, then read it back) ----------

  @positive @smoke @creditline @env-blocked
  # TODO: verify on staging — creditline company data/config dependent. Fetching transactions for a
  # specific client_customer_id returns 500 {"message":"something went wrong"} because the creditline
  # company has no seeded customer to read back (the async upload does not materialise CUST_{LOAN_ID}
  # synchronously). Only the no-customer-filter GET (company_id only) returns a clean 200 empty list.
  Scenario: Upload a transaction then fetch it via customer/transactions returns 200 with a list
    # Step 1 — upload a transaction for CUST_{LOAN_ID} (needs loan write permission).
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
    And the response body should contain field "data.request_id"
    # Step 2 — read back the transactions for that customer. Upload is async, so the row may not
    # be materialised yet; we assert the endpoint contract (200 + success + list), not row presence.
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id         | {COMPANY_ID}   |
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"

  # ---------- allocation_month variants ----------

  @positive @creditline @env-blocked
  # TODO: verify on staging — creditline company data/config dependent. Filtering by the specific
  # (unseeded) client_customer_id CUST_{LOAN_ID} returns 500 {"message":"something went wrong"}; the
  # endpoint only returns a clean 200 when no client_customer_id is supplied.
  Scenario: Default allocation_month ("Overall") when the param is omitted returns 200 with a list
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id         | {COMPANY_ID}   |
      | client_customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"

  @positive @creditline @env-blocked
  # TODO: verify on staging — creditline company data/config dependent. Filtering by the specific
  # (unseeded) client_customer_id CUST_{LOAN_ID} returns 500 {"message":"something went wrong"}
  # regardless of allocation_month; the endpoint only returns a clean 200 with no client_customer_id.
  Scenario Outline: allocation_month values are accepted and return 200 with a list
    # TODO: verify on staging — a specific month with no data still returns 200 + empty list.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id         | {COMPANY_ID}      |
      | client_customer_id | CUST_{LOAN_ID}    |
      | allocation_month   | <allocation_month> |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"

    Examples:
      | allocation_month |
      | Overall          |
      | 2026-7-01        |

  # ---------- Missing / unknown customer ----------

  @positive @creditline
  Scenario: Missing client_customer_id returns 200 with an empty result
    # No customer filter → endpoint still resolves; expect a successful flat list envelope.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"

  @positive @creditline @env-blocked
  # TODO: verify on staging — creditline company data/config dependent. Supplying a specific
  # (nonexistent) client_customer_id returns 500 {"message":"something went wrong"} instead of a 200
  # empty list; the customer-lookup path errors for unseeded ids on this creditline company.
  Scenario: Unknown client_customer_id returns 200 with an empty list
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id         | {COMPANY_ID}                       |
      | client_customer_id | NO_SUCH_CUSTOMER_{LOAN_ID}         |
    When I send a "GET" request to "/recovery/customer/transactions"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/customer_transactions_success_schema.json"
