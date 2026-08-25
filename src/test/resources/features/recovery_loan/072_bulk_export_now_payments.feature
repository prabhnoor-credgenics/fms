@api @export-now-bulk-payments @recovery @pod1
Feature: Export Now Bulk Loan Details API — POST /recovery/export-now/payments


  @negative @smoke
  Scenario: TC-AUTH-001 — Request without authenticationtoken header returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/export-now/payments"
    Then the response status code should be 400
    And the response body should contain field "message" as "auto" with value "invalid authentication token"

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/export-now/payments"
    Then the response status code should be 400

  @positive @smoke @regression
  Scenario Outline: Validate normal export now loan for the new uploaded loan for product_type,loan_type,loan_region,applicant_city,applicant_state
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
    And I set the request body from file "test-data/recovery_loan/bulk_loan_upload.json"
    And I update JSON field "loan_data[0].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan2}" and remember as "loan_id_2"
    And I update JSON field "loan_data[0].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "loan_data[0].<field_path>" as "auto" to "{RANDOM_STRING:6}" and remember as "<field_value>"
    And I update JSON field "loan_data[1].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan3}" and remember as "loan_id_3"
    And I update JSON field "loan_data[1].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "loan_data[1].<field_path>" as "auto" to "{CAPTURED:<field_value>}"
    When I send a "POST" request to "/recovery/v1/bulk/loan-upload"
    Then the response status code should be 202
    And the response body should contain field "success" as "auto" with value "true"
    And the response body should contain field "message" as "auto" with value "Upload Request Initiated Successfully"
    And the response body should contain field "error" as "auto" with value "null"
    And the response body should contain field "message_template" as "auto" with value "Upload Request Initiated Successfully"
    And the response body should contain field "message_placeholder" as "auto" with value "null"
    And I capture response field "data.request_id" as "request_id_for_upload"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | {AUTH_TOKEN}      |
    And I set the query parameters:
      | company_id              | {COMPANY_ID}       |
    And I set the path parameters:
      | request_id              | {CAPTURED:request_id_for_upload}  |
    When I poll a "GET" request to "/recovery/bulk/tasks/{request_id}" until the response body contains field "output.status" as "auto" with value "Completed"
    Then the response status code should be 200
    And the response body should contain field "output.created_by.full_name" as "auto" with value "{USER_NAME:creator0}"
    And the response body should contain field "output.status" as "auto" with value "Completed"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {CAPTURED:loan_id_2} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
    And I set the request body from file "test-data/recovery_loan/payment_update.json"
    And I update JSON field "amount_recovered" as "auto" to "1000"
    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_2}"
    And the response body should contain field "output" as "string" with value "Data updated successfully"
    And the response body should contain field "message" as "string" with value "success"
    And the response body should contain field "message_template" as "string" with value "success"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {CAPTURED:loan_id_3} |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
    And I set the request body from file "test-data/recovery_loan/payment_update.json"
    And I update JSON field "amount_recovered" as "auto" to "1000"
    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_3}"
    And the response body should contain field "output" as "string" with value "Data updated successfully"
    And the response body should contain field "message" as "string" with value "success"
    And the response body should contain field "message_template" as "string" with value "success"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
#      | include_computed_variables | false        |
#      | include_meta_data          | false        |
    And I set the request body from file "test-data/recovery_loan/export_now_loan.json"
    And I add JSON field "<field_value>" as "list" with value "[\"{CAPTURED:<field_value>}\"]"
    And I update JSON field "allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "company_id" as "auto" to "{COMPANY_ID}"
    When I send a "POST" request to "/recovery/export-now/payments"
    Then the response status code should be 200
    And I capture response field "data.document_link" as "presigned_url_1"
    When I download file from absolute url "{CAPTURED:presigned_url_1}" as "export_loan" with extension "xlsx"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_2}" has "Client Customer Id" as "'Client_Customer_Id_1"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_3}" has "Client Customer Id" as "'Client_Customer_Id_1"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_2}" has "Allocation Month" as "2026-8-01"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_3}" has "Allocation Month" as "2026-8-01"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_2}" has "Amount Recovered" as "1000.00"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_3}" has "Amount Recovered" as "1000.00"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_2}" has "Recovery Method" as "platform"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_3}" has "Recovery Method" as "platform"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_2}" has "Recovered By" as "{USER_NAME:creator0}"
    Then I validate Excel where "Loan Id" is "'{CAPTURED:loan_id_3}" has "Recovered By" as "{USER_NAME:creator0}"
    And I clear the loaded excel
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{CAPTURED:loan_id_2}","{CAPTURED:loan_id_3}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200

    Examples:
      | field_path                                                              | field_value              |  csv_column |
      | product_type                                                            | product_type             |  product_type |
      | loan_type                                                               | loan_type                |  loan_type |
