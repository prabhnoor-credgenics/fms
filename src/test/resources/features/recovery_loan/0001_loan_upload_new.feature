@api @loan-recovery @datatype-validation
Feature: Loan Upload

  Background: 
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  @positive @smoke
  Scenario: Verify loan uplaod through quick upload
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"

  @negative
  Scenario: Verify loan_id in path must match the loan_id in payload
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_id" as "auto" to "950"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    # how to update loan id in request body
    And the response body should contain field "message" as "string" with value "loan_id provided in parameter and payload should be same."
    And the response body should contain field "message_template" as "string" with value "loan_id provided in parameter and payload should be same."

  @negative
  Scenario: Verify missing loan id key in payload is rejected
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload_loanId_key_Missing.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    #   And the response body should contain field "success" as "boolean" with value false
    And the response body should contain field "message" as "string" with value "loan_id missing in payload"
    And the response body should contain field "message_template" as "string" with value "loan_id missing in payload"

  @positive @smoke
  Scenario: Verify loan update
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_update.json"
    And I update JSON field "applicant_cibil_score" as "auto" to "950"
    When I send a "PATCH" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data updated successfully"
    And the response body should contain field "message_template" as "string" with value "Data updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.loan_details.applicant_cibil_score" as "integer" with value "950"

  @positive
  Scenario: Verify loan upload with replace_previous_data=true.
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | true         |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_upload_replace_previous_data_true.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    #   And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "applicant_dob" as "null" with value "null"
    And the response body should contain field "applicant_cibil_score" as "null" with value "null"
    And the response body should contain field "applicant_aadhar_number" as "string" with value ""
    And the response body should contain field "credit_bank_ifsc_code" as "string" with value "IFSC9087871"

  @negative
  Scenario: Verify invalid loan id path parameter is rejected
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | invalid_loan** |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_id" as "auto" to "invalid_loan**"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    # how to update loan id in request body
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"

  @negative
  Scenario: Verify IDOR - cannot upload to an unassigned company
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | fe971a70-40dc-4e9d-ba21-c0b6ee8579f3 |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 401
    # how to update loan id in request body
    And the response body should contain field "message" as "string" with value "Session expired, please login again"

  @negative
  Scenario Outline: Date should reject invalid date formats
    GivenI authenticate as "creator" for "lending" slot 3 and remember as "creator3"

    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "allocation_month" as "auto" to "01/2021/01"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.data.allocation_month" as "string" with value "Invalid date provided for allocation_month"

  @positive
  Scenario: Verify Balance_Claim_amount derive automatiocally with the formula
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "total_claim_amount" as "auto" to "100"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "balance_claim_amount" as "string" with value "100"
    And the response body should contain field "total_claim_amount" as "string" with value "100"

  @positive
  Scenario: Verify upload creates a new loan or updates an existing one
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.loan_details.applicant_cibil_score" as "integer" with value "750"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_cibil_score" as "auto" to "950"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.loan_details.applicant_cibil_score" as "integer" with value "950"

  @positive
  Scenario: Verify default upload merges/updates
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.loan_details.applicant_cibil_score" as "integer" with value "750"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_cibil_score" as "auto" to "950"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.loan_details.applicant_cibil_score" as "integer" with value "950"
    And the response body should contain field "applicant_dob" as "string" with value "1991-12-01"
    And the response body should contain field "applicant_cibil_score" as "string" with value "950"
    And the response body should contain field "credit_bank_ifsc_code" as "string" with value "IFSC9087871"

  @positive @regression @ll
  Scenario Outline: Verify Upload variable: applicant_contact_number_is_active should accept only true and false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "<field_path>" as "boolean" to "<allowed_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_contact_details[0].applicant_contact_number_is_active" as "boolean" with value "<allowed_value>"

    Examples: 
      | field_path                                                      | allowed_value |
      | applicant_contact_details[0].applicant_contact_number_is_active | true          |
      | applicant_contact_details[0].applicant_contact_number_is_active | false         |

  @negative @regression @ll
  Scenario: Verify applicant_contact_number_is_active reject invalid data
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_contact_details[0].applicant_contact_number_is_active" as "auto" to "lllll"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "$.output.error.data.applicant_contact_details.0.applicant_contact_number_is_active" as "auto" with value "Value must be of boolean for applicant_contact_number_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_contact_number_is_active key is removed from request then default value is true in response
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_contact_details[0].applicant_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_contact_details[0].applicant_contact_number_is_active" as "boolean" with value "true"

  @negative @regression @bug @ll
  Scenario: Verify Upload variable:applicant_contact_number_is_active is mandatory then user will not able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update.json"
    And I update JSON field "sub_variables.find { it.variable_id == 'X2o9VJcT' }.is_mandatory" as "boolean" to "true"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_contact_details' }.sub_variables.find { it.variable_name == 'applicant_contact_number_is_active' }.is_mandatory" as "boolean" with value "true"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_contact_details[0].applicant_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @positive @regression @ll
  Scenario: Verify Upload variable:applicant_contact_number_is_active is mandatory then user will able to upload loan with this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update.json"
    And I update JSON field "sub_variables.find { it.variable_id == 'X2o9VJcT' }.is_mandatory" as "boolean" to "true"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_contact_details' }.sub_variables.find { it.variable_name == 'applicant_contact_number_is_active' }.is_mandatory" as "boolean" with value "true"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_contact_details[0].applicant_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @ll
  Scenario: Verify Upload variable:applicant_contact_number_is_active is non mandatory then user will able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update.json"
    And I update JSON field "sub_variables.find { it.variable_id == 'X2o9VJcT' }.is_mandatory" as "boolean" to "false"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_contact_details' }.sub_variables.find { it.variable_name == 'applicant_contact_number_is_active' }.is_mandatory" as "boolean" with value "false"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_contact_details[0].applicant_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_contact_details[0].applicant_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @ll
  Scenario Outline: Verify Upload variable: applicant_contact_number_is_valid should accept only true and false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_contact_details[0].applicant_contact_number_is_valid" as "boolean" to "<allowed_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_contact_details[0].applicant_contact_number_is_valid" as "boolean" with value "<allowed_value>"

    Examples: 
      | allowed_value |
      | true          |
      | false         |

  @negative @regression @ll
  Scenario: Verify applicant_contact_number_is_valid reject invalid data
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_contact_details[0].applicant_contact_number_is_valid" as "auto" to "lllll"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "$.output.error.data.applicant_contact_details.0.applicant_contact_number_is_valid" as "auto" with value "Value must be of boolean for applicant_contact_number_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_contact_number_is_valid key is removed from request then default value is true in response
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_contact_details[0].applicant_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_contact_details[0].applicant_contact_number_is_valid" as "boolean" with value "true"

  @negative @regression @bug @ll
  Scenario: Verify Upload variable: applicant_contact_number_is_valid is mandatory then user will not be able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'X8a9YBcR'}.is_mandatory" as "boolean" to "true"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_contact_details' }.sub_variables.find { it.variable_name == 'applicant_contact_number_is_valid' }.is_mandatory" as "boolean" with value "true"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_contact_details[0].applicant_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_contact_number_is_valid is mandatory then user will be able to upload loan with this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'X8a9YBcR'}.is_mandatory" as "boolean" to "true"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_contact_details' }.sub_variables.find { it.variable_name == 'applicant_contact_number_is_valid' }.is_mandatory" as "boolean" with value "true"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_contact_details[0].applicant_contact_number_is_valid" as "boolean" with value "true"

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_contact_number_is_valid is non mandatory then user will be able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'X8a9YBcR'}.is_mandatory" as "boolean" to "false"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_contact_details' }.sub_variables.find { it.variable_name == 'applicant_contact_number_is_valid' }.is_mandatory" as "boolean" with value "false"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_contact_details[0].applicant_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_contact_details[0].applicant_contact_number_is_valid" as "boolean" with value "true"

  @positive @regression @ll
  Scenario Outline: Verify Upload variable: applicant_email_is_valid should accept only true and false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_email_details[0].applicant_email_is_valid" as "boolean" to "<allowed_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_email_details[0].applicant_email_is_valid" as "boolean" with value "<allowed_value>"

    Examples: 
      | allowed_value |
      | true          |
      | false         |

  @negative @regression @ll
  Scenario: Verify applicant_email_is_valid reject invalid data
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_email_details[0].applicant_email_is_valid" as "auto" to "lllll"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "$.output.error.data.applicant_email_details.0.applicant_email_is_valid" as "auto" with value "Value must be of boolean for applicant_email_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_email_is_valid key is removed from request then default value is true in response
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_email_details[0].applicant_email_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_email_details[0].applicant_email_is_valid" as "boolean" with value "true"

  @negative @regression @bug @ll
  Scenario: Verify Upload variable: applicant_email_is_valid is mandatory then user will not be able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update_email.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'Xa4oNQcT'}.is_mandatory" as "boolean" to "true"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_email_details' }.sub_variables.find { it.variable_name == 'applicant_email_is_valid' }.is_mandatory" as "boolean" with value "true"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_email_details[0].applicant_email_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_email_is_valid is mandatory then user will be able to upload loan with this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update_email.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'Xa4oNQcT'}.is_mandatory" as "boolean" to "true"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_email_details' }.sub_variables.find { it.variable_name == 'applicant_email_is_valid' }.is_mandatory" as "boolean" with value "true"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_email_details[0].applicant_email_is_valid" as "boolean" with value "true"

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_email_is_valid is non mandatory then user will be able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update_email.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'Xa4oNQcT'}.is_mandatory" as "boolean" to "false"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_email_details' }.sub_variables.find { it.variable_name == 'applicant_email_is_valid' }.is_mandatory" as "boolean" with value "false"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_email_details[0].applicant_email_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_email_details[0].applicant_email_is_valid" as "boolean" with value "true"

  @positive @regression @ll
  Scenario Outline: Verify Upload variable: applicant_email_is_active should accept only true and false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_email_details[0].applicant_email_is_active" as "boolean" to "<allowed_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_email_details[0].applicant_email_is_active" as "boolean" with value "<allowed_value>"

    Examples: 
      | allowed_value |
      | true          |
      | false         |

  @negative @regression @ll
  Scenario: Verify applicant_email_is_active reject invalid data
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "applicant_email_details[0].applicant_email_is_active" as "auto" to "lllll"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "$.output.error.data.applicant_email_details.0.applicant_email_is_active" as "auto" with value "Value must be of boolean for applicant_email_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_email_is_active key is removed from request then default value is true in response
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_email_details[0].applicant_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_email_details[0].applicant_email_is_active" as "boolean" with value "true"

  @negative @regression @bug @ll
  Scenario: Verify Upload variable: applicant_email_is_active is mandatory then user will not be able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update_email.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'X9q2TObY'}.is_mandatory" as "boolean" to "true"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_email_details' }.sub_variables.find { it.variable_name == 'applicant_email_is_active' }.is_mandatory" as "boolean" with value "true"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_email_details[0].applicant_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_email_is_active is mandatory then user will be able to upload loan with this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update_email.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'X9q2TObY'}.is_mandatory" as "boolean" to "true"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_email_details' }.sub_variables.find { it.variable_name == 'applicant_email_is_active' }.is_mandatory" as "boolean" with value "true"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_email_details[0].applicant_email_is_active" as "boolean" with value "true"

  @positive @regression @ll
  Scenario: Verify Upload variable: applicant_email_is_active is non mandatory then user will be able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/variable_update_email.json"
    And I update JSON field "sub_variables.find { it.variable_id== 'X9q2TObY'}.is_mandatory" as "boolean" to "false"
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.variable_name == 'applicant_email_details' }.sub_variables.find { it.variable_name == 'applicant_email_is_active' }.is_mandatory" as "boolean" with value "false"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "applicant_email_details[0].applicant_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.applicant.applicant_email_details[0].applicant_email_is_active" as "boolean" with value "true"

  @negative @regression @TC_LUU_146 @bug @ss
  Scenario: Verify when co_applicant_contact_number_is_valid variable is mandatory then user will not able to upload loan without co_applicant_contact_number_is_valid variable
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "data"
    And the response body should contain field "message_template" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "message_placeholder"
    And the response body should contain field "output.error.code"
    And the response body should contain field "output.error.data"
    And the response body should contain field "output.error.detail"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_0007"

  @positive @regression @TC_LUU_146
  Scenario: Verify when co_applicant_contact_number_is_valid variable is  mandatory then user will able to upload loan with co_applicant_contact_number_is_valid variable
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.loan_details.co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid" as "boolean" with value "true"

  @positive @regression @TC_LUU_146
  Scenario: Verify a non-mandatory co_applicant_contact_number_is_valid variable allows loan upload when omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should not contain field "output.loan_details.co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid"

  @positive @regression @TC_LUU_146
  Scenario: Verify a non-mandatory co_applicant_contact_number_is_valid variable accepts loan upload when provided
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.loan_details.co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid" as "boolean" with value "true"

  @positive @regression @TC_LUU_146
  Scenario: Verify a non-mandatory co_applicant_contact_number_is_valid variable accepts false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.loan_details.co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid" as "boolean" with value "false"

  @negative @regression @TC_LUU_146
  Scenario: Verify a non-mandatory co_applicant_contact_number_is_valid variable rejects an invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_valid" as "auto" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "$.output.error.data.co_applicant.0.co_applicant_contact_details.0.co_applicant_contact_number_is_valid" as "auto" with value "Value must be of boolean for co_applicant_contact_number_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_147_01
  Scenario: Verify loan upload succeeds when mandatory co_applicant_contact_number_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_147_02
  Scenario: Verify loan upload succeeds when mandatory co_applicant_contact_number_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" with value "false"

  @negative @regression @TC_LUU_147_03 @bug
  Scenario: Verify Upload variable: co_applicant_contact_number_is_active is mandatory then user will not be able to upload loan without this field
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_0007"

  @negative @regression @TC_LUU_147_04
  Scenario: Verify loan upload fails when mandatory co_applicant_contact_number_is_active variable has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.data.co_applicant.0.co_applicant_contact_details.0.co_applicant_contact_number_is_active" as "string" with value "Value must be of boolean for co_applicant_contact_number_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_147_05
  Scenario: Verify loan upload succeeds when non-mandatory co_applicant_contact_number_is_active variable is provided as true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_147_06
  Scenario: Verify loan upload succeeds when non-mandatory co_applicant_contact_number_is_active variable is provided as false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" with value "false"

  @positive @regression @TC_LUU_147_07
  Scenario: Verify non-mandatory co_applicant_contact_number_is_active defaults to true when omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_147_06
  Scenario: Verify non-mandatory co_applicant_contact_number_is_active defaults to true when omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "boolean" with value "true"

  @negative @regression @TC_LUU_147_08
  Scenario: Verify loan upload fails when non-mandatory co_applicant_contact_number_is_active variable is provided with invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_contact_details[0].co_applicant_contact_number_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.detail" as "string" with value "Encountered an exception while validating loan_data"
    And the response body should contain field "output.error.data.co_applicant.0.co_applicant_contact_details.0.co_applicant_contact_number_is_active" as "string" with value "Value must be of boolean for co_applicant_contact_number_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_148_01
  Scenario: Verify loan upload succeeds when mandatory co_applicant_email_is_valid is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "boolean" with value "true"

  @positive @regression @TC_LUU_148_02
  Scenario: Verify loan upload succeeds when mandatory co_applicant_email_is_valid variable is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "boolean" with value "false"

  @negative @regression @TC_LUU_148_03 @bug
  Scenario: Verify loan upload fails when mandatory co_applicant_email_is_valid variable is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"

  @negative @regression @TC_LUU_148_04
  Scenario: Verify loan upload fails when mandatory co_applicant_email_is_valid variable contains invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.co_applicant.0.co_applicant_email_details.0.co_applicant_email_is_valid" as "string" with value "Value must be of boolean for co_applicant_email_is_valid. Only 'True', 'False', '1', or '0' are allowed"
    And the response body should contain field "output.error.detail" as "string" with value "Encountered an exception while validating loan_data"

  @positive @regression @TC_LUU_148_05
  Scenario: Verify loan upload succeeds when non-mandatory co_applicant_email_is_valid variable is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"

  @positive @regression @TC_LUU_148_06
  Scenario: Verify loan upload succeeds when non-mandatory co_applicant_email_is_valid variable is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"

  @positive @regression @TC_LUU_148_07
  Scenario: Verify non-mandatory co_applicant_email_is_valid variable allows loan upload when omitted and defaults to true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "boolean" with value "true"

  @negative @regression @TC_LUU_148_08
  Scenario: Verify loan upload fails when non-mandatory co_applicant_email_is_valid variable contains invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_valid" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema_loan_upload.json"
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.co_applicant.0.co_applicant_email_details.0.co_applicant_email_is_valid" as "string" with value "Value must be of boolean for co_applicant_email_is_valid. Only 'True', 'False', '1', or '0' are allowed"
    And the response body should contain field "output.error.detail" as "string" with value "Encountered an exception while validating loan_data"

  @positive @regression @TC_LUU_149_01
  Scenario: Verify loan upload succeeds when mandatory co_applicant_email_is_active variable is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_149_02
  Scenario: Verify loan upload succeeds when mandatory co_applicant_email_is_active variable is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" with value "false"

  @negative @regression @TC_LUU_149_03 @bug
  Scenario: Verify loan upload fails when mandatory co_applicant_email_is_active variable is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"

  @negative @regression @TC_LUU_149_04
  Scenario: Verify loan upload fails when mandatory co_applicant_email_is_active variable has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.co_applicant.0.co_applicant_email_details.0.co_applicant_email_is_active" as "string" with value "Value must be of boolean for co_applicant_email_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_149_05
  Scenario: Verify loan upload succeeds when non-mandatory co_applicant_email_is_active variable is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_149_06
  Scenario: Verify loan upload succeeds when non-mandatory co_applicant_email_is_active variable is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" with value "false"

  @positive @regression @TC_LUU_149_07
  Scenario: Verify non-mandatory co_applicant_email_is_active variable uses default true when omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}  |
      | attribute_levels | co_applicants |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.co_applicants[0].co_applicant_email_details[0].co_applicant_email_is_active" as "boolean" with value "true"

  @negative @regression @TC_LUU_149_08
  Scenario: Verify non-mandatory co_applicant_email_is_active variable rejects invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "co_applicant_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "co_applicant[0].co_applicant_email_details[0].co_applicant_email_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "success" as "boolean" with value "false"
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.co_applicant.0.co_applicant_email_details.0.co_applicant_email_is_active" as "string" with value "Value must be of boolean for co_applicant_email_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_150_01
  Scenario: Verify loan upload succeeds when mandatory loan_guarantor_contact_number_is_valid is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" with value "true"

  @positive @regression @TC_LUU_150_02
  Scenario: Verify loan upload succeeds when mandatory loan_guarantor_contact_number_is_valid is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" with value "false"

  @positive @regression @TC_LUU_150_03
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_contact_number_is_valid is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" with value "true"

  @positive @regression @TC_LUU_150_04
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_contact_number_is_valid is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" with value "false"

  @positive @regression @TC_LUU_150_05
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_contact_number_is_valid is omitted and defaults to true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "boolean" with value "true"

  @negative @regression @TC_LUU_150_06 @bug
  Scenario: Verify loan upload fails when mandatory loan_guarantor_contact_number_is_valid is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @negative @regression @TC_LUU_150_07
  Scenario: Verify loan upload fails when mandatory loan_guarantor_contact_number_is_valid contains invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.loan_guarantor.0.loan_guarantor_contact_details.0.loan_guarantor_contact_number_is_valid" as "string" with value "Value must be of boolean for loan_guarantor_contact_number_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_150_08
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_contact_number_is_valid contains invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_valid" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.loan_guarantor.0.loan_guarantor_contact_details.0.loan_guarantor_contact_number_is_valid" as "string" with value "Value must be of boolean for loan_guarantor_contact_number_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_151_01
  Scenario: Verify loan upload succeeds when mandatory loan_guarantor_contact_number_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_151_02
  Scenario: Verify loan upload succeeds when mandatory loan_guarantor_contact_number_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" with value "false"

  @positive @regression @TC_LUU_151_03
  Scenario: Verify default value is true when non-mandatory loan_guarantor_contact_number_is_active is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" with value "true"

  @negative @regression @TC_LUU_151_04
  Scenario: Verify loan upload fails when non-mandatory loan_guarantor_contact_number_is_active has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.loan_guarantor.0.loan_guarantor_contact_details.0.loan_guarantor_contact_number_is_active" as "string" with value "Value must be of boolean for loan_guarantor_contact_number_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @negative @regression @TC_LUU_151_05 @bug
  Scenario: Verify loan upload fails when mandatory loan_guarantor_contact_number_is_active is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"

  @positive @regression @TC_LUU_151_06
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_contact_number_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_151_07
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_contact_number_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "boolean" with value "false"

  @negative @regression @TC_LUU_151_08
  Scenario: Verify loan upload fails when mandatory loan_guarantor_contact_number_is_active has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_contact_details[0].loan_guarantor_contact_number_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.loan_guarantor.0.loan_guarantor_contact_details.0.loan_guarantor_contact_number_is_active" as "string" with value "Value must be of boolean for loan_guarantor_contact_number_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_152_01
  Scenario: Verify loan upload succeeds when mandatory loan_guarantor_email_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_152_02
  Scenario: Verify loan upload succeeds when mandatory loan_guarantor_email_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" with value "false"

  @negative @regression @TC_LUU_152_03 @bug
  Scenario: Verify loan upload fails when mandatory loan_guarantor_email_is_active is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"

  @negative @regression @TC_LUU_152_04
  Scenario: Verify loan upload fails when mandatory loan_guarantor_email_is_active has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.loan_guarantor.0.loan_guarantor_email_details.0.loan_guarantor_email_is_active" as "string" with value "Value must be of boolean for loan_guarantor_email_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_152_05
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_email_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_152_06
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_email_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" with value "false"

  @positive @regression @TC_LUU_152_07
  Scenario: Verify loan upload succeeds when non-mandatory loan_guarantor_email_is_active is omitted and defaults to true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | guarantors   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.guarantors[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "boolean" with value "true"

  @negative @regression @TC_LUU_152_08
  Scenario: Verify loan upload fails when non-mandatory loan_guarantor_email_is_active has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "loan_guarantor_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "false"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "loan_guarantor[0].loan_guarantor_email_details[0].loan_guarantor_email_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.loan_guarantor.0.loan_guarantor_email_details.0.loan_guarantor_email_is_active" as "string" with value "Value must be of boolean for loan_guarantor_email_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @TC_LUU_153_01
  Scenario: Verify loan upload succeeds when mandatory reference_contact_number_is_valid is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_contact_details[0].reference_contact_number_is_valid" as "boolean" with value "true"

  @TC_LUU_153_02
  Scenario: Verify loan upload succeeds when mandatory reference_contact_number_is_valid is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @TC_LUU_153_03 @bug
  Scenario: Verify loan upload fails when mandatory reference_contact_number_is_valid is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "references[0].reference_contact_details[0].reference_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @TC_LUU_153_04
  Scenario: Verify loan upload fails when mandatory reference_contact_number_is_valid has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_valid" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.data.references.0.reference_contact_details.0.reference_contact_number_is_valid" as "string" with value "Value must be of boolean for reference_contact_number_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @TC_LUU_153_05
  Scenario: Verify loan upload succeeds when non-mandatory reference_contact_number_is_valid is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @TC_LUU_153_06
  Scenario: Verify loan upload succeeds when non-mandatory reference_contact_number_is_valid is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @TC_LUU_153_07
  Scenario: Verify loan upload succeeds when non-mandatory reference_contact_number_is_valid is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "references[0].reference_contact_details[0].reference_contact_number_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @TC_LUU_153_08
  Scenario: Verify loan upload with non-mandatory reference_contact_number_is_valid has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_valid" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.data.references.0.reference_contact_details.0.reference_contact_number_is_valid" as "string" with value "Value must be of boolean for reference_contact_number_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @smoke @TC_LUU_154_01
  Scenario: Verify loan upload succeeds when mandatory reference_contact_number_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @smoke @TC_LUU_154_02
  Scenario: Verify loan upload succeeds when mandatory reference_contact_number_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" with value "false"

  @negative @regression @smoke @TC_LUU_154_03 @bug
  Scenario: Verify loan upload fails when mandatory reference_contact_number_is_active is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "references[0].reference_contact_details[0].reference_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @negative @regression @smoke @TC_LUU_154_04
  Scenario: Verify loan upload fails when mandatory reference_contact_number_is_active has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output.error.data.references.0.reference_contact_details.0.reference_contact_number_is_active" as "string" with value "Value must be of boolean for reference_contact_number_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @smoke @TC_LUU_154_05
  Scenario: Verify loan upload succeeds when non-mandatory reference_contact_number_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" with value "true"

  @positive @regression @smoke @TC_LUU_154_06
  Scenario: Verify loan upload succeeds when non-mandatory reference_contact_number_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" with value "false"

  @positive @regression @smoke @TC_LUU_154_07
  Scenario: Verify loan upload succeeds when non-mandatory reference_contact_number_is_active is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "references[0].reference_contact_details[0].reference_contact_number_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_contact_details[0].reference_contact_number_is_active" as "boolean" with value "true"

  @negative @regression @smoke @TC_LUU_154_08
  Scenario: Verify loan upload fails when non-mandatory reference_contact_number_is_active has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_contact_number_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_contact_details[0].reference_contact_number_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.data.references.0.reference_contact_details.0.reference_contact_number_is_active" as "string" with value "Value must be of boolean for reference_contact_number_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @TC_LUU_155_01
  Scenario: Verify loan upload succeeds when mandatory reference_email_is_valid is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_valid" as "boolean" with value "true"

  @TC_LUU_155_02
  Scenario: Verify loan upload succeeds when mandatory reference_email_is_valid is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_valid" as "boolean" with value "false"

  @TC_LUU_155_03 @bug
  Scenario: Verify loan upload fails when mandatory reference_email_is_valid is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "references[0].reference_email_details[0].reference_email_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.data.references.0.reference_email_details.0.reference_email_is_valid" as "string" with value "This field is mandatory"

  @TC_LUU_155_04
  Scenario: Verify loan upload fails when mandatory reference_email_is_valid has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_valid" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.data.references.0.reference_email_details.0.reference_email_is_valid" as "string" with value "Value must be of boolean for reference_email_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @TC_LUU_155_05 @specialbug
  Scenario: Verify loan upload succeeds when non-mandatory reference_email_is_valid is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_valid" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_valid" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @TC_LUU_155_06
  Scenario: Verify loan upload succeeds when non-mandatory reference_email_is_valid is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_valid" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @TC_LUU_155_07
  Scenario: Verify loan upload succeeds when non-mandatory reference_email_is_valid is omitted and defaults to true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "references[0].reference_email_details[0].reference_email_is_valid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @TC_LUU_155_08
  Scenario: Verify loan upload fails when non-mandatory reference_email_is_valid has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_valid" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "output.error.data.references.0.reference_email_details.0.reference_email_is_valid" as "string" with value "Value must be of boolean for reference_email_is_valid. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @smoke @TC_LUU_156_01
  Scenario: Verify loan upload succeeds when mandatory reference_email_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_active" as "boolean" with value "true"

  @positive @regression @smoke @TC_LUU_156_02
  Scenario: Verify loan upload succeeds when mandatory reference_email_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output.find { it.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } } }.sub_variables.find { it.sub_variables.find { it.variable_id == '{VARIABLE_ID}' } }.sub_variables.find { it.variable_id == '{VARIABLE_ID}' }.is_mandatory" as "boolean" with value "true"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_active" as "boolean" with value "false"

  @negative @regression @smoke @TC_LUU_156_03
  Scenario: Verify loan upload fails when mandatory reference_email_is_active is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "references[0].reference_email_details[0].reference_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.references.0.reference_email_details.0.reference_email_is_active" as "string"

  @negative @regression @smoke @TC_LUU_156_04
  Scenario: Verify loan upload fails when mandatory reference_email_is_active has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":true}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.references.0.reference_email_details.0.reference_email_is_active" as "string" with value "Value must be of boolean for reference_email_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @smoke @TC_LUU_156_05
  Scenario: Verify loan upload succeeds when non-mandatory reference_email_is_active is true
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_active" as "boolean" to "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_active" as "boolean" with value "true"

  @positive @regression @smoke @TC_LUU_156_06
  Scenario: Verify loan upload succeeds when non-mandatory reference_email_is_active is false
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_active" as "boolean" to "false"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_active" as "boolean" with value "false"

  @positive @regression @smoke @TC_LUU_156_07
  Scenario: Verify loan upload succeeds when non-mandatory reference_email_is_active is omitted
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I remove JSON field "references[0].reference_email_details[0].reference_email_is_active"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | references   |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_active" as "boolean" with value "true"

  @negative @regression @smoke @TC_LUU_156_08
  Scenario: Verify loan upload fails when non-mandatory reference_email_is_active has invalid value
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I find and store variable id for name "reference_email_is_active" from variables response
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"company_id":"{COMPANY_ID}","variable_id":"{VARIABLE_ID}","is_mandatory":false}
      """
    When I send a "PATCH" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "message" as "string" with value "Variables updated successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_computed_variables | true         |
      | include_meta_data          | true         |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "references[0].reference_email_details[0].reference_email_is_active" as "string" to "invalid"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" as "string" with value "Loan Data Validation Failed"
    And the response body should contain field "output.error.code" as "string" with value "REC_0025"
    And the response body should contain field "output.error.data.references.0.reference_email_details.0.reference_email_is_active" as "string" with value "Value must be of boolean for reference_email_is_active. Only 'True', 'False', '1', or '0' are allowed"

  @positive @regression @TC_LUU_029
  Scenario: Verify that a loan existing in the previous month and uploaded again in the current month is visible in the Portfolio under both allocated months.
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | attribute_levels | references                  |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_active" as "boolean" with value "true"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:-1}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                 |
      | attribute_levels | references                   |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:-1} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.references[0].reference_email_details[0].reference_email_is_active" as "boolean" with value "true"

  @positive @regression @TC_LUU_030
  Scenario: Verify Loan Upload Functionality if uploading allocation attribute different allocation month
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "defaults[0].total_claim_amount" as "auto" to "19000"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}                                                                                         |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.allocation_variables.total_claim_amount" as "auto" with value "19000"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:-1}"
    And I update JSON field "defaults[0].total_claim_amount" as "auto" to "19001"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:-1}                                                                                        |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.allocation_variables.total_claim_amount" as "auto" with value "19001"
    And the response body should contain field "data.variable_data.{LOAN_ID}.tags[0].tags" as "auto" with value "tags_loan_1"

  @TC_LUU_044 @positive @regression
  Scenario: Verify Loan Upload Functionality by uploading additional text type variable
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {"variable_type":"text","company_id": "{COMPANY_ID}","variable_name":"{VARIABLE_NAME}"}
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response body should contain field "message" as "string" with value "Variables added successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID}    |
      | include_computed_variables | true            |
      | include_meta_data          | true            |
      | variable_name              | {VARIABLE_NAME} |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output[0].variable_name" as "string" with value "{VARIABLE_NAME}"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I add JSON field "{VARIABLE_NAME}" as "string" with value "loantextvariable"
    And I update JSON field "defaults[0].total_claim_amount" as "auto" to "19000"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field " data.variable_data.{LOAN_ID}.loan_additional_variables.{VARIABLE_NAME}" as "string" with value "loantextvariable"

  @TC_LUU_045 @positive @regression
  Scenario: Verify Loan Upload Functionality by uploading additional text type variable of allocation level
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
      "variable_type": "text",
      "variable_level": "allocation",
      "is_allocation_variable": true,
      "is_transaction_variable": false,
      "is_derivable": false,
      "variable_name": "{VARIABLE_NAME}"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response body should contain field "message" as "string" with value "Variables added successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID}    |
      | include_computed_variables | true            |
      | include_meta_data          | true            |
      | variable_name              | {VARIABLE_NAME} |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output[0].variable_name" as "string" with value "{VARIABLE_NAME}"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I add JSON field "{VARIABLE_NAME}" as "string" with value "allocationtextvariable"
    And I update JSON field "defaults[0].total_claim_amount" as "auto" to "19000"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.allocation_additional_variables.{VARIABLE_NAME}" as "string" with value "allocationtextvariable"

  @TC_LUU_046 @positive @regression
  Scenario: Verify Loan Upload Functionality by uploading additional boolean type variable
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
      "variable_type": "bool",
      "allow_multiple_values": false,
      "is_dropdown": false,
      "is_trackable": false,
      "is_casing_enabled": false,
      "is_mandatory": false,
      "is_workflow_editable": false,
      "is_derivable": false,
      "company_id": "{COMPANY_ID}",
      "variable_name": "{VARIABLE_NAME}"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response body should contain field "message" as "string" with value "Variables added successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID}    |
      | include_computed_variables | true            |
      | include_meta_data          | true            |
      | variable_name              | {VARIABLE_NAME} |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output[0].variable_name" as "string" with value "{VARIABLE_NAME}"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I add JSON field "{VARIABLE_NAME}" as "boolean" with value "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field " data.variable_data.{LOAN_ID}.loan_additional_variables.{VARIABLE_NAME}" as "boolean" with value "true"

  @TC_LUU_047 @positive @regression
  Scenario: Verify Loan Upload Functionality by uploading additional boolean type variable of allocation level
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
      "variable_type": "bool",
      "allow_multiple_values": false,
      "is_dropdown": false,
      "is_trackable": false,
      "is_casing_enabled": false,
      "is_mandatory": false,
      "is_workflow_editable": false,
      "is_derivable": false,
      "variable_level": "allocation",
      "is_allocation_variable": true,
      "is_transaction_variable": false,
      "company_id": "{COMPANY_ID}",
      "variable_name": "{VARIABLE_NAME}"
      }
      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response body should contain field "message" as "string" with value "Variables added successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID}    |
      | include_computed_variables | true            |
      | include_meta_data          | true            |
      | variable_name              | {VARIABLE_NAME} |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output[0].variable_name" as "string" with value "{VARIABLE_NAME}"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I add JSON field "{VARIABLE_NAME}" as "boolean" with value "true"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field " data.variable_data.{LOAN_ID}.allocation_additional_variables.{VARIABLE_NAME}" as "boolean" with value "true"

  @TC_LUU_048 @positive @regression
  Scenario: Verify Loan Upload Functionality by uploading additional number type variable
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      
      {
      "variable_type": "number",
       "company_id": "{COMPANY_ID}",
      "variable_name": "{VARIABLE_NAME}",
      "is_validation_enabled": false,
      "allow_multiple_values": false,
      "is_dropdown": false,
      "is_trackable": false,
      "is_casing_enabled": false,
      "is_mandatory": false,
      "is_workflow_editable": false,
      "is_derivable": false
      }

      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response body should contain field "message" as "string" with value "Variables added successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID}    |
      | include_computed_variables | true            |
      | include_meta_data          | true            |
      | variable_name              | {VARIABLE_NAME} |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output[0].variable_name" as "string" with value "{VARIABLE_NAME}"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I add JSON field "{VARIABLE_NAME}" as "integer" with value "1234"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.loan_additional_variables.{VARIABLE_NAME}" as "integer" with value "1234"

  @TC_LUU_048 @positive @regression
  Scenario: Verify Loan Upload Functionality by uploading additional number type variable
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      
      {
      "variable_type": "number",
       "company_id": "{COMPANY_ID}",
      "variable_name": "{VARIABLE_NAME}",
      "is_validation_enabled": false,
      "allow_multiple_values": false,
      "is_dropdown": false,
      "is_trackable": false,
      "is_casing_enabled": false,
      "is_mandatory": false,
      "is_workflow_editable": false,
      "is_derivable": false
      }

      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response body should contain field "message" as "string" with value "Variables added successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID}    |
      | include_computed_variables | true            |
      | include_meta_data          | true            |
      | variable_name              | {VARIABLE_NAME} |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output[0].variable_name" as "string" with value "{VARIABLE_NAME}"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I add JSON field "{VARIABLE_NAME}" as "integer" with value "1234"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "data.variable_data.{LOAN_ID}.loan_additional_variables.{VARIABLE_NAME}" as "integer" with value "1234"

  @TC_LUU_049 @positive @regression
  Scenario: Verify Loan Upload Functionality by uploading additional number type variable of allocation level
    Given I authenticate as "creator" for "lending" slot 3 and remember as "creator3"
    And scenario variable name is unique
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      
      {
      
      "variable_type": "number",
      "variable_level": "allocation",
      "is_allocation_variable": true,
      "is_transaction_variable": false,
      "is_derivable": false,
      "is_validation_enabled": false,
      "allow_multiple_values": false,
      "is_dropdown": false,
      "is_trackable": false,
      "is_casing_enabled": false,
      "is_mandatory": false,
      "is_workflow_editable": false,
      "company_id": "{COMPANY_ID}",
      "variable_name": "{VARIABLE_NAME}"
      
      }

      """
    When I send a "POST" request to "/recovery/variables"
    Then the response status code should be 201
    And the response body should contain field "message" as "string" with value "Variables added successfully"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID}    |
      | include_computed_variables | true            |
      | include_meta_data          | true            |
      | variable_name              | {VARIABLE_NAME} |
    When I send a "GET" request to "/recovery/variables"
    Then the response status code should be 200
    And the response body should contain field "output[0].variable_name" as "string" with value "{VARIABLE_NAME}"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
    And I add JSON field "{VARIABLE_NAME}" as "integer" with value "1234"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                                                                        |
      | attribute_levels | loan_variables,document_details,loan_additional_variables,allocation_additional_variables,allocation_variables,tags |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field " data.variable_data.{LOAN_ID}.allocation_additional_variables.{VARIABLE_NAME}" as "integer" with value "1234"
