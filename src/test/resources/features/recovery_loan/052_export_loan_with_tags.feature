@api @export-loan-with-tags @recovery
Feature: Export Loan With Tags — POST /recovery/export/bulk/loan-with-tags


  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And scenario loan id is unique
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
    Then the response status code should be 201


  @positive @smoke @creator
  Scenario: Minimal {} (defaults, link mode) returns 200
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
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @positive @creator
  Scenario: tags_column=true, response_type=link returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": true, "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @positive @creator
  Scenario: tags_column=true, response_type=data returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/export_loan_data_success_schema.json"
    And the export loan with tags success response should be valid

  @positive @creator
  Scenario Outline: tags_column "<tags>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": <tags>, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

    Examples:
      | tags  |
      | true  |
      | false |

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
      { "selected_loan_ids": ["{LOAN_ID}"], "tags_column": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @negative @creator
  Scenario: Enabling all column toggles together errors on staging (500)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": true, "include_allocated_users": true, "include_fos_users": true, "include_calling_users": true, "include_additional_columns": true, "include_derivable_variables": true, "inc_doc_links": true, "co_applicant_columns": true, "doc_detail_columns": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 500
    And the response body should not be empty

  @positive @creator
  Scenario: All column toggles false (explicit) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": false, "include_allocated_users": false, "include_fos_users": false, "include_calling_users": false, "include_additional_columns": false, "include_derivable_variables": false, "inc_doc_links": false, "co_applicant_columns": false, "doc_detail_columns": false, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @positive @creator
  Scenario: Column-count overrides returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": true, "number_of_applicant_addresses": 2, "number_of_references": 3, "number_of_co_applicants": 4, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @positive @creator
  Scenario: historical_loan_limit=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": true, "historical_loan_limit": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @positive @creator
  Scenario Outline: allocation_month "<month>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocation_month": "<month>", "tags_column": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

    Examples:
      | month      |
      | 2026-01-01 |
      | overall    |

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
      { "archive": "<archive>", "tags_column": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

    Examples:
      | archive |
      | true    |
      | false   |

  @positive @creator
  Scenario: Search by search_type + query returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "search_type": "loan_id", "query": "{LOAN_ID}", "tags_column": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @positive @creator
  Scenario Outline: export_type "<export_type>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "export_type": "<export_type>", "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

    Examples:
      | export_type                |
      | customer                   |
      | transaction                |
      | allocated_users            |
      | portfolio_allocated_users  |
      | portfolio_data             |
      | portfolio_transaction_data |
      | bulk_document_download     |

  @positive @creator
  Scenario: Pagination returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": true, "page_number": 2, "page_size": 100, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @positive @creator
  Scenario: Range selection with deselected returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": true, "select_from": 1, "select_to": 500, "deselected": ["LOAN0009"], "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 200
    And the export loan with tags success response should be valid

  @negative @creator
  Scenario: export_id referencing a non-existent export task returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | export_id  | 3002         |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "tags_column": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 400
    And the export loan with tags failure response should be valid

  @negative @creator
  Scenario: Extra portfolio filter fields error on the export (500)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocation_month": "2026-01-01", "recovery_status": ["promise_to_pay"], "state": ["maharashtra"], "tags_column": true, "response_type": "data" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 500
    And the response body should not be empty

  @negative @creator
  Scenario: Combined export with include_additional_columns errors on staging (500)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocation_month": "2026-01-01", "selected_loan_ids": ["{LOAN_ID}"], "tags_column": true, "include_allocated_users": true, "include_additional_columns": true, "response_type": "link" }
      """
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 500
    And the response body should not be empty


  @negative @creator
  Scenario Outline: Invalid body "<case>" returns 400
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
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 400
    And the export loan with tags failure response should be valid

    Examples:
      | case                  | body                       |
      | invalid export_type   | { "export_type": "bogus" } |
      | invalid response_type | { "response_type": "xml" } |
      | invalid sort          | { "sort": "bogus_sort" }   |


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
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
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
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
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
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
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
    When I send a "POST" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: GET on the loan-with-tags export endpoint is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/export/bulk/loan-with-tags"
    Then the response status code should be 405
