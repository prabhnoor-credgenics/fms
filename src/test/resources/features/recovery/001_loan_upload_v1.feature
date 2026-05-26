@api @loan-recovery @datatype-validation
Feature: Loan Recovery API - Strict Datatype Validation

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
    And I set the query parameters:
      | replace_previous_data | false |
      | replace_given_data    | false |


  @api-validation @negative @approver
  Scenario: API should return 401 when authentication token is missing
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 401
    And the response message should be "Session expired, please login again"
    And the response should match json schema "schemas/loan_recovery_error_schema.json"

  @api-validation @negative @testapi @creator
  Scenario: API should return 401 when authentication token is invalid
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 401
    And the response should match json schema "schemas/loan_recovery_error_schema.json"

  @api-validation @negative @creator
  Scenario: API should return 403 when company_id query parameter is missing
    Given I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 403
    And the response should match json schema "schemas/loan_recovery_error_schema.json"

  @api-validation @negative @creator
  Scenario: API should return 400 when URI loan_id does not match payload loan_id
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | different_loan_id |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/loan_recovery_error_schema.json"


  @api-validation @negative @creator
  Scenario: API should return 400 when loan_id is null in payload
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" to null
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/loan_recovery_error_schema.json"
    And the validation error should contain
      | detail | Id provided in parameter & payload are different. |



  @datatype-validation @text @special-characters @positive @creator
  Scenario: Loan ID field should accept values containing allowed special characters
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | loan_123-ABC/45 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" to "loan_123-ABC/45"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/loan_recovery_success_schema.json"

  @datatype-validation @text @special-characters @negative @creator
  Scenario: Loan ID field should not accept values containing allowed special characters
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | loan^123 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" to "loan^123"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @datatype-validation @text @special-characters @positive @creator
  Scenario Outline: Text fields should accept values containing allowed special characters
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<allowed_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                                              | allowed_value                     |
      | client_customer_id                                      | cust_01-AZ                       |
      | group_id                                                | group_01-A                       |
      | center_name                                             | Center-1 (Noida) @Sector          |
      | loan_region                                             | North-East (Zone-1)               |
      | loan_zone                                               | Zone-2 (East)                    |
      | loan_branch                                             | Branch-01 (Noida)                |
      | loan_regional_manager_name                              | Rajesh.Kumar                     |
      | loan_source_branch_address                              | S-48/Sector-62 (Noida)            |
      | loan_nbfc_name                                          | NBFC-Name (India)                |
      | notice_delivery_partner                                 | Blue-Dart (India)                |
      | product_type                                            | Car-Loan/Personal                |
      | loan_type                                               | Home-Loan                        |
      | engine_number                                           | ENG-12345-A                      |
      | business_name                                           | Biz_Name-1@India                 |
      | channel_partner                                         | Partner_01#India                 |
      | chassis_number                                          | CHS12345                         |
      | credit_account_holder_name                              | Aman.Sharma                     |
      | credit_bank_ifsc_code                                   | SBIN0001234                      |
      | credit_bank_name                                        | State_Bank@India                 |
      | merchant_name                                           | PayPal.India                     |
      | applicant_name                                          | Ramesh.Kumar                    |
      | applicant_occupation                                   | Govt-Employee (Group-A)          |
      | applicant_pan_number                                   | ABCDE1234F                      |
      | applicant_address[0].applicant_address_text             | H-12/45, Sector-62               |
      | applicant_address[0].applicant_city                     | New-Delhi                        |
      | applicant_address[0].applicant_state                    | Uttar-Pradesh                   |
      | applicant_address[0].applicant_landmark                 | Near-Metro/Gate-3               |
      | co_applicant[0].co_applicant_name                       | Suresh.Verma                    |
      | co_applicant[0].co_applicant_notice_reference_number    | REF-123/2024                    |
      | co_applicant[0].co_applicant_address[0].co_applicant_address_text | Flat-21B, Rosewood-Apt |
      | allocation_dpd_bracket                                  | DPD-30 (Bucket-1)               |
      | dpd_bracket                                             | DPD-60 (Bucket-2)               |
      | security_mode                                           | High-Security                   |
      | document_details[0].document_number                     | DOC-123/2024                    |
      | document_details[0].document_bank_name                  | Axis_Bank@India                 |
      | document_details[0].document_signature_name             | Aman.K                          |
      | document_details[0].document_bounce_bank_address        | H-No-10, New-Delhi              |
      | reason_of_document_bounce                               | Late-Payment/Fee                |
      | loan_guarantor[0].loan_guarantor_name                   | Mohan.Lal                       |
      | loan_guarantor[0].loan_guarantor_address[0].loan_guarantor_address_text | Gali-5, Sector-9 |
      | relation_with_applicant                                 | Father                          |
      | references[0].name                                      | Test.Reference                  |
      | references[0].reference_pan_number                      | PQRSX9876Z                      |
      | references[0].reference_address[0].reference_address_text | S-142/67, Dehradun             |


  @datatype-validation @text @special-characters @negative @creator
  Scenario Outline: Text fields should reject values containing disallowed special characters
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                                              | invalid_value      |
      | client_customer_id                                      | cust<>01           |
      | group_id                                                | group{\|}           |
      | center_name                                             | Center~Name        |
      | loan_region                                             | North\|Zone         |
      | loan_zone                                               | Zone\\East         |
      | loan_branch                                             | Branch`01          |
      | loan_regional_manager_name                              | Rajesh\|Kumar       |
      | loan_source_branch_address                              | Addr{Sector}       |
      | loan_nbfc_name                                          | NBFC^Name          |
      | notice_delivery_partner                                 | Blue~Dart          |
      | product_type                                            | Car#Loan^          |
      | loan_type                                               | Home~Loan          |
      | engine_number                                           | ENG@123^           |
      | business_name                                           | Biz{name}          |
      | channel_partner                                         | Partner\|01         |
      | chassis_number                                          | CHS<>998           |
      | credit_account_holder_name                              | Aman{Sharma}      |
      | credit_bank_ifsc_code                                   | SBIN^001           |
      | credit_bank_name                                        | Bank{Name}         |
      | merchant_name                                           | PayPal~India       |
      | applicant_name                                          | Ramesh<>           |
      | applicant_occupation                                   | Govt\|Employee      |
      | applicant_pan_number                                   | ABCD^1234          |
      | applicant_address[0].applicant_address_text             | House~12           |
      | applicant_address[0].applicant_city                     | City{Name}         |
      | applicant_address[0].applicant_state                    | State<>UP          |
      | applicant_address[0].applicant_landmark                 | Near\|Metro         |
      | co_applicant[0].co_applicant_name                       | Suresh\|Verma       |
      | allocation_dpd_bracket                                  | DPD^30             |
      | dpd_bracket                                             | DPD~60             |
      | security_mode                                           | High\|Secure        |
      | document_details[0].document_number                     | DOC{123}           |
      | document_details[0].document_bank_name                  | Axis~Bank          |
      | document_details[0].document_signature_name             | Aman~K             |
      | reason_of_document_bounce                               | Late^Payment       |
      | loan_guarantor[0].loan_guarantor_name                   | Mohan\|Lal          |
      | relation_with_applicant                                 | Father^            |
      | references[0].name                                      | Test\|Reference     |


  @datatype-validation @text @negative @creator
  Scenario: Loan ID should reject values exceeding max length of 64
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {RANDOM_STRING:65} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" to "{RANDOM_STRING:65}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400


  @datatype-validation @text @negative @creator
  Scenario Outline: Text field should reject values exceeding max length of 255
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "{RANDOM_STRING:<max_length_plus>}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                                                        | max_length_plus |
      | client_customer_id                                                | 65  |
      | group_id                                                          | 65  |
      | center_name                                                       | 257 |
      | loan_region                                                       | 257 |
      | loan_zone                                                         | 257 |
      | loan_branch                                                       | 257 |
      | loan_regional_manager_name                                        | 65  |
      | loan_source_branch_address                                        | 257 |
      | loan_nbfc_name                                                    | 257 |
      | notice_delivery_partner                                           | 257 |
      | product_type                                                      | 257 |
      | loan_type                                                         | 257 |
      | engine_number                                                     | 18  |
      | business_name                                                     | 257 |
      | channel_partner                                                   | 257 |
      | chassis_number                                                    | 18  |
      | credit_account_holder_name                                        | 65  |
      | credit_bank_ifsc_code                                             | 12  |
      | credit_bank_name                                                  | 257 |
      | vehicle_registration_number                                       | 21  |
      | merchant_name                                                     | 65  |
      | applicant_name                                                    | 65  |
      | applicant_occupation                                              | 65  |
      | applicant_pan_number                                              | 11  |
      | applicant_aadhar_number                                           | 13  |
      | applicant_address[0].applicant_address_type                       | 21  |
      | applicant_address[0].applicant_address_text                       | 257 |
      | applicant_address[0].applicant_city                               | 257 |
      | applicant_address[0].applicant_state                              | 257 |
      | applicant_address[0].applicant_landmark                           | 257 |
      | applicant_address[0].applicant_address_latitude                   | 13  |
      | applicant_address[0].applicant_address_longitude                  | 13  |
      | co_applicant[0].co_applicant_name                                 | 65  |
      | co_applicant[0].co_applicant_notice_reference_number              | 257 |
      | co_applicant[0].co_applicant_pan_number                           | 11  |
      | co_applicant[0].co_applicant_address[0].co_applicant_address_text| 257 |
      | co_applicant[0].co_applicant_address[0].co_applicant_city        | 257 |
      | co_applicant[0].co_applicant_address[0].co_applicant_state       | 257 |
      | co_applicant[0].co_applicant_address[0].co_applicant_address_latitude | 13 |
      | co_applicant[0].co_applicant_address[0].co_applicant_address_longitude| 13 |
      | allocation_dpd_bracket                                            | 65  |
      | dpd_bracket                                                       | 65  |
      | security_mode                                                     | 257 |
      | document_details[0].document_number                               | 257 |
      | document_details[0].document_bank_name                            | 257 |
      | document_details[0].document_bank_ifsc_code                       | 12  |
      | document_details[0].document_signature_name                       | 65  |
      | document_details[0].document_bounce_bank_name                     | 257 |
      | document_details[0].document_bounce_bank_ifsc_code                | 12  |
      | document_details[0].document_bounce_bank_address                  | 257 |
      | document_details[0].reason_of_document_bounce                     | 257 |
      | document_details[0].document_micr                                 | 10  |
      | document_details[0].document_presented_in_account                 | 257 |
      | document_details[0].document_presented_zone                       | 257 |
      | document_details[0].document_bounce_memo_branch_address           | 257 |
      | document_details[0].document_signature_address_text               | 257 |
      | document_details[0].document_signature_city                       | 257 |
      | document_details[0].document_signature_state                      | 257 |
      | document_details[0].document_sequence_number                      | 257 |
      | document_details[0].document_bounce_memo_reference_number         | 257 |
      | document_details[0].document_umrn                                 | 257 |
      | loan_guarantor[0].loan_guarantor_name                             | 65  |
      | loan_guarantor[0].loan_guarantor_address[0].loan_guarantor_address_text | 257 |
      | loan_guarantor[0].loan_guarantor_city                             | 257 |
      | loan_guarantor[0].loan_guarantor_state                            | 257 |
      | loan_guarantor[0].loan_guarantor_legal_heir                       | 257 |
      | loan_guarantor[0].loan_guarantor_prefix                           | 13  |
      | relation_with_applicant                                           | 257 |
      | references[0].name                                                | 65  |
      | references[0].reference_pan_number                                | 11  |
      | references[0].reference_address[0].reference_address_text         | 257 |
      | references[0].reference_city                                     | 257 |
      | references[0].reference_state                                    | 257 |




  @datatype-validation @text @negative @creator
  Scenario Outline: Text field should reject numeric-only values
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    
    Examples:
      | field_path              | invalid_value |
      | applicant_name          | 123456        |
      | applicant_occupation    | 999           |




  @datatype-validation @boolean @negative @creator
  Scenario Outline: Boolean field should reject invalid boolean values
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    
    Examples:
      | field_path        | invalid_value |
      | tenure_finished   | 1             |
      | tenure_finished   | 0             |
      | tenure_finished   | yes           |
      | tenure_finished   | no            |
      | backed_by_security| 1             |
      | backed_by_security| 0              |


  @datatype-validation @integer @negative @creator
  Scenario Outline: Integer field should reject decimal values
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    
    Examples:
      | field_path          | invalid_value |
      | loan_tenure         | 12.5          |
      | default_emi_number  | 5.99          |
      | applicant_cibil_score| 750.5        |

  @datatype-validation @integer @negative @creator
  Scenario Outline: Integer field should reject negative values
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    
    Examples:
      | field_path          | invalid_value |
      | loan_tenure         | -10           |
      | default_emi_number  | -5            |

  @datatype-validation @integer @negative @creator
  Scenario: CIBIL score should reject values outside 300-900 range
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "applicant_cibil_score" to "250"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @datatype-validation @integer @negative @creator
  Scenario: CIBIL score should reject values above 900
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "applicant_cibil_score" to "950"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201


  @datatype-validation @amount @negative @creator
  Scenario Outline: Amount field should reject negative values
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    
    Examples:
      | field_path              | invalid_value |
      | total_loan_amount       | -50000        |
      | applicant_monthly_income| -10000        |
      | emi_amount              | -6000         |

  @datatype-validation @amount @negative
  Scenario Outline: Amount field should reject scientific notation
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    
    Examples:
      | field_path        | invalid_value |
      | total_loan_amount | 1.23E+11      |
      | emi_amount        | 5.5E+2        |

  @datatype-validation @amount @negative
  Scenario: Amount field should reject values with more than 2 decimal places
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "total_loan_amount" to "50000.999"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @datatype-validation @percentage @negative
  Scenario: Percentage field should reject values above 100
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "interest_on_loan" to "150.5"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @datatype-validation @percentage @negative
  Scenario: Percentage field should reject negative values
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "interest_on_loan" to "-10.5"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201


  @datatype-validation @mobile @negative
  Scenario Outline: Mobile number should reject invalid formats
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    
    Examples:
      | field_path                    | invalid_value      |
      | applicant_contact_number      | 123                |
      | applicant_contact_number      | 12345              |
      | applicant_contact_number      | 998877665544332211 |
      | applicant_contact_number      | 9988776655         |
      | applicant_contact_number      | +919988776655      |


  @datatype-validation @email @negative
  Scenario Outline: Email should reject invalid email formats
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    
    Examples:
      | field_path        | invalid_value              |
      | applicant_email   | invalid-email              |
      | applicant_email   | user@@domain.com           |
      | applicant_email   | user..name@domain.com      |
      | applicant_email   | @domain.com                |


  @datatype-validation @pincode @negative
  Scenario Outline: Pincode should reject invalid formats
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "applicant_address[0].applicant_pincode" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    
    Examples:
      | invalid_value |
      | 1234          |
      | 123456789     |
      | 12345         |
      | ABC123        |


  @datatype-validation @url @negative
  Scenario: URL should reject values not starting with http:// or https://
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "applicant_photo_link" to "www.example.com"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @datatype-validation @url @negative
  Scenario: URL should reject invalid URL formats
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "applicant_photo_link" to "http://invalid..url.com"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201


  @datatype-validation @date @negative
  Scenario Outline: Date should reject invalid date formats
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    
    Examples:
      | field_path             | invalid_value  |
      | applicant_dob          | 24-11-1998     |
      | applicant_dob          | 1998/11/24     |
      | client_loan_sanction_date | 01-01-2021  |
      | allocation_month       | 2021/01/01     |

  @datatype-validation @date @negative
  Scenario: Date should reject invalid dates (e.g., invalid month)
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "applicant_dob" to "1998-13-24"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400


  @datatype-validation @positive @smoke
  Scenario: API should accept request with all valid datatypes
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201


  @datatype-validation @text @positive
  Scenario Outline: Text field should accept null values
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to null
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                                |
      | client_customer_id                        |
      | loan_type                                 |
      | applicant_name                            |
      | applicant_dob                             |
      | applicant_email                           |
      | applicant_gender                          |
      | applicant_contact_number                  |
      | applicant_occupation                      |
      | applicant_aadhar_number                   |
      | applicant_language                        |
      | applicant_pan_number                      |
      | client_loan_sanction_date                 |
      | loan_end_date                             |
      | tenure_finished                           |
      | security_type                             |
      | backed_by_surety                          |
      | loan_nbfc_name                            |
      | loan_nbfc_cin                             |
      | product_type                              |
      | credit_account_number                     |
      | credit_account_holder_name                |
      | credit_bank_name                          |
      | credit_account_holder_type                |
      | credit_bank_ifsc_code                     |
      | business_name                             |
      | security_mode                             |
      | document_number                           |
      | document_bank_name                        |
      | document_bank_ifsc_code                   |
      | document_signature_name                   |
      | document_bounce_bank_account_number       |
      | document_bounce_bank_ifsc_code            |
      | document_bounce_bank_name                 |
      | document_bounce_bank_address              |
      | reason_of_document_bounce                 |
      | document_bounce_memo_reference_number     |
      | document_sequence_number                  |
      | applicant_address_type                    |
      | applicant_address_text                    |
      | applicant_city                            |
      | applicant_state                           |
      | allocation_month                          |
      | date_of_default                           |
      | co_applicant_dob                          |
      | co_applicant_name                         |
      | co_applicant_type                         |
      | co_applicant_email                        |
      | co_applicant_gender                       |
      | co_applicant_language                     |
      | co_applicant_pan_number                   |
      | co_applicant_contact_number               |
      | co_applicant_notice_reference_number      |
      | co_applicant_city                         |
      | co_applicant_state                        |
      | co_applicant_address_text                 |
      | co_applicant_address_type                 |


  @datatype-validation @text @positive
  Scenario Outline: Text field should accept empty string values
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "<field_path>" to ""
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                                |
      | client_customer_id                        |
      | loan_type                                 |
      | applicant_name                            |
      | applicant_dob                             |
      | applicant_email                           |
      | applicant_gender                          |
      | applicant_contact_number                  |
      | applicant_occupation                      |
      | applicant_aadhar_number                   |
      | applicant_language                        |
      | applicant_pan_number                      |
      | client_loan_sanction_date                 |
      | loan_end_date                             |
      | tenure_finished                           |
      | security_type                             |
      | backed_by_surety                          |
      | loan_nbfc_name                            |
      | loan_nbfc_cin                             |
      | product_type                              |
      | credit_account_number                     |
      | credit_account_holder_name                |
      | credit_bank_name                          |
      | credit_account_holder_type                |
      | credit_bank_ifsc_code                     |
      | business_name                             |
      | security_mode                             |
      | document_number                           |
      | document_bank_name                        |
      | document_bank_ifsc_code                   |
      | document_signature_name                   |
      | document_bounce_bank_account_number       |
      | document_bounce_bank_ifsc_code            |
      | document_bounce_bank_name                 |
      | document_bounce_bank_address              |
      | reason_of_document_bounce                 |
      | document_bounce_memo_reference_number     |
      | document_sequence_number                  |
      | applicant_address_type                    |
      | applicant_address_text                    |
      | applicant_city                            |
      | applicant_state                           |
      | allocation_month                          |
      | date_of_default                           |
      | co_applicant_dob                          |
      | co_applicant_name                         |
      | co_applicant_type                         |
      | co_applicant_email                        |
      | co_applicant_gender                       |
      | co_applicant_language                     |
      | co_applicant_pan_number                   |
      | co_applicant_contact_number               |
      | co_applicant_notice_reference_number      |
      | co_applicant_city                         |
      | co_applicant_state                        |
      | co_applicant_address_text                 |
      | co_applicant_address_type                 |


  @api @db-validation @loan-recovery @datatype-validation
  Scenario Outline: Persisted loan recovery fields should have correct datatype in DB
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And DB column "<db_column>" in table "<db_table>" should have datatype "<db_type>" and match API field "<json_path>" for loan "{LOAN_ID}"

    Examples:
      | db_table               | db_column               | db_type   | json_path                     |
      | lending_loan_details   | loan_id                 | VARCHAR   | loan_id                       |
      | lending_loan_details   | total_loan_amount       | NUMERIC   | total_loan_amount             |
      | lending_loan_details   | emi_amount              | NUMERIC   | emi_amount                    |
      | lending_loan_details   | applicant_cibil_score   | INTEGER   | applicant_cibil_score         |
      | lending_loan_details   | tenure_finished         | BOOLEAN   | tenure_finished               |
      | lending_loan_details   | interest_on_loan        | NUMERIC   | interest_on_loan              |
      | lending_loan_details   | applicant_email         | VARCHAR   | applicant_email               |

