@api @export-now-bulk-loan-details @recovery @pod1
Feature: Export Now Bulk Loan Details API — POST /recovery/export/export-now/loan-details


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
    When I send a "POST" request to "/recovery/export/export-now/loan-details"
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
    When I send a "POST" request to "/recovery/export/export-now/loan-details"
    Then the response status code should be 400

  @positive @smoke @regression @test
  Scenario: Validate normal export loan for the new uploaded loan
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
#      | include_computed_variables | false        |
#      | include_meta_data          | false        |
    And I set the request body from file "test-data/loan/bulk_loan_upload.json"
    And I update JSON field "loan_data[0].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan2}" and remember as "loan_id_2"
    And I update JSON field "loan_data[0].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "loan_data[0].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "loan_data[1].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan3}" and remember as "loan_id_3"
    And I update JSON field "loan_data[1].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
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
    And the response body should contain field "output.status" as "auto" with value "Completed"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
#      | include_computed_variables | false        |
#      | include_meta_data          | false        |
    And I set the request body from file "test-data/loan/bulk_loan_upload.json"
    And I update JSON field "loan_data[0].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan2}" and remember as "loan_id_2"
    And I update JSON field "loan_data[1].loan_id" as "auto" to "Loan{RANDOM_STRING:6:loan3}" and remember as "loan_id_3"
    And I update JSON field "loan_data[0].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    And I update JSON field "loan_data[1].defaults.allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/bulk/loan-upload"

