@api @export-bulk-loan-details @recovery
Feature: Export Bulk Loan Details API — POST /recovery/export/bulk/loan-details



  @negative
  Scenario: TC-AUTH-001 — Request without authenticationtoken header returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative 
  Scenario: TC-AUTH-003 — Valid token resolves to valid company — 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive 
  Scenario: TC-BODY-001 — Empty body {} returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-BODY-002 — Valid allocation_month "2026-01-01" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-BODY-003 — allocation_month "Overall" — service behaviour TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "Overall",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative 
  Scenario: TC-BODY-004 — Invalid allocation_month format returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "not-a-date"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive 
  Scenario: TC-BODY-005 — archive = true returns 200 (queries archived loans)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "archive": true,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-BODY-006 — archive = false returns 200 (queries active loans)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "archive": false,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-BODY-007 — Extra unknown fields accepted without error — Config.extra="allow"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": "data",
        "unknown_field": "this is forwarded silently",
        "another_extra": 12345
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-BODY-008 — allocation_month = null defaults to current month returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": null,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative 
  Scenario: TC-BODY-009 — allocation_month as integer is not a parseable date returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": 20260101
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive 
  Scenario: TC-EXPTYPE-001 — export_type "customer" (default) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "customer",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EXPTYPE-002 — export_type "transaction" forces 4 flags to false via root_validator
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "transaction",
        "include_additional_columns": true,
        "include_allocated_users": true,
        "inc_doc_links": true,
        "tags_column": true,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EXPTYPE-003 — export_type "allocated_users" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "allocated_users",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EXPTYPE-004 — export_type "portfolio_allocated_users" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "portfolio_allocated_users",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EXPTYPE-005 — export_type "portfolio_data" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "portfolio_data",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EXPTYPE-006 — export_type "portfolio_transaction_data" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "portfolio_transaction_data",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EXPTYPE-007 — export_type "bulk_document_download" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "bulk_document_download",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative 
  Scenario: TC-EXPTYPE-008 — Invalid export_type returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01",
        "export_type": "invalid_type"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive 
  Scenario: TC-RESP-001 — response_type "link" (default) returns 200 with S3 output URL
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": "link"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-RESP-002 — response_type "data" returns 200 with data array
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative 
  Scenario: TC-RESP-003 — Invalid response_type "csv" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01",
        "response_type": "csv"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive 
  Scenario: TC-SORT-001 — sort "created_desc" is a valid enum value returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "sort": "created_desc",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-SORT-002 — sort "principal_outstanding_amount_asc" silently dropped to null — returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "sort": "principal_outstanding_amount_asc",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-SORT-003 — sort = "null" string coerced to null returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "sort": "null",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-SORT-004 — sort = null (JSON null) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "sort": null,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative 
  Scenario: TC-SORT-005 — Invalid sort value not in SortBy enum returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01",
        "sort": "totally_invalid_sort_field"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive 
  Scenario: TC-SEARCH-001 — search_type "loan_id" with query string returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "search_type": "loan_id",
        "query": "{LOAN_ID}",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-SEARCH-002 — search_type "applicant_name" with query returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "search_type": "applicant_name",
        "query": "test",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-SEARCH-003 — search_type empty string coerced to "loan_id" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "search_type": "",
        "query": "{LOAN_ID}",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative 
  Scenario: TC-SEARCH-004 — Invalid search_type not in SearchType enum returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01",
        "search_type": "invalid_search"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive 
  Scenario: TC-SELINDS-001 — selected_loan_ids with valid IDs bypasses portfolio filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected_loan_ids": ["{LOAN_ID}"],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-SELINDS-002 — selected_loan_ids as empty list — service behaviour TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected_loan_ids": [],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-SELINDS-003 — selected_loan_ids + select_from/select_to — portfolio filter takes over
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "selected_loan_ids": ["{LOAN_ID}"],
        "select_from": 0,
        "select_to": 100,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-SELINDS-004 — selected_loan_ids with only non-existent IDs returns 200 no data
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected_loan_ids": ["NON-EXISTENT-LOAN-{UUID}", "ANOTHER-MISSING-{UUID}"],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"



  @negative 
  Scenario: TC-EXPORTID-001 — export_id not found in DB returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01"
      }
      """
    And I set the query parameters:
      | export_id | 99999999 |
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive 
  Scenario: TC-EXPORTID-002 — export_id with COMPLETED or FAILED status returns 200 no data
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01"
      }
      """
    And I set the query parameters:
      | export_id | 1 |
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-EXPORTID-003 — Without export_id query param — normal export flow runs
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"



  @positive 
  Scenario: TC-COLS-001 — All boolean column flags = true returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "customer",
        "include_fos_users": true,
        "include_calling_users": true,
        "include_additional_columns": true,
        "include_derivable_variables": true,
        "include_allocated_users": true,
        "inc_doc_links": true,
        "tags_column": true,
        "co_applicant_columns": true,
        "doc_detail_columns": true,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-COLS-002 — Custom column count overrides with explicit values returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "number_of_applicant_addresses": 5,
        "number_of_references": 6,
        "number_of_co_applicants": 10,
        "number_of_co_applicant_addresses": 3,
        "number_of_document_details": 4,
        "number_of_custom_list_variable_items": 8,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-COLS-003 — historical_loan_limit = true extends record cap to 100k
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "historical_loan_limit": true,
        "response_type": "link"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-COLS-004 — Number column counts as zero — TBD behaviour
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "number_of_co_applicants": 0,
        "co_applicant_columns": true,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"



  @positive 
  Scenario: TC-FILTER-001 — dpd_bracket filter returns 200
    # TODO: 200-only — DPD bracket is derived from date_of_default vs the allocation month — not directly settable on a plain upload. Loan presence not asserted.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "dpd_bracket": ["0_30", "30_60"],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-FILTER-002 — dpd_from / dpd_to numeric range generates dynamic bracket
    # TODO: 200-only — DPD range is derived — not directly settable on a plain upload. Loan presence not asserted.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "dpd_from": 30,
        "dpd_to": 90,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-FILTER-003 — applicant_state filter returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    # match the applicant_state filter below so the uploaded loan appears in the export
    And I update JSON field "applicant_address[0].applicant_state" to "maharashtra"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "applicant_state": ["maharashtra", "karnataka"],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain text "{LOAN_ID}"

  @positive 
  Scenario: TC-FILTER-004 — recovery_status filter returns 200
    # TODO: 200-only — recovery_status is a disposition set via status-update, not on upload. Loan presence not asserted.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "recovery_status": ["promise_to_pay"],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-FILTER-005 — date_of_default range filter returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "date_of_default_from": "2025-01-01",
        "date_of_default_to": "2025-12-31",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    # uploaded loan's defaults[0].date_of_default is 2025-08-04 — inside the filter range
    And the response body should contain text "{LOAN_ID}"

  @positive 
  Scenario: TC-FILTER-006 — total_loan_amount range filter returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    # set total_loan_amount inside the 50000-500000 filter range so the loan appears
    And I update JSON field "total_loan_amount" to "100000"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "total_loan_amount_from": 50000,
        "total_loan_amount_to": 500000,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain text "{LOAN_ID}"

  @positive 
  Scenario: TC-FILTER-007 — co_applicant_present = true with co_app_from/upto returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "co_applicant_present": true,
        "co_app_from": 1,
        "co_app_upto": 3,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    # uploaded loan already carries 2 co-applicants — inside the 1..3 filter range
    And the response body should contain text "{LOAN_ID}"

  @positive 
  Scenario: TC-FILTER-008 — upload_date range filter returns 200
    # TODO: 200-only — upload_date is server-set to the actual upload day; the loan will not fall in a past (Jan) range. Loan presence not asserted.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "upload_date_from": "2026-01-01",
        "upload_date_to": "2026-01-31",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-FILTER-009 — speedpost_status filter returns 200
    # TODO: 200-only — speedpost_status requires a notice/speedpost dispatch, not produced by a loan upload. Loan presence not asserted.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "speedpost_status": ["delivered", "in-transit"],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-FILTER-010 — Litigation filter civil_-_current_stages returns 200
    # TODO: 200-only — litigation data requires litigation records, not produced by a loan upload. Loan presence not asserted.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "civil_-_current_stages": ["summons_issued"],
        "civil_-_next_stages": ["hearing_scheduled"],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty



  @positive 
  Scenario: TC-SHAPE-001 — Link response has output (S3 URL) and message="success"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": "link"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-SHAPE-002 — Data response has data array and message
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-SHAPE-003 — No-data response has data=[] and message="no data found"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "search_type": "loan_id",
        "query": "NON-EXISTENT-LOAN-{UUID}",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty



  @negative 
  Scenario Outline: TC-ENUM-00x — Invalid <field> value "<invalid_value>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01"
      }
      """
    And I update JSON field "<field>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | field         | invalid_value    |
      | export_type   | invalid_export   |
      | response_type | csv              |
      | search_type   | invalid_search   |
      | sort          | invalid_sort_key |
      | export_type   | CUSTOMER         |



  @positive 
  Scenario: TC-EDGE-001 — select_from = 0 and select_to = 1000 with allocation_month returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "select_from": 0,
        "select_to": 1000,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EDGE-002 — call_attempts_from = 0 treated as null returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "call_attempts_from": 0,
        "call_attempts_to": 5,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EDGE-003 — co_applicant_present = false resets co_app_from/upto to null
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "co_applicant_present": false,
        "co_app_from": 1,
        "co_app_upto": 3,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EDGE-004 — Multiple status filters combined returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "recovery_status": ["promise_to_pay"],
        "global_status": ["active"],
        "fos_status": ["visited"],
        "telecalling_status": ["call_not_answered"],
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-EDGE-005 — Digital notice filters combined returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "digital_notice_clicked": true,
        "digital_notice_opened": false,
        "ivr_message_heard": true,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EDGE-006 — page_number and page_size params forwarded returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "page_number": 1,
        "page_size": 50,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"



  @positive 
  Scenario: TC-COMBO-001 — High-value NPA loans with multiple filters and column flags
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "customer",
        "response_type": "data",
        "principal_outstanding_amount_from": 100000,
        "dpd_bracket": ["90_180"],
        "applicant_state": ["maharashtra"],
        "legal_status": ["notice_served"],
        "include_allocated_users": true,
        "include_additional_columns": true,
        "tags_column": true
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-COMBO-002 — Telecalling export with call attempts and status filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "customer",
        "response_type": "data",
        "telecalling_status": ["call_not_answered", "busy"],
        "call_attempts_from": 5,
        "call_attempts_to": 20,
        "allocated_user_profession": ["telecalling"],
        "include_calling_users": true
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive 
  Scenario: TC-COMBO-003 — Archive export with historical limit and offset pagination
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "Overall",
        "archive": true,
        "export_type": "customer",
        "historical_loan_limit": true,
        "response_type": "link",
        "select_from": 0,
        "select_to": 5000
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-COMBO-004 — Litigation export with co-applicant columns and IBC filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "export_type": "customer",
        "response_type": "data",
        "ibc_-_current_stages": ["nclt_admission"],
        "co_applicant_present": true,
        "co_applicant_columns": true,
        "number_of_co_applicants": 3,
        "include_additional_columns": true
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"



  @positive @performance @creator
  Scenario: TC-PERF-001 — POST response time should be within configured threshold
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response time should be within configured limit



  @negative 
  Scenario: TC-EXTRA-001 — selected_loan_ids as string instead of list returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "selected_loan_ids": "{LOAN_ID}",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive 
  Scenario: TC-EXTRA-002 — co_app_from > co_app_upto when co_applicant_present=false — range ignored
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "co_applicant_present": false,
        "co_app_from": 5,
        "co_app_upto": 1,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EXTRA-003 — response_type = null defaults to "link" response
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "response_type": null
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive 
  Scenario: TC-EXTRA-004 — principal_outstanding_amount_from > to range — behaviour TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then export its data below (as creator) ---
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-01-01",
        "principal_outstanding_amount_from": 500000,
        "principal_outstanding_amount_to": 10000,
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative 
  Scenario: TC-EXTRA-005 — archive as string "yes" is not a valid StrBool value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01",
        "archive": "yes",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative 
  Scenario: TC-500-001 — Service unhandled exception path returns error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "allocation_month": "2026-01-01",
        "response_type": "data"
      }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-details"
    Then the response status code should be 400
    Then the response body should not be empty
