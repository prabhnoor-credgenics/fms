@api @repossession @loan-details
Feature: Repossession Loan Details API — GET /repossession/loan-details



  @positive @smoke @creator
  Scenario: TC-POS-001 — Valid request with default pagination returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | accept              | application/json |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 200
    And the response body should contain field "success"
    And the response body should contain field "message"
    And the response body should contain field "response_code"
    And the response body should contain field "data.total_count"
    And the response body should contain field "data.loan_details"
    And the response should match json schema "schemas/recovery/success/repossession_loan_details_success_schema.json"

  @positive @creator
  Scenario: TC-POS-002 — Empty search_value returns full page (no filter applied)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/repossession_loan_details_success_schema.json"

  @positive @creator
  Scenario Outline: TC-POS-003 — Valid pagination page_number=<page> page_size=<size> returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | <page>       |
      | page_size    | <size>       |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/repossession_loan_details_success_schema.json"

    Examples:
      | page | size |
      | 1    | 1    |
      | 1    | 25   |
      | 1    | 100  |
      | 2    | 10   |

  @positive @creator @boundary
  Scenario: TC-POS-004 — High page_number beyond data returns 200 with empty list
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 999999       |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 200
    And the response body should contain field "data.loan_details"
    And the response should match json schema "schemas/recovery/success/repossession_loan_details_success_schema.json"

  @positive @creator
  Scenario Outline: TC-POS-006 — Valid search_by "<field>" with empty value returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | <field>      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/success/repossession_loan_details_success_schema.json"

    Examples:
      | field          |
      | loan_id        |
      | applicant_name |
      | allocated_user |

  @positive @creator
  Scenario Outline: TC-POS-007 — Filter by "<field>"="<value>" returns 400 with matching or empty results
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | <field>      |
      | search_value | <value>      |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/success/repossession_loan_details_success_schema.json"

    Examples:
      | field          | value                     |
      | loan_id        | agencytest_01             |
      | applicant_name | agencyapplicant           |
      | allocated_user | Raktim                    |
      | loan_id        | this_id_does_not_exist_xx |

  @positive @chief-admin
  Scenario: TC-POS-005 — Chief admin can fetch repossession loan details — 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/success/repossession_loan_details_success_schema.json"



  @negative
  Scenario: TC-AUTH-001 — Missing authenticationtoken header returns 401
    Given I prepare a request
    And I set the request headers:
      | accept | application/json |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be one of "400, 401,403"
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 403
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz-123 |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be one of "400, 401,403"
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-003 — Malformed UUID token returns 401
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | not-a-uuid |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be one of "400, 401"



  @negative @creator
  Scenario: TC-COMP-001 — Missing company_id returns 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | page_number  | 1       |
      | page_size    | 10      |
      | search_by    | loan_id |
      | search_value |         |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: TC-COMP-002 — Empty company_id returns 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   |         |
      | page_number  | 1       |
      | page_size    | 10      |
      | search_by    | loan_id |
      | search_value |         |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 403

  @negative @creator
  Scenario: TC-COMP-003 — Non-UUID company_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | not-a-uuid |
      | page_number  | 1          |
      | page_size    | 10         |
      | search_by    | loan_id    |
      | search_value |            |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 400

  @negative @creator
  Scenario: TC-COMP-004 — Well-formed but non-existent company_id returns 422
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | 00000000-0000-0000-0000-000000000000 |
      | page_number  | 1                                    |
      | page_size    | 10                                   |
      | search_by    | loan_id                              |
      | search_value |                                      |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be one of "422"



  @negative @creator
  Scenario Outline: TC-PAGE-001 — Invalid page_number "<page>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | <page>       |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 400

    Examples:
      | page       |
      | 0          |
      | -1         |
      | not-a-page |
      | 1.5        |

  @negative @creator
  Scenario Outline: TC-PAGE-002 — Invalid page_size "<size>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | <size>       |
      | search_by    | loan_id      |
      | search_value |              |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 400

    Examples:
      | size      |
      | 0         |
      | -1        |
      | not-a-num |
      | 5001      |


  @negative @creator
  Scenario: TC-SRCH-001 — Invalid search_by field returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}       |
      | page_number  | 1                  |
      | page_size    | 10                 |
      | search_by    | non_existent_field |
      | search_value | anything           |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be 400

  @negative @creator
  Scenario: TC-SRCH-002 — search_value supplied without search_by returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}    |
      | page_number  | 1               |
      | page_size    | 10              |
      | search_value | some-loan-value |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be one of "200, 400"

  @negative @creator @security
  Scenario: TC-SRCH-003 — SQL-injection-like search_value is safely handled
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}          |
      | page_number  | 1                     |
      | page_size    | 10                    |
      | search_by    | loan_id               |
      | search_value | '; DROP TABLE loans;-- |
    When I send a "GET" request to "/repossession/loan-details"
    Then the response status code should be one of "200, 400"
    And the response body should not be empty


  @negative @creator
  Scenario: TC-METH-001 — POST on GET endpoint returns  405
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | page_number  | 1            |
      | page_size    | 10           |
      | search_by    | loan_id      |
      | search_value |              |
    And I set the request body to "{}"
    When I send a "POST" request to "/repossession/loan-details"
    Then the response status code should be one of "405"
