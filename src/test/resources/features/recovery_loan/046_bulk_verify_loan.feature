@api @bulk-verify-loan @recovery
Feature: Bulk Verify Loan — POST /recovery/bulk/verify-loan


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
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201


  @positive @smoke @creator
  Scenario: Minimal (company_id + loan_ids) returns 200 with verified/non-verified split
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/bulk_verify_loan_success_schema.json"
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: Multiple loan_ids returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}", "OTHER-LOAN-1", "OTHER-LOAN-2"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: allocation_month "Overall" verifies the uploaded loan across all months
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"], "allocation_month": "Overall" }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"

  @positive @creator
  Scenario: Specific allocation_month returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"], "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}" }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: archive=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"], "archive": true }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: archive=false (explicit) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"], "archive": false }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: Duplicate loan_ids are tolerated returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}", "{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: A non-existent id lands in non_verified (still 200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["NON-EXISTENT-{UUID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: Sibling route /bulk/verify-customer returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-customer"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: Combined — month + archive + many ids returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}", "L2", "L3", "L4", "L5"], "allocation_month": "Overall", "archive": false }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @positive @creator
  Scenario: Body company_id different from session is ignored (session company used) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{UUID}", "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid


  @negative @creator
  Scenario: Empty body {} returns 400
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
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 400
    And the "bulk_verify_loan" failure response should be valid

  @negative @creator
  Scenario Outline: Invalid request "<case>" returns 400
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
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 400
    And the "bulk_verify_loan" failure response should be valid

    Examples:
      | case                     | body                                                      |
      | company_id absent        | { "loan_ids": ["{LOAN_ID}"] }                             |
      | company_id non-uuid      | { "company_id": "not-a-uuid", "loan_ids": ["{LOAN_ID}"] } |
      | company_id null          | { "company_id": null, "loan_ids": ["{LOAN_ID}"] }         |
      | loan_ids absent          | { "company_id": "{COMPANY_ID}" }                          |
      | loan_ids empty list      | { "company_id": "{COMPANY_ID}", "loan_ids": [] }          |
      | loan_ids null            | { "company_id": "{COMPANY_ID}", "loan_ids": null }        |
      | loan_ids string not list | { "company_id": "{COMPANY_ID}", "loan_ids": "L1" }        |


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
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
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json                                 |
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator
  Scenario: Missing company_id query param still resolves via session — returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 200
    And the "bulk_verify_loan" success response should be valid

  @negative @creator
  Scenario: Unknown (random UUID) company_id query param is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: GET on the bulk verify-loan endpoint is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/bulk/verify-loan"
    Then the response status code should be 405

