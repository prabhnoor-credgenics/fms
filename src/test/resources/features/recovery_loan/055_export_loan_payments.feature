@api @export-loan-payments @recovery
Feature: Export Loan Payments — POST /recovery/export/bulk/loan-payments



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal {} (link mode default) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: response_type=data returns 200 (data array)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/export_loan_payments_data_success_schema.json"
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: response_type=link returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: By selected_loan_ids returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "selected_loan_ids": ["LOAN0001", "LOAN0002"], "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: Date range (start + end) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "start_date": "2026-01-01", "end_date": "2026-01-31", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: Only start_date returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "start_date": "2026-01-01", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: Only end_date returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "end_date": "2026-01-31", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: allocation_month specific returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocation_month": "2026-01-01", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: allocation_month overall returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocation_month": "overall", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario Outline: archive "<archive>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "archive": "<archive>", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

    Examples:
      | archive |
      | true    |
      | false   |

  @positive @creator
  Scenario Outline: search_type "<search_type>" with response_type=data returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_type": "<search_type>", "query": "X", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

    Examples:
      | search_type              |
      | loan_id                  |
      | applicant_name           |
      | applicant_email          |
      | applicant_contact_number |
      | business_name            |
      | client_customer_id       |
      | group_id                 |
      | center_name              |

  @positive @creator
  Scenario Outline: sort "<sort>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "sort": "<sort>", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

    Examples:
      | sort                   |
      | created_desc           |
      | total_claim_amount_desc|
      | date_of_default_asc    |

  @positive @creator
  Scenario: Pagination (page_number + page_size) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "page_number": 2, "page_size": 100, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: Range selection (select_from + select_to) with deselected returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "select_from": 1, "select_to": 500, "deselected": ["LOAN0009"], "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @positive @creator
  Scenario: user_details metadata returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "user_details": { "requested_by": "ops_user" }, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid

  @negative @creator
  Scenario: export_id referencing a non-existent export task returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | export_id  | 3001         |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "selected_loan_ids": ["LOAN0001"], "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 400
    And the "export_loan_payments" failure response should be valid

  @negative @creator
  Scenario: Extra portfolio filter fields error on the payment export (500)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocation_month": "2026-01-01", "recovery_status": ["promise_to_pay"], "state": ["maharashtra"], "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 500
    And the response body should not be empty

  @positive @creator
  Scenario: Combined — selected loans, date-bounded, transactions returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocation_month": "2026-01-01", "selected_loan_ids": ["LOAN0001", "LOAN0002"], "start_date": "2026-01-01", "end_date": "2026-01-31", "include_transactions": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 200
    And the "export_loan_payments" success response should be valid


  @negative @creator
  Scenario: Empty body (no JSON) returns 400 (Empty request body)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 400
    And the "export_loan_payments" failure response should be valid

  @negative @creator
  Scenario Outline: Invalid field "<case>" returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 400
    And the "export_loan_payments" failure response should be valid

    Examples:
      | case                  | body                                     |
      | invalid response_type | { "response_type": "xml" }               |
      | invalid search_type   | { "search_type": "bogus", "query": "x" } |
      | invalid sort          | { "sort": "bogus_sort" }                 |
      | unparseable start_date| { "start_date": "notadate" }             |


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      { "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json                                  |
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    And I set the request body:
      """
      { "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected (insufficient access rights)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: GET on the export/bulk/loan-payments endpoint is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/export/bulk/loan-payments"
    Then the response status code should be 405
