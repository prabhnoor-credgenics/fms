@api @document @document-type
Feature: Loan Recovery API - Strict Datatype Validation

  @positive @creator @p0
  Scenario Outline: Upload document for a loan
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    Given I set the query parameters:
      | company_id | {COMPANY_ID} |
      | level      | <document_level> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/document/document-types"
    Then the response status code should be 200


  Examples:
    | document_level |
    | loan      |
    | user        |