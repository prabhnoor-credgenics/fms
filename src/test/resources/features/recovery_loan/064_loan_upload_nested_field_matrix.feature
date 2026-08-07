@api @loan-upload @loan-recovery @recovery @nested-field-matrix
Feature: Loan Upload — nested borrower sub-field matrix (POST /recovery/v1/loan/<loan_id>)

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"



  @positive @creator @field-matrix @text
  Scenario Outline: <tc> — Nested text sub-field "<field>" is accepted on upload
    Given scenario loan id is unique
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

    Examples:
      | tc         | field                                                                            | value              |
      | TC_LUU_073 | applicant_contact_details[0].applicant_contact_number_type                       | mobile             |
      | TC_LUU_074 | applicant_email_details[0].applicant_email_type                                  | personal           |
      | TC_LUU_086 | co_applicant[0].co_applicant_type                                                | spouse             |
      | TC_LUU_087 | co_applicant[0].co_applicant_gender                                              | female             |
      | TC_LUU_088 | co_applicant[0].co_applicant_language                                            | hindi              |
      | TC_LUU_089 | co_applicant[0].co_applicant_pan_number                                          | ABCPX1234Z         |
      | TC_LUU_090 | co_applicant[0].co_applicant_address[0].co_applicant_address_latitude            | 28.6139            |
      | TC_LUU_091 | co_applicant[0].co_applicant_address[0].co_applicant_address_longitude           | 77.2090            |
      | TC_LUU_092 | co_applicant[0].co_applicant_address[0].co_applicant_address_type                | permanent          |
      | TC_LUU_093 | co_applicant[0].co_applicant_address[0].co_applicant_address_text                | 12 AutoQA Street   |
      | TC_LUU_094 | co_applicant[0].co_applicant_address[0].co_applicant_city                        | Pune               |
      | TC_LUU_095 | co_applicant[0].co_applicant_address[0].co_applicant_state                       | Maharashtra        |
      | TC_LUU_096 | co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_type | mobile             |
      | TC_LUU_097 | co_applicant[0].co_applicant_email_details[0].co_applicant_email_type            | personal           |
      | TC_LUU_098 | co_applicant[0].co_applicant_notice_reference_number                             | NOTICE-CA-001      |
      | TC_LUU_099 | co_applicant[0].co_applicant_name                                                | AutoQA CoApplicant |
      | TC_LUU_100 | co_applicant[0].co_applicant_legal_heir                                          | AutoQA Heir        |
      | TC_LUU_101 | co_applicant[0].co_applicant_prefix                                              | Mrs                |
      | TC_LUU_126 | references[0].reference_contact_details[0].reference_contact_number_type         | mobile             |
      | TC_LUU_127 | references[0].name                                                               | AutoQA Reference   |
      | TC_LUU_128 | references[0].reference_gender                                                   | male               |
      | TC_LUU_129 | references[0].reference_pan_number                                               | LMNPX5678Q         |
      | TC_LUU_130 | references[0].reference_address[0].reference_address_type                        | current            |
      | TC_LUU_131 | references[0].reference_address[0].reference_address_text                        | 44 Reference Road  |
      | TC_LUU_132 | references[0].reference_address[0].reference_city                                | Nagpur             |
      | TC_LUU_133 | references[0].reference_address[0].reference_state                               | Maharashtra        |
      | TC_LUU_134 | references[0].relation_with_applicant                                            | brother            |
      | TC_LUU_135 | references[0].reference_email_details[0].reference_email_type                    | work               |
      | TC_LUU_104 | credit_account_number                                                            | CRD-AUTO-0001      |


  @positive @creator @field-matrix @bool
  Scenario Outline: <tc> — Nested boolean sub-field "<field>" is accepted on upload
    Given scenario loan id is unique
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

    Examples:
      | tc         | field                                                                                       | value |
      | TC_LUU_141 | applicant_contact_details[0].applicant_contact_number_is_valid                              | true  |
      | TC_LUU_142 | applicant_contact_details[0].applicant_contact_number_is_active                             | true  |
      | TC_LUU_143 | applicant_email_details[0].applicant_email_is_valid                                         | true  |
      | TC_LUU_144 | applicant_email_details[0].applicant_email_is_active                                        | false |
      | TC_LUU_146 | co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid        | true  |
      | TC_LUU_147 | co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active       | false |
      | TC_LUU_148 | co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid                   | true  |
      | TC_LUU_149 | co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active                  | false |
      | TC_LUU_150 | loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid  | true  |
      | TC_LUU_151 | loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active | false |
      | TC_LUU_152 | loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active            | true  |
      | TC_LUU_153 | references[0].reference_contact_details[0].reference_contact_number_is_valid                | true  |
      | TC_LUU_154 | references[0].reference_contact_details[0].reference_contact_number_is_active               | false |
      | TC_LUU_155 | references[0].reference_email_details[0].reference_email_is_valid                           | true  |
      | TC_LUU_156 | references[0].reference_email_details[0].reference_email_is_active                          | false |


  @positive @creator @field-matrix @mobile
  Scenario Outline: <tc> — Nested mobile number sub-field "<field>" is accepted on upload
    Given scenario loan id is unique
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

    Examples:
      | tc         | field                                                                             | value      |
      | TC_LUU_188 | applicant_contact_details[0].applicant_contact_number                             | 9812345670 |
      | TC_LUU_189 | co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number       | 9812345671 |
      | TC_LUU_190 | loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number | 9812345672 |
      | TC_LUU_191 | loan_regional_manager_contact_number                                              | 9812345673 |
      | TC_LUU_192 | references[0].reference_contact_details[0].contact_number                         | 9812345674 |


  @positive @creator @field-matrix @email
  Scenario Outline: <tc> — Nested email address sub-field "<field>" is accepted on upload
    Given scenario loan id is unique
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

    Examples:
      | tc         | field                                                                  | value                        |
      | TC_LUU_194 | applicant_email_details[0].applicant_email                             | autoqa.applicant@example.com |
      | TC_LUU_195 | co_applicant[0].co_applicant_email_details[0].co_applicant_email       | autoqa.coapp@example.com     |
      | TC_LUU_196 | loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email | autoqa.guarantor@example.com |
      | TC_LUU_197 | loan_regional_manager_contact_email                                    | autoqa.rm@example.com        |
      | TC_LUU_198 | references[0].reference_email_details[0].reference_email               | autoqa.reference@example.com |


  @positive @creator @field-matrix @pincode
  Scenario Outline: <tc> — Nested pincode sub-field "<field>" is accepted on upload
    Given scenario loan id is unique
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

    Examples:
      | tc         | field                                                              | value  |
      | TC_LUU_200 | applicant_address[0].applicant_pincode                             | 411001 |
      | TC_LUU_201 | co_applicant[0].co_applicant_address[0].co_applicant_pincode       | 411002 |
      | TC_LUU_202 | loan_guarantor[0].loan_guarantor_address[0].loan_guarantor_pincode | 411003 |
      | TC_LUU_203 | references[0].reference_address[0].reference_pincode               | 411004 |
      | TC_LUU_204 | document_details[0].document_signature_pincode                     | 411005 |


  @positive @creator @field-matrix @link
  Scenario Outline: <tc> — Nested link sub-field "<field>" is accepted on upload
    Given scenario loan id is unique
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

    Examples:
      | tc         | field                                   | value                         |
      | TC_LUU_207 | co_applicant[0].co_applicant_photo_link | https://example.com/coapp.png |


  @positive @creator @field-matrix @date
  Scenario Outline: <tc> — Nested date sub-field "<field>" is accepted on upload
    Given scenario loan id is unique
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

    Examples:
      | tc         | field                                         | value      |
      | TC_LUU_212 | co_applicant[0].co_applicant_dob              | 1990-05-14 |
      | TC_LUU_215 | document_details[0].document_date             | 2025-01-15 |
      | TC_LUU_216 | document_details[0].document_dishonour_date   | 2025-02-15 |
      | TC_LUU_217 | document_details[0].document_bounce_memo_date | 2025-02-20 |


  @positive @creator @field-matrix @number
  Scenario Outline: <tc> — Nested number sub-field "<field>" is accepted on upload
    Given scenario loan id is unique
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
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201,400"
    And the response body should not be empty

    Examples:
      | tc         | field                                                   | value        |
      | TC_LUU_164 | document_details[0].document_bounce_bank_account_number | 123456789012 |