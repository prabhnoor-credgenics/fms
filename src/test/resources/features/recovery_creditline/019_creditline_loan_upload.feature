@api @creditline @recovery @creditline-loan-upload
Feature: Credit-line single transaction (quick) upload — POST /recovery/v1/loan/{loan_id}
  # Credit-line product (company_type == "credit line"). Single-record "quick_upload" of a
  # transaction via the shared loan-upload endpoint. For a credit-line company the record identity
  # is `transaction_id`; the id in the URI path and the `transaction_id` in the payload MUST be the
  # same value or the API rejects the request. Both are driven by the scenario-unique {LOAN_ID}, so
  # every scenario uploads under its own non-colliding id.
  #
  # Body serializer mirrors the loan-upload object (applicant / co_applicant / defaults /
  # document_details / loan_guarantor / references arrays) with source == "quick_upload".
  # Reusable payload: test-data/creditline/creditline_loan_recovery_request.json.
  #
  # Success envelope (observed on staging): HTTP 201
  #   {"success": true, "message": "Data uploaded successfully", "data": null, "output": {"error": null}}
  # auto-validated against schemas/recovery/success/loan_recovery_success_schema.json.
  #
  # VALIDATION SCOPE (verified on staging 2026-07-22): the credit-line quick-upload path enforces
  # far fewer field rules than the lending loan-upload endpoint. It DOES enforce: identity
  # (transaction_id present / <=64 / path==payload), auth/company gate, mobile & email format,
  # date format, booleans, numeric-only text, and special-char/length rules on the id-like fields
  # (client_customer_id, group_id) plus max length on loan_nbfc_name/product_type/loan_type. It does
  # NOT enforce: integer/amount/percentage/CIBIL-range rules, URL format, pincode length, and
  # special-chars / over-length on most descriptive text fields — those are accepted (201). Scenarios
  # documenting the accepted-but-"invalid" behaviour are grouped under "not enforced" outlines.

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the query parameters:
      | replace_previous_data | false |
      | replace_given_data    | false |

  # ============================================================================
  # Auth & permission
  # ============================================================================

  @negative @creditline @creator
  Scenario: Upload without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/recovery/error/loan_recovery_error_schema.json"

  @negative @creditline @creator
  Scenario: Upload with an invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/loan_recovery_error_schema.json"

  @negative @creditline @creator
  Scenario: Upload with company_id query parameter missing returns 403
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 403
    And the response should match json schema "schemas/recovery/error/loan_recovery_error_schema.json"

  # ============================================================================
  # Happy path
  # ============================================================================

  @positive @smoke @creditline @creator
  Scenario: Valid single transaction upload returns 201
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response message should be "Data uploaded successfully"
    And the response body should contain field "success"
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"

  @positive @creditline @creator
  Scenario: Minimal transaction upload (only identity + one default) returns 201
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body:
      """
      {
        "transaction_id": "{LOAN_ID}",
        "client_customer_id": "Client_Customer_Id_1",
        "defaults": [ { "allocation_month": "{ALLOCATION_MONTH}", "total_outstanding_amount": "10098.98" } ],
        "source": "quick_upload"
      }
      """
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  @positive @creditline @creator
  Scenario Outline: Upload honours each replace-flag combination and returns 201
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id            | {COMPANY_ID}            |
      | replace_previous_data | <replace_previous_data> |
      | replace_given_data    | <replace_given_data>    |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | replace_previous_data | replace_given_data |
      | false                 | false              |
      | true                  | false              |
      | false                 | true               |

  # ============================================================================
  # Path / payload id matching (enforced)
  # ============================================================================

  @negative @creditline @creator
  Scenario: URI id and payload transaction_id mismatch returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | different_transaction_id |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/loan_recovery_error_schema.json"

  @negative @creditline @creator
  Scenario: Null transaction_id in payload returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "transaction_id" to null
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @negative @creditline @creator @boundary
  Scenario: transaction_id exceeding max length of 64 returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {RANDOM_STRING:65} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "transaction_id" to "{RANDOM_STRING:65}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @positive @creditline @creator @boundary
  Scenario: transaction_id containing allowed special characters is accepted (201)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | txn_123-ABC/45 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "transaction_id" to "txn_123-ABC/45"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

  # ============================================================================
  # ENFORCED validations (return 400)
  # ============================================================================

  @datatype-validation @text @special-characters @negative @creditline @creator
  Scenario Outline: Id-like text fields reject disallowed special characters (enforced)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

    Examples:
      | field_path         | invalid_value |
      | client_customer_id | cust\|/01     |
      | group_id           | group{\|}     |

  @datatype-validation @text @negative @creditline @creator @boundary
  Scenario Outline: Text fields with an enforced max length reject over-length values (400)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "{RANDOM_STRING:<max_length_plus>}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

    Examples:
      | field_path         | max_length_plus |
      | client_customer_id | 65              |
      | loan_nbfc_name     | 257             |
      | product_type       | 257             |
      | loan_type          | 257             |

  @datatype-validation @text @negative @creditline @creator
  Scenario Outline: Text field rejects numeric-only values (400)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

    Examples:
      | field_path           | invalid_value |
      | applicant_name       | 123456        |
      | applicant_occupation | 999           |

  @datatype-validation @boolean @negative @creditline @creator
  Scenario Outline: Boolean field rejects non-boolean values (400)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

    Examples:
      | field_path         | invalid_value |
      | tenure_finished    | yes           |
      | tenure_finished    | no            |
      | backed_by_security | maybe         |

  @datatype-validation @mobile @negative @creditline @creator
  Scenario Outline: Mobile number rejects invalid formats (400)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "applicant_contact_details[0].applicant_contact_number" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

    Examples:
      | invalid_value      |
      | 123                |
      | 12345              |
      | 998877665544332211 |
      | +919988776655      |

  @datatype-validation @email @negative @creditline @creator
  Scenario Outline: Email rejects invalid formats (400)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "applicant_email_details[0].applicant_email" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

    Examples:
      | invalid_value         |
      | invalid-email         |
      | user@@domain.com      |
      | user..name@domain.com |
      | @domain.com           |

  @datatype-validation @pincode @negative @creditline @creator
  Scenario: Pincode rejects non-numeric value (400)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "applicant_address[0].applicant_pincode" to "ABC123"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

  @datatype-validation @date @negative @creditline @creator
  Scenario Outline: Date field rejects invalid date formats (400)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<invalid_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 400

    Examples:
      | field_path                   | invalid_value |
      | applicant_dob                | 24-11-1998    |
      | applicant_dob                | 1998/11/24    |
      | applicant_dob                | 1998-13-24    |
      | client_loan_sanction_date    | 01-01-2021    |
      | defaults[0].allocation_month | 2021/01/01    |

  # ============================================================================
  # Positive: text fields accept allowed special characters (201)
  # ============================================================================

  @datatype-validation @text @special-characters @positive @creditline @creator
  Scenario Outline: Text fields accept values containing allowed special characters (201)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<allowed_value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                                    | allowed_value            |
      | client_customer_id                            | cust_01-AZ               |
      | group_id                                      | group_01-A               |
      | center_name                                   | Center-1 (Noida) @Sector |
      | loan_region                                   | North-East (Zone-1)      |
      | loan_zone                                     | Zone-2 (East)            |
      | loan_branch                                   | Branch-01 (Noida)        |
      | loan_regional_manager_name                    | Rajesh.Kumar             |
      | loan_source_branch_address                    | S-48/Sector-62 (Noida)   |
      | loan_nbfc_name                                | NBFC-Name (India)        |
      | notice_delivery_partner                       | Blue-Dart (India)        |
      | product_type                                  | Car-Loan/Personal        |
      | loan_type                                     | Home-Loan                |
      | business_name                                 | Biz_Name-1@India         |
      | channel_partner                               | Partner_01#India         |
      | credit_account_holder_name                    | Aman.Sharma              |
      | credit_bank_name                              | State_Bank@India         |
      | merchant_name                                 | PayPal.India             |
      | applicant_name                                | Ramesh.Kumar             |
      | applicant_occupation                          | Govt-Employee (Group-A)  |
      | applicant_address[0].applicant_address_text   | H-12/45, Sector-62       |
      | applicant_address[0].applicant_city           | New-Delhi                |
      | applicant_address[0].applicant_landmark       | Near-Metro/Gate-3        |
      | co_applicant[0].co_applicant_name             | Suresh.Verma             |
      | document_details[0].document_number           | DOC-123/2024             |
      | document_details[0].document_bounce_bank_address | H-No-10, New-Delhi    |
      | loan_guarantor[0].loan_guarantor_name         | Mohan.Lal                |
      | references[0].name                            | Test.Reference           |
      | references[0].relation_with_applicant         | Father                   |

  # ============================================================================
  # NOT ENFORCED by credit-line quick upload — accepted with 201
  # (documented staging gap vs the lending loan-upload endpoint)
  # ============================================================================

  @datatype-validation @text @special-characters @positive @creditline @creator @not-enforced
  Scenario Outline: Descriptive text fields accept disallowed special characters (not enforced, 201)
    # TODO: verify on staging — quick upload does not enforce the char-set rule on these fields (returns 201).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                 | value          |
      | center_name                | Center~Name    |
      | loan_region                | North\|Zone    |
      | loan_zone                  | Zone\\East     |
      | loan_branch                | Branch`01      |
      | loan_regional_manager_name | Rajesh\|Kumar  |
      | loan_nbfc_name             | NBFC^Name      |
      | product_type               | Car#Loan^      |
      | loan_type                  | Home~Loan      |
      | business_name              | Biz{name}      |
      | channel_partner            | Partner\|01    |
      | credit_bank_name           | Bank{Name}     |
      | merchant_name              | PayPal~India   |
      | applicant_name             | Ramesh<>       |
      | applicant_occupation       | Govt\|Employee |

  @datatype-validation @text @positive @creditline @creator @not-enforced @boundary
  Scenario Outline: Text fields accept over-length values (max length not enforced, 201)
    # TODO: verify on staging — quick upload does not enforce max length on these fields (returns 201).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "{RANDOM_STRING:<length>}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                                  | length |
      | group_id                                    | 65     |
      | center_name                                 | 257    |
      | loan_region                                 | 257    |
      | loan_zone                                   | 257    |
      | loan_branch                                 | 257    |
      | loan_regional_manager_name                  | 65     |
      | loan_source_branch_address                  | 257    |
      | business_name                               | 257    |
      | credit_account_holder_name                  | 65     |
      | credit_bank_ifsc_code                       | 12     |
      | credit_bank_name                            | 257    |
      | merchant_name                               | 65     |
      | applicant_name                              | 65     |
      | applicant_occupation                        | 65     |
      | applicant_pan_number                        | 11     |
      | applicant_aadhar_number                     | 13     |
      | applicant_address[0].applicant_address_text | 257    |
      | applicant_address[0].applicant_city         | 257    |
      | applicant_address[0].applicant_state        | 257    |
      | co_applicant[0].co_applicant_name           | 65     |
      | co_applicant[0].co_applicant_pan_number     | 11     |
      | document_details[0].document_number         | 257    |
      | document_details[0].document_bank_ifsc_code | 12     |
      | references[0].name                          | 65     |
      | references[0].reference_pan_number          | 11     |
      | loan_guarantor[0].loan_guarantor_name       | 65     |

  @datatype-validation @integer @amount @percentage @positive @creditline @creator @not-enforced
  Scenario Outline: Numeric fields accept decimal / negative / out-of-range values (not enforced, 201)
    # TODO: verify on staging — quick upload does not enforce integer/amount/percentage/CIBIL rules (returns 201).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                     | value     |
      | loan_tenure                    | 12.5      |
      | defaults[0].default_emi_number | 5.99      |
      | applicant_cibil_score          | 750.5     |
      | loan_tenure                    | -10       |
      | defaults[0].default_emi_number | -5        |
      | applicant_cibil_score          | 250       |
      | applicant_cibil_score          | 950       |
      | total_loan_amount              | -50000    |
      | applicant_monthly_income       | -10000    |
      | emi_amount                     | -6000     |
      | defaults[0].settlement_amount  | -9098.98  |
      | total_loan_amount              | 1.23E+11  |
      | emi_amount                     | 5.5E+2    |
      | total_loan_amount              | 50000.999 |
      | interest_on_loan               | 150.5     |
      | interest_on_loan               | -10.5     |

  @datatype-validation @pincode @url @positive @creditline @creator @not-enforced
  Scenario Outline: Pincode length and URL format are not enforced (accepted, 201)
    # TODO: verify on staging — quick upload accepts wrong-length pincodes and malformed URLs (returns 201).
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to "<value>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                              | value                   |
      | applicant_address[0].applicant_pincode  | 1234                    |
      | applicant_address[0].applicant_pincode  | 123456789               |
      | applicant_photo_link                    | www.example.com         |
      | applicant_photo_link                    | http://invalid..url.com |

  # ============================================================================
  # Null / empty acceptance for optional text fields (201)
  # ============================================================================

  @datatype-validation @text @positive @creditline @creator
  Scenario Outline: Optional text field accepts null (201)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to null
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path                        |
      | loan_type                         |
      | business_name                     |
      | center_name                       |
      | channel_partner                   |
      | merchant_name                     |
      | loan_region                       |
      | loan_zone                         |
      | loan_branch                       |
      | notice_delivery_partner           |
      | applicant_legal_heir              |
      | applicant_notice_reference_number |
      | credit_bank_name                  |
      | credit_account_holder_type        |

  @datatype-validation @text @positive @creditline @creator
  Scenario Outline: Optional text field accepts empty string (201)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "<field_path>" to ""
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201

    Examples:
      | field_path              |
      | loan_type               |
      | business_name           |
      | center_name             |
      | channel_partner         |
      | merchant_name           |
      | loan_region             |
      | loan_zone               |
      | notice_delivery_partner |

  # ============================================================================
  # Multi-step: upload then read the transaction back
  # ============================================================================

  @positive @creditline @creator @multistep @env-blocked
  Scenario: Upload a transaction then read it back via transaction details
    # TODO: verify on staging — creditline company data/config dependent; upload + read-back chain.
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creator0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I wait for 5 seconds
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | transaction_id | {LOAN_ID} |
    When I send a "GET" request to "/recovery/transaction/details/{transaction_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
