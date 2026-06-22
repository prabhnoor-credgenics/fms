@api @company-table-names @recovery
Feature: Company Table Names — GET /recovery/company-table-names



  @positive @smoke @creator
  Scenario: Minimal request (no query param → defaults to include_disabled=true) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/company_table_names_success_schema.json"
    And the company table names success response should be valid

  @positive @creator
  Scenario: include_disabled=true (enabled + disabled tables) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the company table names success response should be valid

  @positive @creator
  Scenario: include_disabled=false (only enabled tables) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the company table names success response should be valid

  @positive @creator @multistep
  Scenario: Two consecutive reads are consistent (idempotent read) — both 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the company table names success response should be valid
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the company table names success response should be valid

  @positive @creator
  Scenario Outline: include_disabled is parsed leniently — value "<value>" still returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled | <value>      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the company table names success response should be valid

    Examples:
      | value |
      | TRUE  |
      | True  |
      | FALSE |
      | 0     |
      | 1     |
      | yes   |
      | no    |
      | maybe |
      | {RANDOM_STRING:8} |

  @positive @creator
  Scenario: Empty include_disabled value is treated as false — returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled |              |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the company table names success response should be valid

  @positive @creator
  Scenario: Unknown query param is ignored — returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | totally_unknown_param | whatever     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the company table names success response should be valid

  @positive @approver
  Scenario: A non-creator role (approver) may read the company tables — no permission submodule
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 200
    And the company table names success response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id (org context unresolved) is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/company-table-names"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: POST on the company-table-names endpoint is not allowed (405)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/company-table-names"
    Then the response status code should be 405

