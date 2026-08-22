@api @loan-upload-via-queue @recovery @pod1
Feature: Loan Upload via queue


  @positive @creator @p0
  Scenario: Upload document for a loan
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | content-type        | application/json |
    And I store file extension of "test-data/upload_document/users.csv" as "fileExtension"
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}",
      "file_format": "{CAPTURED:fileExtension}",
    "operation_type": "loan_upload" }
      """
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