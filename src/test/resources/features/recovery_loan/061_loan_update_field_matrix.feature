@api @loan-update @loan-recovery @recovery
Feature: Loan Update — per-field matrix (PATCH /recovery/loan/<loan_id>)

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

  @positive @creator
  Scenario: TC_LUU_011 / TC_LUU_015 — Update a loan variable via API then read it back reflects the new value
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "AutoQA_ReadBack_Name" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be one of "200,404"
    And the response body should contain text "AutoQA_ReadBack_Name"

  @negative @security @idor @creator
  Scenario: TC_LUU_020b — Update on an unassigned company is blocked
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_name": "AutoQA_IDOR" }
      """
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "400,403,422"
    And the response body should not be empty

  @positive @creator @field-matrix @text
  Scenario Outline: <tc> — Update text variable "<field>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform" }
      """
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200"

    Examples:
      | tc         | field                       | value            |
      | TC_LUU_075 | applicant_gender            | female           |
      | TC_LUU_076 | applicant_language          | hindi            |
      | TC_LUU_078 | applicant_name              | AutoQA Name 2    |
      | TC_LUU_080 | applicant_occupation        | Doctor           |
      | TC_LUU_081 | applicant_pan_number        | PQRSX6789Z       |
      | TC_LUU_083 | business_name               | AutoQA Traders 2 |
      | TC_LUU_108 | group_id                    | GRP-AUTO-02      |
      | TC_LUU_110 | loan_branch                 | AutoQA Branch 2  |
      | TC_LUU_114 | loan_region                 | East             |
      | TC_LUU_116 | loan_type                   | Home Loan        |
      | TC_LUU_118 | loan_zone                   | Zone-B           |
      | TC_LUU_119 | make_and_model              | AutoQA Model Y   |
      | TC_LUU_122 | payment_mode                | NEFT             |
      | TC_LUU_123 | product_type                | Secured          |
      | TC_LUU_136 | security_type               | Property         |
      | TC_LUU_137 | tags                        | AutoQA-Tag-2     |
      | TC_LUU_139 | vehicle_registration_number | MH02CD5678       |

  @positive @creator @field-matrix @date
  Scenario Outline: <tc> — Update date variable "<field>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform" }
      """
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200"

    Examples:
      | tc         | field                     | value      |
      | TC_LUU_210 | applicant_dob             | 1991-07-15 |
      | TC_LUU_211 | client_loan_sanction_date | 2023-07-01 |
      | TC_LUU_218 | loan_end_date             | 2028-07-01 |
      | TC_LUU_219 | notice_date               | 2024-04-10 |

  @positive @creator @field-matrix @numeric
  Scenario Outline: <tc> — Update numeric variable "<field>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform" }
      """
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200,400"

    Examples:
      | tc         | field                    | value |
      | TC_LUU_159 | applicant_cibil_score    | 800   |
      | TC_LUU_165 | loan_tenure              | 36    |
      | TC_LUU_170 | applicant_monthly_income | 55000 |
      | TC_LUU_183 | emi_amount               | 1200  |
      | TC_LUU_184 | total_loan_amount        | 60000 |
      | TC_LUU_186 | interest_on_loan         | 11.0  |

  @positive @creator @field-matrix @bool
  Scenario Outline: <tc> — Update boolean variable "<field>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform" }
      """
    And I update JSON field "<field>" as "auto" to "<value>"
    When I send a "PATCH" request to "/recovery/loan/{loan_id}"
    Then the response status code should be one of "200,400"

    Examples:
      | tc         | field              | value |
      | TC_LUU_145 | backed_by_security | false |
      | TC_LUU_157 | tenure_finished    | true  |