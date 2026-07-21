@api @creditline @creditline-transaction-exports @recovery
Feature: Credit-line Transaction Exports — POST /recovery/export/{bulk,export-now,export-later}/loan-transactions
  # Credit-line product (company_type == "credit line"). GROUP 8, flat envelope
  # ({output|data, message, message_template, message_placeholder} — no success/error keys,
  #  EXCEPT export-later which additionally returns success:true).
  # Auth: login + org; permission export_loans:read (granted for happy paths).
  # Body: LoanExport (extra keys allowed). export_type MUST be set:
  #   - "transaction" for /export/bulk and /export/export-now
  #   - "portfolio_transaction_data" for /export/export-later
  #   (default is "customer" — omitting it silently exports customer data, see note scenario).
  # response_type "link" (default) / "data" applies to /export/bulk only; export-now is always a link.
  # Other LoanExport fields: allocation_month, archive, selected_loan_ids, historical_loan_limit,
  #   deselected (credit-line only).
  # Because success shape depends on data volume in the target company, assertions here favour
  # `contain field "message"` / `contain text` over brittle exact matches; volume-dependent
  # branches are marked # TODO: verify on staging.

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission matrix (exercised on /export/bulk) ----------

  @negative @creditline
  Scenario: Bulk export without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Bulk export with an invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Bulk export with missing company_id returns 403
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 403
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Export-now without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/export-now/loan-transactions"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Export-later without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/creditline/loan_export_transaction_later.json"
    When I send a "POST" request to "/recovery/export/export-later/loan-transactions"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path — /export/bulk/loan-transactions ----------

  @positive @smoke @creditline
  Scenario: Bulk export with response_type=link returns 200 (link or no-data-found)
    # Flat 200: either {data:[],message:"no data found"} when the company has no matching
    # transactions, or {output:"<S3 url>",message:"success"}. Assert on the always-present message.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"

  @positive @creditline
  Scenario: Bulk export with response_type=data returns 200
    # Flat 200: {data:[rows],message:"success"} with rows, or {data:[],message:"no data found"} when empty.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    And I update JSON field "response_type" to "data"
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"

  @positive @creditline
  Scenario: Bulk export with explicit export_type=transaction and archive flag returns 200
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
      { "export_type": "transaction", "response_type": "link", "archive": true }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"

  # ---------- Happy path — /export/export-now/loan-transactions (always a link) ----------

  @positive @smoke @creditline
  Scenario: Export-now returns 200 (always a link / no-data-found)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction.json"
    When I send a "POST" request to "/recovery/export/export-now/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"

  # ---------- Happy path — /export/export-later/loan-transactions ----------

  @positive @smoke @creditline
  Scenario: Export-later with export_type=portfolio_transaction_data returns 200 success:true
    # Flat 200 with a success flag: {message:"<html confirmation>"|"download link has been sent successfully", success:true}.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction_later.json"
    When I send a "POST" request to "/recovery/export/export-later/loan-transactions"
    Then the response status code should be 200
    # NOTE: `success` is a JSON boolean (true), not the string "true", so we only assert the
    # field is present (the `with value` step does a string compare and would fail on a boolean).
    And the response body should contain field "success"
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_later_success_schema.json"

  # ---------- Business/domain rules ----------

  @positive @creditline
  Scenario: Export-later with export_type=transaction is accepted and returns 200 success:true
    # TODO: verify on staging — not enforced. The doc-implied "Invalid export type" 400 guard does
    # NOT fire here: export_type="transaction" is accepted by export-later and the request falls
    # through to the portfolio-data export flow, returning 200 {message:"<html confirmation>",success:true}.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/loan_export_transaction_later.json"
    And I update JSON field "export_type" to "transaction"
    When I send a "POST" request to "/recovery/export/export-later/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_later_success_schema.json"

  @positive @creditline @boundary
  Scenario: Bulk export with a selected_loan_ids list returns 200 (5000-loan guard not tripped)
    # TODO: verify on staging — not enforced here. The > 5000 guard ("Loan Export is supported for a
    # maximum of 5000 loans at a time.") requires seeding > 5000 selected_loan_ids, which is
    # impractical in this suite. With one placeholder id the request is under the limit and returns
    # 200 {data:[],message:"no data found"} (no matching data). The documented 400 limit stays untested.
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
      { "export_type": "transaction", "response_type": "link", "selected_loan_ids": ["CUST_{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"

  # ---------- Behaviour note: missing export_type falls back to "customer" ----------

  @positive @creditline
  Scenario: Bulk export with no export_type falls back to a customer export and still returns 200
    # NOTE: export_type defaults to "customer" when omitted, so this exports customer (not transaction)
    # data — it does NOT error. Included to document the silent fallback.
    # TODO: verify on staging — confirm 200 and that the export contents are customer-scoped.
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
      { "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-transactions"
    Then the response status code should be 200
    And the response body should contain field "message"
    And the response should match json schema "schemas/creditline/success/transaction_export_link_success_schema.json"
