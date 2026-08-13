@api @document @document-type @array-lookup
Feature: Document types - array extract and validate

  @positive @approver @p0
  Scenario: Get document types and lookup by reference key
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
      | level      | loan,user    |
      | need_size  | true         |
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                      |
    When I send a "GET" request to "/document/document-types"
    Then the response status code should be 200
    And the array "data" should not be empty
    And the array "data" size should be greater than 0
    And the array "data" size should be at least 1
    And I store array "data" size as "documentTypeCount"
    And the array "data" should contain item where "document_type" is "Loan Document"
    And the array "data" should not contain item where "document_type" is "NonExistent_Document_Type_XYZ"
    And the array "data" should have 1 items where "document_type" is "Loan Document"
    And every item in array "data" should have key "document_type_id"
    And every item in array "data" should have key "document_type"
    And any item in array "data" should have key "storage_used"
    And the JSON object "$" should contain key "success"
    And the JSON object "$" should contain key "data"
    And the JSON object "$" should not contain key "non_existent_root_key"
    And the item in array "data" where "document_type" is "Loan Document" should contain key "document_type_id"
    And values of "document_type_id" in array "data" should be unique
    And I extract "document_type_id" from array "data" using "document_type" with value "Loan Document" and remember as "documentTypeId"
    And I validate "document_type" in array "data" using "document_type_id" with value "{CAPTURED:documentTypeId}" equals "Loan Document"
