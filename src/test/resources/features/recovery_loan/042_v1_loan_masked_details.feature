@api @v1-loan-masked @recovery
Feature: V1 Loan masked details — GET /recovery/v1/loans/<loan_id>



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
    And I update JSON field "applicant_name" to "MaskProbeName"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201


  @positive @smoke @creator
  Scenario: GET the uploaded loan with an attribute level returns it in variable_data
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/v1_loan_masked_details_success_schema.json"
    And the v1 loan details success response should be valid
    And the v1 loan details response should contain loan "{LOAN_ID}"

  @positive @masking @creator
  Scenario: PII masking is config-dependent — not applied for this test company (raw value returned)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the v1 loan details response should contain loan "{LOAN_ID}"
    And the response body should contain text "MaskProbeName"

  @positive @creator
  Scenario: All optional query params populated returns the loan
    Given I prepare a request
    And I set the query parameters:
      | company_id          | {COMPANY_ID}                                          |
      | source              | frontend                                              |
      | allocation_month    | {ALLOCATION_MONTH_OFFSET:0}                                            |
      | attribute_levels    | applicant,loan_variables,allocation_details,payments  |
      | attribute_variables | loan_amount,applicant_name                            |
      | audit_info          | true                                                  |
      | nested_audit_info   | true                                                  |
      | id_info             | true                                                  |
      | data_type_conversion| true                                                  |
      | apply_transform     | true                                                  |
      | trigger             | automation_full                                       |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the v1 loan details response should contain loan "{LOAN_ID}"

  @positive @creator
  Scenario: attribute_variables only (comma-separated) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id          | {COMPANY_ID}               |
      | attribute_variables | loan_amount,applicant_name |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: All boolean flags true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id           | {COMPANY_ID} |
      | attribute_levels     | applicant    |
      | audit_info           | true         |
      | nested_audit_info    | true         |
      | id_info              | true         |
      | data_type_conversion | true         |
      | apply_transform      | true         |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: All boolean flags false (explicit) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id           | {COMPANY_ID} |
      | attribute_levels     | applicant    |
      | audit_info           | false        |
      | nested_audit_info    | false        |
      | id_info              | false        |
      | data_type_conversion | false        |
      | apply_transform      | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: Valid allocation_month (single-digit month, no leading zero) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}   |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: All attribute_levels members (comma-separated) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                                                                                                                                            |
      | attribute_levels | applicant,co_applicants,references,guarantors,document_details,loan_additional_variables,loan_variables,loan_statuses,allocation_statuses,applicant_addresses,allocation_variables,allocation_additional_variables,payments,tags,ds_variables,allocation_details |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/v1_loan_masked_details_success_schema.json"

  @positive @creator
  Scenario: attribute_levels accepted case-insensitively (uppercase coerced) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}            |
      | attribute_levels | APPLICANT,Loan_Variables |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: Unknown query param is silently dropped (extra="ignore") returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id           | {COMPANY_ID} |
      | attribute_levels     | applicant    |
      | totally_unknown_param| dropped      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: Duplicate attribute_levels entries are tolerated returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                  |
      | attribute_levels | applicant,applicant,applicant |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario Outline: Each source enum value "<source>" is accepted (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
      | source           | <source>     |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
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
      | company_id       | {COMPANY_ID} |
      | attribute_levels | <level>      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
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


  @negative @creator
  Scenario: No attribute selector (path only) returns 400 (REC_0002)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details error code should be "REC_0002"

  @negative @creator
  Scenario: Empty attribute_levels query value returns 400 (coerced to None → no selector)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels |              |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details error code should be "REC_0002"

  @negative @creator
  Scenario: Non-existent valid-format loan_id returns 400 (REC_0007)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | NONEXISTENT{RANDOM_STRING:10} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details error code should be "REC_0007"


  @negative @creator
  Scenario: source invalid enum value returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}      |
      | attribute_levels | applicant         |
      | source           | not_a_real_source |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details validation error should be valid

  @negative @creator
  Scenario: source as a numeric string is an invalid enum returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
      | source           | 5            |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details validation error should be valid

  @negative @creator
  Scenario: attribute_levels invalid member returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}        |
      | attribute_levels | applicant,bogus_level |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details validation error should be valid

  @negative @creator
  Scenario: Invalid boolean value for audit_info returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
      | audit_info       | maybe        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details validation error should be valid

  @negative @creator
  Scenario Outline: allocation_month bad format "<allocation_month>" returns 400 (REC_0003)
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID}       |
      | attribute_levels | applicant          |
      | allocation_month | <allocation_month> |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details validation error should be valid

    Examples:
      | allocation_month | # reason                                  |
      | 01-12-2026       | # DD-MM-YYYY instead of YYYY-M-01          |
      | 2026-13-01       | # month out of range                      |
      | 2026-6-15        | # day must be 01                          |
      | 2026-06-01       | # leading-zero month not allowed by regex |
      | notadate         | # non-date string                         |


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id (org context unresolved) is rejected
    Given I prepare a request
    And I set the query parameters:
      | attribute_levels | applicant |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {UUID}    |
      | attribute_levels | applicant |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @approver
  Scenario: Approver reaches the loan lookup (no permission submodule blocks the role)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | NONEXISTENT{RANDOM_STRING:10} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the v1 loan details error code should be "REC_0007"



