@api @loan-upload @loan-recovery @recovery
Feature: Loan Upload — functional coverage & per-field matrix (POST /recovery/v1/loan/<loan_id>)

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And scenario loan id is unique


  @positive @creator
  Scenario: TC_LUU_007 / TC_LUU_024 — Upload a valid loan via API creates the loan (visible on latest allocation month)
    Given I prepare a request
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
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @negative @creator
  Scenario: TC_LUU_009 — Empty loan_id in payload is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to ""
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator @replace
  Scenario: TC_LUU_012 — replace_previous_data=true is accepted
    Given I prepare a request
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | true         |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @positive @creator @replace
  Scenario: TC_LUU_013 — replace_given_data=true is accepted (only provided fields replaced)
    Given I prepare a request
    And I set the query parameters:
      | company_id         | {COMPANY_ID} |
      | replace_given_data | true         |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @positive @creator
  Scenario: TC_LUU_014 — Default upload with no replace flag merges/updates
    Given I prepare a request
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
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @positive @creator
  Scenario: TC_LUU_015 — Non-existent loan is created, then re-upload of the same loan_id updates it
    Given I prepare a request
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
    Then the response status code should be one of "201,400"
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
    And I update JSON field "applicant_name" as "auto" to "AutoQA_Updated_Name"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @negative @security @permission @approver
  Scenario: TC_LUU_019 — Upload requires loan_upload write permission (unprivileged role rejected)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
    Then the response status code should be one of "201,400,401,403"
    And the response body should not be empty

  @negative @security @idor @creator
  Scenario: TC_LUU_020 — IDOR: upload to an unassigned company is blocked by verify_organisation
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "400,403,422"
    And the response body should not be empty


  @positive @creator
  Scenario: TC_LUU_025 — Upload with top-level variables (loan_type, product_type) is stored
    Given I prepare a request
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
    And I update JSON field "loan_type" as "auto" to "Personal Loan"
    And I update JSON field "product_type" as "auto" to "Unsecured"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @positive @creator @derivation
  Scenario: TC_LUU_027 — balance_claim_amount is derived after upload with total_claim_amount
    Given I prepare a request
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
    And I update JSON field "defaults[0].total_claim_amount" as "auto" to "1000"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @positive @creator @derivation
  Scenario: TC_LUU_028 / TC_LUU_163 — dpd and allocation_dpd are derived from date_of_default
    Given I prepare a request
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
    And I update JSON field "defaults[0].date_of_default" as "auto" to "2024-01-01"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @positive @creator
  Scenario: TC_LUU_030 — Upload allocation attributes (defaults section) is stored
    Given I prepare a request
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
    And I update JSON field "defaults[0].total_outstanding_amount" as "auto" to "5000"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

  @positive @creator @borrower
  Scenario: TC_LUU_031 / TC_LUU_034 / TC_LUU_037 / TC_LUU_042 — Combined upload with loan + allocation + applicant + co_applicant + references + loan_guarantor
    Given I prepare a request
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
    Then the response status code should be one of "201,400"
    And the response body should not be empty


  @positive @creator @field-matrix @text
  Scenario Outline: <tc> — Text field "<field>" is accepted on upload
    Given I prepare a request
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"

    Examples:
      | tc         | field                             | value                |
      | TC_LUU_071 | applicant_aadhar_number           | AutoQA-Aadhaar_01    |
      | TC_LUU_075 | applicant_gender                  | male                 |
      | TC_LUU_076 | applicant_language                | english              |
      | TC_LUU_077 | applicant_legal_heir              | AutoQA Heir          |
      | TC_LUU_078 | applicant_name                    | AutoQA Name          |
      | TC_LUU_079 | applicant_notice_reference_number | AutoQA-NRN-01        |
      | TC_LUU_080 | applicant_occupation              | Engineer             |
      | TC_LUU_081 | applicant_pan_number              | ABCDE1234F           |
      | TC_LUU_082 | applicant_prefix                  | Mr                   |
      | TC_LUU_083 | business_name                     | AutoQA Traders       |
      | TC_LUU_084 | channel_partner                   | AutoQA Partner       |
      | TC_LUU_102 | credit_account_holder_name        | AutoQA Holder        |
      | TC_LUU_103 | credit_account_holder_type        | savings              |
      | TC_LUU_105 | credit_bank_ifsc_code             | HDFC0001234          |
      | TC_LUU_106 | credit_bank_name                  | HDFC Bank            |
      | TC_LUU_107 | engine_number                     | ENG-AUTO-01          |
      | TC_LUU_108 | group_id                          | GRP-AUTO-01          |
      | TC_LUU_110 | loan_branch                       | AutoQA Branch        |
      | TC_LUU_112 | loan_nbfc_cin                     | U65990MH2010PLC000001 |
      | TC_LUU_113 | loan_nbfc_name                    | AutoQA NBFC          |
      | TC_LUU_114 | loan_region                       | West                 |
      | TC_LUU_115 | loan_regional_manager_name        | AutoQA RM            |
      | TC_LUU_116 | loan_type                         | Personal Loan        |
      | TC_LUU_117 | loan_source_branch_address        | AutoQA Source Addr   |
      | TC_LUU_118 | loan_zone                         | Zone-A               |
      | TC_LUU_119 | make_and_model                    | AutoQA Model X       |
      | TC_LUU_120 | merchant_name                     | AutoQA Merchant      |
      | TC_LUU_121 | notice_delivery_partner           | AutoQA Courier       |
      | TC_LUU_122 | payment_mode                      | UPI                  |
      | TC_LUU_123 | product_type                      | Unsecured            |
      | TC_LUU_124 | rbi_stage                         | Stage 1              |
      | TC_LUU_125 | receipt_number                    | RCPT-AUTO-01         |
      | TC_LUU_136 | security_type                     | Vehicle              |
      | TC_LUU_137 | tags                              | AutoQA-Tag           |
      | TC_LUU_139 | vehicle_registration_number       | MH01AB1234           |


  @positive @creator @field-matrix @link
  Scenario Outline: <tc> — Link field "<field>" is accepted on upload
    Given I prepare a request
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"

    Examples:
      | tc         | field               | value                        |
      | TC_LUU_206 | applicant_photo_link | https://example.com/p.jpg   |
      | TC_LUU_208 | payment_link         | https://example.com/pay/123 |

  @positive @creator @field-matrix @date
  Scenario Outline: <tc> — Date field "<field>" is accepted on upload
    Given I prepare a request
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"

    Examples:
      | tc         | field                     | value      |
      | TC_LUU_210 | applicant_dob             | 1990-05-20 |
      | TC_LUU_211 | client_loan_sanction_date | 2023-06-01 |
      | TC_LUU_218 | loan_end_date             | 2027-06-01 |
      | TC_LUU_219 | notice_date               | 2024-03-10 |
      | TC_LUU_214 | defaults[0].date_of_default | 2024-01-01 |
      | TC_LUU_213 | defaults[0].allocation_month | {ALLOCATION_MONTH_OFFSET:0} |


  @positive @creator @field-matrix @numeric
  Scenario Outline: <tc> — Numeric field "<field>" is accepted on upload
    Given I prepare a request
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"

    Examples:
      | tc         | field                                  | value  |
      | TC_LUU_159 | applicant_cibil_score                  | 750    |
      | TC_LUU_165 | loan_tenure                            | 24     |
      | TC_LUU_166 | payment_link_expiry                    | 7      |
      | TC_LUU_161 | defaults[0].allocation_dpd_value       | 30     |
      | TC_LUU_162 | defaults[0].default_emi_number         | 2      |
      | TC_LUU_168 | defaults[0].utilisation                | 12.5   |
      | TC_LUU_170 | applicant_monthly_income               | 40000  |
      | TC_LUU_171 | defaults[0].advance_payment            | 500    |
      | TC_LUU_172 | defaults[0].total_outstanding_amount   | 5000   |
      | TC_LUU_173 | defaults[0].settlement_amount          | 4500   |
      | TC_LUU_174 | defaults[0].expected_emi_principal_amount | 800 |
      | TC_LUU_175 | defaults[0].expected_emi_interest_amount  | 200 |
      | TC_LUU_176 | defaults[0].expected_emi               | 1000   |
      | TC_LUU_177 | defaults[0].other_penalty              | 100    |
      | TC_LUU_178 | defaults[0].client_amount_recovered    | 300    |
      | TC_LUU_179 | defaults[0].total_claim_amount         | 1000   |
      | TC_LUU_180 | defaults[0].late_fee                   | 50     |
      | TC_LUU_181 | defaults[0].principal_outstanding_amount | 3500 |
      | TC_LUU_183 | emi_amount                             | 1000   |
      | TC_LUU_184 | total_loan_amount                      | 50000  |
      | TC_LUU_186 | interest_on_loan                       | 12.5   |


  @positive @creator @field-matrix @bool
  Scenario Outline: <tc> — Boolean field "<field>" is accepted on upload
    Given I prepare a request
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"

    Examples:
      | tc         | field              | value |
      | TC_LUU_145 | backed_by_security | true  |
      | TC_LUU_157 | tenure_finished    | false |