#      | tags                                                                    | tags                     |  tags |
      | loan_region                                                             | loan_region              |  loan_region |
      | applicant_address[0].applicant_city                                     | applicant_city           |  applicant_city_1 |
      | applicant_address[0].applicant_state                                    | applicant_state          |  applicant_state_1 |
#      | applicant_address[0].applicant_pincode                                  | applicant_pincode        |  applicant_pincode_1 |


#  @positive @smoke @regression
#  Scenario: Validate normal export now loan for the new uploaded loan for applicant_pincode
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#    And I set the request body from file "test-data/recovery_loan/bulk_loan_upload.json"
#    And I update JSON field "loan_data[0].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan2}" and remember as "loan_id_2"
#    And I update JSON field "loan_data[0].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "loan_data[0].applicant_address[0].applicant_pincode" as "auto" to "{RANDOM_INT:100000:999999}" and remember as "applicant_pincode"
#    And I update JSON field "loan_data[1].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan3}" and remember as "loan_id_3"
#    And I update JSON field "loan_data[1].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "loan_data[1].applicant_address[0].applicant_pincode" as "auto" to "{CAPTURED:applicant_pincode}"
#    When I send a "POST" request to "/recovery/v1/bulk/loan-upload"
#    Then the response status code should be 202
#    And the response body should contain field "success" as "auto" with value "true"
#    And the response body should contain field "message" as "auto" with value "Upload Request Initiated Successfully"
#    And the response body should contain field "error" as "auto" with value "null"
#    And the response body should contain field "message_template" as "auto" with value "Upload Request Initiated Successfully"
#    And the response body should contain field "message_placeholder" as "auto" with value "null"
#    And I capture response field "data.request_id" as "request_id_for_upload"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN}      |
#    And I set the query parameters:
#      | company_id              | {COMPANY_ID}       |
#    And I set the path parameters:
#      | request_id              | {CAPTURED:request_id_for_upload}  |
#    When I poll a "GET" request to "/recovery/bulk/tasks/{request_id}" until the response body contains field "output.status" as "auto" with value "Completed"
#    Then the response status code should be 200
#    And the response body should contain field "output.created_by.full_name" as "auto" with value "{USER_NAME:creator0}"
#    And the response body should contain field "output.status" as "auto" with value "Completed"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {CAPTURED:loan_id_2} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_2}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {CAPTURED:loan_id_3} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_3}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
##      | include_computed_variables | false        |
##      | include_meta_data          | false        |
#    And I set the request body from file "test-data/recovery_loan/export_now_loan.json"
#    And I add JSON field "applicant_pincode" as "list" with value "[\"{CAPTURED:applicant_pincode}\"]"
#    And I update JSON field "allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "company_id" as "auto" to "{COMPANY_ID}"
#    When I send a "POST" request to "/recovery/export-now/payments"
#    Then the response status code should be 200
#    And I capture response field "data.document_link" as "presigned_url_1"
#    When I download file from absolute url "{CAPTURED:presigned_url_1}" as "export_loan" with extension "xlsx"
#    Then I validate Excel where "Loan Id" is "{CAPTURED:loan_id_2}" has "applicant_pincode_1" as "{CAPTURED:applicant_pincode}"
#    Then I validate Excel where "Loan Id" is "{CAPTURED:loan_id_3}" has "applicant_pincode_1" as "{CAPTURED:applicant_pincode}"
#    And I clear the loaded excel
#    And I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}",
#        "category": "loan",
#        "operation_type": "archive",
#        "data": ["{CAPTURED:loan_id_2}","{CAPTURED:loan_id_3}"],
#        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
#        "execution_mode": "real-time"
#      }
#      """
#    When I send a "POST" request to "/recovery/data-operations"
#    Then the response status code should be 200
#
#
#
#  @positive @smoke @regression @total_claim_amount
#  Scenario Outline: Validate normal export now loan for the new uploaded loan for tags
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#    And I set the request body from file "test-data/recovery_loan/bulk_loan_upload.json"
#    And I update JSON field "loan_data[0].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan2}" and remember as "loan_id_2"
#    And I update JSON field "loan_data[0].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "loan_data[0].defaults.<field_path>" as "double" to "{RANDOM_INT:100000:999999}.{RANDOM_INT:1:9}" and remember as "<field_value>"
#    And I update JSON field "loan_data[1].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan3}" and remember as "loan_id_3"
#    And I update JSON field "loan_data[1].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "loan_data[1].defaults.<field_path>" as "double" to "{CAPTURED:<field_value>}"
#    When I send a "POST" request to "/recovery/v1/bulk/loan-upload"
#    Then the response status code should be 202
#    And the response body should contain field "success" as "auto" with value "true"
#    And the response body should contain field "message" as "auto" with value "Upload Request Initiated Successfully"
#    And the response body should contain field "error" as "auto" with value "null"
#    And the response body should contain field "message_template" as "auto" with value "Upload Request Initiated Successfully"
#    And the response body should contain field "message_placeholder" as "auto" with value "null"
#    And I capture response field "data.request_id" as "request_id_for_upload"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN}      |
#    And I set the query parameters:
#      | company_id              | {COMPANY_ID}       |
#    And I set the path parameters:
#      | request_id              | {CAPTURED:request_id_for_upload}  |
#    When I poll a "GET" request to "/recovery/bulk/tasks/{request_id}" until the response body contains field "output.status" as "auto" with value "Completed"
#    Then the response status code should be 200
#    And the response body should contain field "output.created_by.full_name" as "auto" with value "{USER_NAME:creator0}"
#    And the response body should contain field "output.status" as "auto" with value "Completed"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {CAPTURED:loan_id_2} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_2}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {CAPTURED:loan_id_3} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_3}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
##      | include_computed_variables | false        |
##      | include_meta_data          | false        |
#    And I set the request body from file "test-data/recovery_loan/export_now_loan.json"
#    And I add JSON field "<field_path>_from" as "string" with value "1"
#    And I add JSON field "<field_path>_to" as "string" with value "1000000"
#    And I update JSON field "allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "company_id" as "auto" to "{COMPANY_ID}"
#    When I send a "POST" request to "/recovery/export-now/payments"
#    Then the response status code should be 200
#    And I capture response field "data.document_link" as "presigned_url_1"
#    When I download file from absolute url "{CAPTURED:presigned_url_1}" as "export_loan" with extension "xlsx"
#    Then I validate Excel where "Loan Id" is "{CAPTURED:loan_id_2}" has "<field_path>" as "{CAPTURED:<field_value>}"
#    Then I validate Excel where "Loan Id" is "{CAPTURED:loan_id_3}" has "<field_path>" as "{CAPTURED:<field_value>}"
#    And I clear the loaded excel
#    And I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}",
#        "category": "loan",
#        "operation_type": "archive",
#        "data": ["{CAPTURED:loan_id_2}","{CAPTURED:loan_id_3}"],
#        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
#        "execution_mode": "real-time"
#      }
#      """
#    When I send a "POST" request to "/recovery/data-operations"
#    Then the response status code should be 200
#
#    Examples:
#      | field_path                                                              | field_value                     |
#      | total_claim_amount                                                      |   total_claim_amount            |
#      | principal_outstanding_amount                                            |   principal_outstanding_amount  |
#
#  @positive @smoke @regression
#  Scenario: Validate normal export now loan for the new uploaded loan for date_of_default
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#    And I set the request body from file "test-data/recovery_loan/bulk_loan_upload.json"
#    And I update JSON field "loan_data[0].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan2}" and remember as "loan_id_2"
#    And I update JSON field "loan_data[0].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "loan_data[0].defaults.date_of_default" as "string" to "{NOW_OFFSET:-7:days:iso_date}" and remember as "date_of_default"
#    And I update JSON field "loan_data[1].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan3}" and remember as "loan_id_3"
#    And I update JSON field "loan_data[1].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "loan_data[1].defaults.date_of_default" as "string" to "{CAPTURED:date_of_default}"
#    When I send a "POST" request to "/recovery/v1/bulk/loan-upload"
#    Then the response status code should be 202
#    And the response body should contain field "success" as "auto" with value "true"
#    And the response body should contain field "message" as "auto" with value "Upload Request Initiated Successfully"
#    And the response body should contain field "error" as "auto" with value "null"
#    And the response body should contain field "message_template" as "auto" with value "Upload Request Initiated Successfully"
#    And the response body should contain field "message_placeholder" as "auto" with value "null"
#    And I capture response field "data.request_id" as "request_id_for_upload"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN}      |
#    And I set the query parameters:
#      | company_id              | {COMPANY_ID}       |
#    And I set the path parameters:
#      | request_id              | {CAPTURED:request_id_for_upload}  |
#    When I poll a "GET" request to "/recovery/bulk/tasks/{request_id}" until the response body contains field "output.status" as "auto" with value "Completed"
#    Then the response status code should be 200
#    And the response body should contain field "output.created_by.full_name" as "auto" with value "{USER_NAME:creator0}"
#    And the response body should contain field "output.status" as "auto" with value "Completed"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {CAPTURED:loan_id_2} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_2}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {CAPTURED:loan_id_3} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_3}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
##      | include_computed_variables | false        |
##      | include_meta_data          | false        |
#    And I set the request body from file "test-data/recovery_loan/export_now_loan.json"
#    And I add JSON field "date_of_default_from" as "string" with value "{NOW_OFFSET:-8:days:iso_date}"
#    And I add JSON field "date_of_default_to" as "string" with value "{NOW_OFFSET:7:days:iso_date}"
#    And I update JSON field "allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "company_id" as "auto" to "{COMPANY_ID}"
#    When I send a "POST" request to "/recovery/export-now/payments"
#    Then the response status code should be 200
#    And I capture response field "data.document_link" as "presigned_url_1"
#    When I download file from absolute url "{CAPTURED:presigned_url_1}" as "export_loan" with extension "xlsx"
#    Then I validate Excel where "Loan Id" is "{CAPTURED:loan_id_2}" has "date_of_default" as "{CAPTURED:date_of_default}"
#    Then I validate Excel where "Loan Id" is "{CAPTURED:loan_id_3}" has "date_of_default" as "{CAPTURED:date_of_default}"
#    And I clear the loaded excel
#    And I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}",
#        "category": "loan",
#        "operation_type": "archive",
#        "data": ["{CAPTURED:loan_id_2}","{CAPTURED:loan_id_3}"],
#        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
#        "execution_mode": "real-time"
#      }
#      """
#    When I send a "POST" request to "/recovery/data-operations"
#    Then the response status code should be 200
#
#
#  @positive @smoke @regression
#  Scenario Outline: Validate normal export now loan for the new uploaded loan for dpd
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#    And I set the request body from file "test-data/recovery_loan/bulk_loan_upload.json"
#    And I update JSON field "loan_data[0].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan2}" and remember as "loan_id_2"
#    And I update JSON field "loan_data[0].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "loan_data[0].defaults.date_of_default" as "string" to "{NOW_OFFSET:-<field_value>:days:iso_date}" and remember as "date_of_default"
#    And I update JSON field "loan_data[1].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan3}" and remember as "loan_id_3"
#    And I update JSON field "loan_data[1].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "loan_data[1].defaults.date_of_default" as "string" to "{CAPTURED:date_of_default}"
#    When I send a "POST" request to "/recovery/v1/bulk/loan-upload"
#    Then the response status code should be 202
#    And the response body should contain field "success" as "auto" with value "true"
#    And the response body should contain field "message" as "auto" with value "Upload Request Initiated Successfully"
#    And the response body should contain field "error" as "auto" with value "null"
#    And the response body should contain field "message_template" as "auto" with value "Upload Request Initiated Successfully"
#    And the response body should contain field "message_placeholder" as "auto" with value "null"
#    And I capture response field "data.request_id" as "request_id_for_upload"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN}      |
#    And I set the query parameters:
#      | company_id              | {COMPANY_ID}       |
#    And I set the path parameters:
#      | request_id              | {CAPTURED:request_id_for_upload}  |
#    When I poll a "GET" request to "/recovery/bulk/tasks/{request_id}" until the response body contains field "output.status" as "auto" with value "Completed"
#    Then the response status code should be 200
#    And the response body should contain field "output.created_by.full_name" as "auto" with value "{USER_NAME:creator0}"
#    And the response body should contain field "output.status" as "auto" with value "Completed"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {CAPTURED:loan_id_2} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_2}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {CAPTURED:loan_id_3} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{CAPTURED:loan_id_3}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
##      | include_computed_variables | false        |
##      | include_meta_data          | false        |
#    And I set the request body from file "test-data/recovery_loan/export_now_loan.json"
#    And I add JSON field "<field_path>_from" as "string" with value "1"
#    And I add JSON field "<field_path>_to" as "string" with value "1000"
#    And I update JSON field "allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "company_id" as "auto" to "{COMPANY_ID}"
#    When I send a "POST" request to "/recovery/export-now/payments"
#    Then the response status code should be 200
#    And I capture response field "data.document_link" as "presigned_url_1"
#    When I download file from absolute url "{CAPTURED:presigned_url_1}" as "export_loan" with extension "xlsx"
#    Then I validate Excel where "Loan Id" is "{CAPTURED:loan_id_2}" has "<field_path>" as "<field_value>"
#    Then I validate Excel where "Loan Id" is "{CAPTURED:loan_id_3}" has "<field_path>" as "<field_value>"
#    And I clear the loaded excel
#    And I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}",
#        "category": "loan",
#        "operation_type": "archive",
#        "data": ["{CAPTURED:loan_id_2}","{CAPTURED:loan_id_3}"],
#        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
#        "execution_mode": "real-time"
#      }
#      """
#    When I send a "POST" request to "/recovery/data-operations"
#    Then the response status code should be 200
#
#
#    Examples:
#      | field_path                 |  field_value |
#      | dpd                        |       7      |
#      | allocation_dpd_value       |       7      |
#
#
##  @positive @smoke @regression
##  Scenario: Validate normal export now loan for the new uploaded loan for not recovered recovery status
##    Given I authenticate as "creator" slot 0 and remember as "creator0"
##    And I set the request headers:
##      | accept              | application/json, text/plain, */* |
##      | authenticationtoken | {AUTH_TOKEN}                      |
##    And I set the path parameters:
##      | loan_id | {LOAN_ID} |
##    And I set the query parameters:
##      | company_id            | {COMPANY_ID} |
##      | replace_previous_data | false        |
##      | replace_given_data    | false        |
##    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
##    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
##    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
##    Then the response status code should be 201
##    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
##    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
##    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
##    Given I prepare a request
##    And I set the request headers:
##      | Content-Type        | application/json  |
##      | authenticationtoken | {AUTH_TOKEN}      |
##    And I set the query parameters:
##      | company_id              | {COMPANY_ID}                |
##      | variable_id             | recovery_status             |
##      | variable_group          | Recovery+Attributes         |
##      | allocation_month        | {ALLOCATION_MONTH_OFFSET:0} |
##      | archive                 | false                       |
##    When I send a "GET" request to "/portfolio-v2/v3/fetch-distinct-value"
##    Then the response status code should be 200
##    Then I extract "value" from array "output.variable_filter_value" using "label" with value "Not Recovered" and remember as "not_recovered_value"
##    Given I prepare a request
##    And I set the request headers:
##      | Content-Type        | application/json  |
##      | authenticationtoken | {AUTH_TOKEN} |
##    And I set the query parameters:
##      | company_id                 | {COMPANY_ID} |
###      | include_computed_variables | false        |
###      | include_meta_data          | false        |
##    And I set the request body from file "test-data/recovery_loan/export_now_loan.json"
##    And I add JSON field "recovery_status" as "string" with value "{CAPTURED:not_recovered_value}"
##    And I update JSON field "allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
##    And I update JSON field "company_id" as "auto" to "{COMPANY_ID}"
##    When I send a "POST" request to "/recovery/export-now/payments"
##    Then the response status code should be 200
##    And I capture response field "data.document_link" as "presigned_url_1"
##    When I download file from absolute url "{CAPTURED:presigned_url_1}" as "export_loan" with extension "xlsx"
##    Then I validate Excel where "Loan Id" is "{LOAN_ID}" has "recovery_status" as "Not Recovered"
##    And I clear the loaded excel
##    And I prepare a request
##    And I set the request headers:
##      | Content-Type        | application/json |
##      | authenticationtoken | {AUTH_TOKEN}     |
##    And I set the request body:
##      """
##      {
##        "company_id": "{COMPANY_ID}",
##        "category": "loan",
##        "operation_type": "archive",
##        "data": ["{LOAN_ID}"],
##        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
##        "execution_mode": "real-time"
##      }
##      """
##    When I send a "POST" request to "/recovery/data-operations"
##    Then the response status code should be 200
#
#  @positive @smoke @regression
#  Scenario Outline: Validate normal export now loan for the new uploaded loan for partial & fully recovered recovery statuses
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {LOAN_ID} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | replace_previous_data | false        |
#      | replace_given_data    | false        |
#    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
#    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
#    Then the response status code should be 201
#    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
#    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
#    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {LOAN_ID} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "<value>"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{LOAN_ID}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN}      |
#    And I set the query parameters:
#      | company_id              | {COMPANY_ID}                |
#      | variable_id             | recovery_status             |
#      | variable_group          | Recovery+Attributes         |
#      | allocation_month        | {ALLOCATION_MONTH_OFFSET:0} |
#      | archive                 | false                       |
#    When I send a "GET" request to "/portfolio-v2/v3/fetch-distinct-value"
#    Then the response status code should be 200
#    Then I extract "value" from array "output.variable_filter_value" using "label" with value "<status>" and remember as "<status>_value"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
##      | include_computed_variables | false        |
##      | include_meta_data          | false        |
#    And I set the request body from file "test-data/recovery_loan/export_now_loan.json"
#    And I add JSON field "recovery_status" as "string" with value "{CAPTURED:<status>_value}"
#    And I update JSON field "allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "company_id" as "auto" to "{COMPANY_ID}"
#    When I send a "POST" request to "/recovery/export-now/payments"
#    Then the response status code should be 200
#    And I capture response field "data.document_link" as "presigned_url_1"
#    When I download file from absolute url "{CAPTURED:presigned_url_1}" as "export_loan" with extension "xlsx"
#    Then I validate Excel where "Loan Id" is "{LOAN_ID}" has "recovery_status" as "<status>"
#    And I clear the loaded excel
#    And I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}",
#        "category": "loan",
#        "operation_type": "archive",
#        "data": ["{LOAN_ID}"],
#        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
#        "execution_mode": "real-time"
#      }
#      """
#    When I send a "POST" request to "/recovery/data-operations"
#    Then the response status code should be 200
#
#    Examples:
#      | status | value|
#      | Partially Recovered | 5000.00 |
#      | Fully Recovered | 10098.98 |
#
#
#  @positive @smoke @regression
#  Scenario Outline: Validate normal export now loan for the new uploaded loan for global statuses
#    Given I authenticate as "creator" slot 0 and remember as "creator0"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {LOAN_ID} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | replace_previous_data | false        |
#      | replace_given_data    | false        |
#    And I set the request body from file "test-data/recovery_loan/loan_quick_upload.json"
#    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
#    Then the response status code should be 201
#    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
#    And the response body should contain field "message" as "string" with value "Data uploaded successfully"
#    And the response body should contain field "message_template" as "string" with value "Data uploaded successfully"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#    And I set the path parameters:
#      | loanId | {LOAN_ID} |
#    And I set the query parameters:
#      | company_id | {COMPANY_ID} |
#      | allocation_month        | {ALLOCATION_MONTH_OFFSET:0} |
#    And I set the request body:
#      """
#      {
#        "module": "global",
#        "status_name": "<status>"
#      }
#      """
#    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
#    Then the response status code should be 200
#    And the response body should contain field "output" as "string" with value "Status updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#    And I set the path parameters:
#      | loan_id | {LOAN_ID} |
#    And I set the query parameters:
#      | company_id            | {COMPANY_ID} |
#      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}        |
#    And I set the request body from file "test-data/recovery_loan/payment_update.json"
#    And I update JSON field "amount_recovered" as "auto" to "1000"
#    And I update JSON field "recovery_date" as "auto" to "{NOW_OFFSET:0:days:iso_date}"
#    And I update JSON field "recovered_by" as "auto" to "{USER_ID:creator0}"
#    When I send a "PATCH" request to "/recovery/payments/{loan_id}"
#    Then the response status code should be 200
#    And the response body should contain field "loan_id" as "string" with value "{LOAN_ID}"
#    And the response body should contain field "output" as "string" with value "Data updated successfully"
#    And the response body should contain field "message" as "string" with value "success"
#    And the response body should contain field "message_template" as "string" with value "success"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN}      |
#    And I set the query parameters:
#      | company_id              | {COMPANY_ID}                |
#      | variable_id             | global_status             |
#      | variable_group          | Platform+Attributes         |
#      | allocation_month        | {ALLOCATION_MONTH_OFFSET:0} |
#      | archive                 | false                       |
#    When I send a "GET" request to "/portfolio-v2/v3/fetch-distinct-value"
#    Then the response status code should be 200
#    Then I extract "value" from array "output.variable_filter_value" using "label" with value "<status>" and remember as "<status>_value"
#    Given I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json  |
#      | authenticationtoken | {AUTH_TOKEN} |
#    And I set the query parameters:
#      | company_id                 | {COMPANY_ID} |
#    And I set the request body from file "test-data/recovery_loan/export_now_loan.json"
#    And I add JSON field "global_status" as "string" with value "{CAPTURED:<status>_value}"
#    And I update JSON field "allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
#    And I update JSON field "company_id" as "auto" to "{COMPANY_ID}"
#    When I send a "POST" request to "/recovery/export-now/payments"
#    Then the response status code should be 200
#    And I capture response field "data.document_link" as "presigned_url_1"
#    When I download file from absolute url "{CAPTURED:presigned_url_1}" as "export_loan" with extension "xlsx"
#    Then I validate Excel where "Loan Id" is "{LOAN_ID}" has "global_status" as "<status>"
#    And I clear the loaded excel
#    And I prepare a request
#    And I set the request headers:
#      | Content-Type        | application/json |
#      | authenticationtoken | {AUTH_TOKEN}     |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}",
#        "category": "loan",
#        "operation_type": "archive",
#        "data": ["{LOAN_ID}"],
#        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
#        "execution_mode": "real-time"
#      }
#      """
#    When I send a "POST" request to "/recovery/data-operations"
#    Then the response status code should be 200
#
#    Examples:
#      | status |
#      | Initiated |
#      | Escalated |
#      | Do Not Disturb |
#
