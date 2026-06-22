@api @exports-payments @recovery
Feature: Exports Payments Logs — GET /recovery/exports/payments



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"



  @positive @smoke @creator
  Scenario: Minimal (export_category=payment) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/exports_payments_logs_success_schema.json"
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: Pagination (page_number + page_size) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | page_number     | 2            |
      | page_size       | 25           |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: disable_paging=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | disable_paging  | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: disable_paging=false (explicit) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | disable_paging  | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: Search by author returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | search_type     | author       |
      | search_query    | Ramesh       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: Search by request_id (comma-separated) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | search_type     | request_id   |
      | search_query    | 101,102,103  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario Outline: status filter "<status>" returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | status          | <status>     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

    Examples:
      | status              |
      | accepted            |
      | initiated           |
      | in_process          |
      | completed           |
      | failed              |
      | rejected            |
      | partially_completed |
      | cancelled           |
      | interrupted         |

  @positive @creator
  Scenario: Multiple statuses (comma-separated) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID}     |
      | export_category | payment          |
      | status          | completed,failed |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: Date range (start + end) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | start_date      | 2026-01-01   |
      | end_date        | 2026-01-31   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: Only start_date returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | start_date      | 2026-01-01   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: Only end_date returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | end_date        | 2026-01-31   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: Search by author with no match returns 200 (empty list)
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID}            |
      | export_category | payment                 |
      | search_type     | author                  |
      | search_query    | NoSuchAuthor{RANDOM_STRING:6} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @positive @creator
  Scenario: Combined — status + author + date + paging returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | status          | completed    |
      | search_type     | author       |
      | search_query    | Ramesh       |
      | start_date      | 2026-01-01   |
      | end_date        | 2026-01-31   |
      | page_number     | 1            |
      | page_size       | 50           |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid


  @positive @boundary @creator
  Scenario: page_size at max (5000) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | page_size       | 5000         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 200
    And the export payments logs success response should be valid

  @negative @boundary @creator
  Scenario: page_size over max (5001) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | page_size       | 5001         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 400
    And the export payments logs failure response should be valid

  @negative @boundary @creator
  Scenario: search_type=request_id with out-of-range id returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
      | search_type     | request_id   |
      | search_query    | 2147483648   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 400
    And the export payments logs failure response should be valid



  @negative @creator
  Scenario: Missing export_category (mandatory) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 400
    And the export payments logs failure response should be valid

  @negative @creator
  Scenario: Invalid export_category (loan not allowed here) returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | loan         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 400
    And the export payments logs failure response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
    And I set the request headers:
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected (insufficient access rights)
    Given I prepare a request
    And I set the query parameters:
      | export_category | payment |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {UUID}  |
      | export_category | payment |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/exports/payments"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: POST on the exports/payments endpoint is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | export_category | payment      |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/exports/payments"
    Then the response status code should be 405
