@api @internal-bulk-loans @recovery
Feature: Internal Bulk Loans fetch — POST /recovery/internal/bulk/loans



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
  Scenario: Fetch the uploaded loan with an attribute level returns it in variable_data
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/internal_bulk_loans_success_schema.json"
    And the internal bulk loans success response should be valid
    And the internal bulk loans response should contain loan "{LOAN_ID}"

  @positive @creator
  Scenario: All optional fields populated returns the loan
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "source": "frontend",
        "allocation_month": "2026-6-01",
        "attribute_levels": ["applicant", "loan_variables", "allocation_details", "payments"],
        "attribute_variables": ["loan_amount", "applicant_name"],
        "audit_info": true,
        "nested_audit_info": true,
        "id_info": true,
        "data_type_conversion": true,
        "apply_transform": true,
        "trigger": "automation_full"
      }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/internal_bulk_loans_success_schema.json"
    And the internal bulk loans response should contain loan "{LOAN_ID}"

  @positive @creator
  Scenario: attribute_variables only (no attribute_levels) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_variables": ["loan_amount", "applicant_name"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @positive @creator
  Scenario: All boolean flags true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "attribute_levels": ["applicant"],
        "audit_info": true,
        "nested_audit_info": true,
        "id_info": true,
        "data_type_conversion": true,
        "apply_transform": true
      }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @positive @creator
  Scenario: All boolean flags false (explicit) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "attribute_levels": ["applicant"],
        "audit_info": false,
        "nested_audit_info": false,
        "id_info": false,
        "data_type_conversion": false,
        "apply_transform": false
      }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @positive @creator
  Scenario: Valid allocation_month (single-digit month, no leading zero) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "allocation_month": "2026-6-01" }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @negative @boundary @creator
  Scenario: Two-digit allocation_month is a valid format but the loan is not allocated there (REC_0007)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "allocation_month": "2026-12-01" }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans error code should be "REC_0007"

  @positive @creator
  Scenario: All attribute_levels members in one request returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "attribute_levels": [
          "applicant", "co_applicants", "references", "guarantors",
          "document_details", "loan_additional_variables", "loan_variables",
          "loan_statuses", "allocation_statuses", "applicant_addresses",
          "allocation_variables", "allocation_additional_variables",
          "payments", "tags", "ds_variables", "allocation_details"
        ]
      }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/internal_bulk_loans_success_schema.json"

  @positive @creator
  Scenario: attribute_levels accepted case-insensitively (uppercase coerced) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["APPLICANT", "Loan_Variables"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @positive @creator
  Scenario: Unknown body field is silently dropped (extra="ignore") returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "totally_unknown_field": "dropped", "another": 123 }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @positive @creator
  Scenario: Whitespace-padded loan_id is stripped (anystr_strip_whitespace) returns the loan
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["  {LOAN_ID}  "], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200
    And the internal bulk loans response should contain loan "{LOAN_ID}"

  @positive @creator
  Scenario: Duplicate loan_ids entries are tolerated returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}", "{LOAN_ID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200
    And the internal bulk loans response should contain loan "{LOAN_ID}"

  @positive @creator
  Scenario: Combined — full collections export returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "source": "frontend",
        "allocation_month": "2026-6-01",
        "attribute_levels": ["applicant", "loan_variables", "allocation_details", "payments"],
        "audit_info": true,
        "id_info": true
      }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @positive @creator
  Scenario: Combined — calling view with transforms returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "source": "calling",
        "attribute_levels": ["applicant", "co_applicants", "applicant_addresses", "loan_statuses"],
        "data_type_conversion": true,
        "apply_transform": true,
        "trigger": "calling_dashboard"
      }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @positive @creator
  Scenario: Combined — litigation with nested audit returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "source": "litigation",
        "allocation_month": "2026-6-01",
        "attribute_levels": ["applicant", "guarantors", "references"],
        "attribute_variables": ["case_number", "court_name"],
        "nested_audit_info": true,
        "audit_info": true,
        "id_info": true
      }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

  @positive @creator
  Scenario Outline: Each source enum value "<source>" is accepted (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "source": "<source>" }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

    Examples:
      | source        |
      | notice        |
      | workflow      |
      | frontend      |
      | litigation    |
      | communication |
      | calling       |
      | fos           |
      | fos_app       |
      | unknown       |
      | settlement    |
      | scrape        |
      | approval      |

  @positive @creator
  Scenario Outline: Each attribute_levels member "<level>" is accepted (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["<level>"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200

    Examples:
      | level                            |
      | applicant                        |
      | co_applicants                    |
      | references                       |
      | guarantors                       |
      | document_details                 |
      | loan_additional_variables        |
      | loan_variables                   |
      | loan_statuses                    |
      | allocation_statuses              |
      | applicant_addresses              |
      | allocation_variables             |
      | allocation_additional_variables  |
      | payments                         |
      | tags                             |
      | ds_variables                     |
      | allocation_details               |

  @positive @creator @multistep
  Scenario: Upload then read back asserts the loan is returned with id_info
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "id_info": true }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200
    And the internal bulk loans response should contain loan "{LOAN_ID}"
    And the response body should contain text "{LOAN_ID}"


  @negative @creator
  Scenario: Request without attribute_levels or attribute_variables returns 400 (REC_0002)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans error code should be "REC_0002"

  @negative @creator
  Scenario: Non-existent valid-format loan_id returns 400 (REC_0007)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["NON-EXISTENT-{UUID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans error code should be "REC_0007"

  @positive @creator
  Scenario: Mixed existing + non-existent loan_ids returns 200 (unknown ids ignored, valid loan returned)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}", "NON-EXISTENT-{UUID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 200
    And the internal bulk loans response should contain loan "{LOAN_ID}"

  @negative @creator @fuzz
  Scenario: Fuzz random loan_id is well-formed but unknown returns 400 (REC_0007)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LN_{RANDOM_STRING:12}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans error code should be "REC_0007"

  @negative @creator
  Scenario Outline: loan_id containing forbidden character "<ch>" is rejected (REC_0007)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["loan<ch>001"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans error code should be "REC_0007"

    Examples:
      | ch |
      | '  |
      | ;  |
      | %  |
      | ~  |



  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
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
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
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
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id (org context unresolved) is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
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
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @approver
  Scenario: Approver reaches the loan lookup (no permission submodule blocks the role)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["NON-EXISTENT-{UUID}"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans error code should be "REC_0007"


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
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: loan_ids present but null returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": null }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans validation error should be valid

  @negative @creator
  Scenario: loan_ids empty list returns 400 (min_items=1, REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": [] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans validation error should be valid

  @negative @boundary @creator
  Scenario: loan_ids over max (51 items) returns 400 (max_items=50, REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["L1","L2","L3","L4","L5","L6","L7","L8","L9","L10","L11","L12","L13","L14","L15","L16","L17","L18","L19","L20","L21","L22","L23","L24","L25","L26","L27","L28","L29","L30","L31","L32","L33","L34","L35","L36","L37","L38","L39","L40","L41","L42","L43","L44","L45","L46","L47","L48","L49","L50","L51"], "attribute_levels": ["applicant"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans validation error should be valid

  @negative @creator
  Scenario Outline: loan_ids with wrong type "<case>" returns 400 (REC_0003)
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
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans validation error should be valid

    Examples:
      | case            | body                                                          |
      | string not list | { "loan_ids": "loan_001", "attribute_levels": ["applicant"] } |
      | integer         | { "loan_ids": 12345, "attribute_levels": ["applicant"] }      |
      | object          | { "loan_ids": {}, "attribute_levels": ["applicant"] }         |

  @negative @creator
  Scenario: source invalid enum string returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "source": "not_a_real_source" }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans validation error should be valid

  @negative @creator
  Scenario: source as a JSON integer triggers an unhandled error (500, REC_0004)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "source": 5 }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 500
    And the internal bulk loans error code should be "REC_0004"

  @negative @creator
  Scenario: attribute_levels invalid member returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant", "bogus_level"] }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans validation error should be valid

  @negative @creator
  Scenario: Invalid boolean value for audit_info returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "audit_info": "maybe" }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans validation error should be valid

  @negative @creator
  Scenario Outline: allocation_month bad format "<allocation_month>" returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "attribute_levels": ["applicant"], "allocation_month": "<allocation_month>" }
      """
    When I send a "POST" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 400
    And the internal bulk loans validation error should be valid

    Examples:
      | allocation_month | # reason                                  |
      | 01-12-2026       | # DD-MM-YYYY instead of YYYY-M-01          |
      | 2026-13-01       | # month out of range                      |
      | 2026-6-15        | # day must be 01                          |
      | 2026-06-01       | # leading-zero month not allowed by regex |
      | 2026/6/01        | # wrong separators                        |
      | notadate         | # non-date string                         |



  @negative @creator
  Scenario: GET on the bulk loans endpoint is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    When I send a "GET" request to "/recovery/internal/bulk/loans"
    Then the response status code should be 405
