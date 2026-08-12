@api @document @document-upload-loan
Feature: Loan Recovery API - Strict Datatype Validation

  @positive @creator @p0
  Scenario: Upload document for a loan
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And scenario loan id is unique
    And I grant the current user all loan permissions
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And the response should match json schema "schemas/recovery/success/loan_recovery_success_schema.json"
    Given I prepare a request
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | content-type        | application/json |
    And I set the request body from file "test-data/document/loan_document_upload.json"
    And I store file size in bytes of "test-data/upload_document/users.csv" as "fileSize"
    And I update JSON field "data.users.meta_data.size" as "int" to "{CAPTURED:fileSize}"
    When I send a "POST" request to "/document/presigned-url"
    Then the response status code should be 201
    And I capture response field "data.users.presigned_url" as "presigned_url_1"
    And I capture response field "data.users.document_id" as "document_id_1"
    Given I prepare a request
    And I set the request headers:
      | Content-Type | text/csv |
    And I set the request body from binary file "test-data/upload_document/users.csv"
    When I send a "PUT" request to absolute url "{CAPTURED:presigned_url_1}"
    Then the response status code should be 200
    Given I prepare a request
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | document_id | {CAPTURED:document_id_1} |
    And I set the request body from file "test-data/document/document_update.json"
    When I send a "PATCH" request to "/document/{document_id}"
    Then the response status code should be 200
