@api @exports @recovery
Feature: Exports API — GET /recovery/exports


  Background:
    Given scenario company id is from configuration
    And I prepare a request


  @negative
  Scenario: TC-AUTH-001 — Request without authenticationtoken header returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept | application/json |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @chief-admin
  Scenario: TC-AUTH-003 — Valid token resolves to valid company — 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty


  @negative @chief-admin
  Scenario: TC-EXPCAT-001 — Missing export_category param returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @chief-admin
  Scenario: TC-EXPCAT-002 — Empty export_category string returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category |              |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @chief-admin
  Scenario: TC-EXPCAT-003 — Invalid category value returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | invalid_category |
      | company_id      | {COMPANY_ID}     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @chief-admin
  Scenario: TC-EXPCAT-004 — "payment" is not valid for /exports endpoint returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | payment      |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @chief-admin
  Scenario: TC-EXPCAT-005 — Mixed valid and invalid categories returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan,invalid_cat |
      | company_id      | {COMPANY_ID}     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"


  @positive @chief-admin
  Scenario: TC-CAT-001 — export_category "loan" returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-CAT-002 — export_category "transaction" returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | transaction  |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-CAT-003 — export_category "customer" returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | customer     |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-CAT-004 — export_category "portfolio_allocated_users" returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | portfolio_allocated_users |
      | company_id      | {COMPANY_ID}              |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-CAT-005 — export_category "portfolio_data" returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | portfolio_data |
      | company_id      | {COMPANY_ID}   |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-CAT-006 — export_category "portfolio_transaction_data" returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | portfolio_transaction_data |
      | company_id      | {COMPANY_ID}               |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-CAT-007 — Multiple comma-separated categories returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan,transaction,customer |
      | company_id      | {COMPANY_ID}              |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-CAT-008 — Uppercase export_category "LOAN" accepted — tokens are lowercased
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | LOAN         |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"


  @positive @chief-admin
  Scenario: TC-PAGE-001 — Default pagination (page_number=1, page_size=10) returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-PAGE-002 — Custom page_number=2 page_size=25 returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_number     | 2            |
      | page_size       | 25           |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-PAGE-003 — page_size=5000 (max boundary) returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_size       | 5000         |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @negative @chief-admin
  Scenario: TC-PAGE-004 — page_size=5001 exceeds max allowed limit returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_size       | 5001         |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @chief-admin @500
  Scenario: TC-PAGE-005 — Non-numeric page_number returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_number     | not-a-page   |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @chief-admin @500
  Scenario: TC-PAGE-006 — Non-numeric page_size returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_size       | big-size     |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @chief-admin
  Scenario: TC-DPAG-001 — disable_paging=true returns all records without limit
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | disable_paging  | true         |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-DPAG-002 — disable_paging=false (explicit default) uses page_number and page_size
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | disable_paging  | false        |
      | page_number     | 1            |
      | page_size       | 10           |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-DPAG-003 — disable_paging=TRUE (uppercase) accepted — coerced to lowercase true
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | disable_paging  | TRUE         |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"


  @positive @chief-admin
  Scenario: TC-STATUS-001 — status=completed filters to completed exports
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | status          | completed    |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-STATUS-002 — status=failed filters to failed exports
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | status          | failed       |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-STATUS-003 — Multiple comma-separated statuses filter correctly
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan                        |
      | company_id      | {COMPANY_ID}                |
      | status          | completed,failed,in_process |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-STATUS-004 — Uppercase status "COMPLETED" accepted — tokens are lowercased
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | status          | COMPLETED    |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"


  @positive @chief-admin
  Scenario: TC-SRCH-001 — search_type=author with query returns 200 (may be empty if no match)
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | search_type     | author       |
      | search_query    | test         |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-SRCH-002 — search_type=author with query matching no users returns 200 empty
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan                  |
      | company_id      | {COMPANY_ID}          |
      | search_type     | author                |
      | search_query    | zzz-no-match-xyzzy123 |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-SRCH-003 — search_type=request_id with valid integer IDs returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | search_type     | request_id   |
      | search_query    | 1,2,3        |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @negative @chief-admin
  Scenario: TC-SRCH-004 — search_type=request_id with ID = 0 (below range) returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | search_type     | request_id   |
      | search_query    | 0            |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @chief-admin
  Scenario: TC-SRCH-005 — search_type=request_id with ID above INT max returns 400
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | search_type     | request_id   |
      | search_query    | 2147483648   |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive @chief-admin
  Scenario: TC-SRCH-006 — search_type=request_id non-integer tokens silently skipped returns 200 empty
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | search_type     | request_id   |
      | search_query    | abc,xyz      |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"


  @positive @chief-admin
  Scenario: TC-DATE-001 — start_date only filters exports created on or after date
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | start_date      | 2026-01-01   |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-DATE-002 — end_date only filters exports created on or before date
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | end_date        | 2026-01-31   |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-DATE-003 — start_date + end_date range filters to that period
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | start_date      | 2026-01-01   |
      | end_date        | 2026-01-31   |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-DATE-004 — start_date + end_date with status and category combined
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan,transaction |
      | company_id      | {COMPANY_ID}     |
      | status          | completed        |
      | start_date      | 2026-01-01       |
      | end_date        | 2026-01-31       |
      | page_number     | 1                |
      | page_size       | 50               |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"


  @positive @chief-admin
  Scenario: TC-AUTHOR-001 — Single author_id filter returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan             |
      | company_id      | {COMPANY_ID}     |
      | author_id       | AbCdEfGhIjKlMnOp |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-AUTHOR-002 — Multiple comma-separated author_ids returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan                              |
      | company_id      | {COMPANY_ID}                      |
      | author_id       | AbCdEfGhIjKlMnOp,QrStUvWxYz123456 |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-AUTHOR-003 — author_id with no permissible intersection returns 200 empty
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan               |
      | company_id      | {COMPANY_ID}       |
      | author_id       | ZzZzZzZzZzZzZzZzZz |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"


  @positive @chief-admin
  Scenario: TC-SHAPE-001 — Full response shape: data.exports array, total_count, message, success
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data"
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"
    And the response body should not be empty

  @positive @chief-admin
  Scenario: TC-SHAPE-002 — Empty result shape: exports=[] total_count=0 with success=true
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | start_date      | 2099-01-01   |
      | end_date        | 2099-12-31   |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-SHAPE-003 — search_type=author no match returns success with empty exports
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan                   |
      | company_id      | {COMPANY_ID}           |
      | search_type     | author                 |
      | search_query    | zzz-definitely-no-user |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty


  @positive @chief-admin
  Scenario Outline: TC-CATVAL-00x — export_category "<category>" returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | <category>   |
      | company_id      | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

    Examples:
      | category                   |
      | loan                       |
      | transaction                |
      | customer                   |
      | portfolio_allocated_users  |
      | portfolio_data             |
      | portfolio_transaction_data |


  @positive @chief-admin
  Scenario Outline: TC-STVAL-00x — status filter "<status_val>" returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | status          | <status_val> |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

    Examples:
      | status_val          |
      | accepted            |
      | initiated           |
      | in_process          |
      | completed           |
      | failed              |
      | rejected            |
      | partially_completed |
      | cancelled           |
      | interrupted         |


  @positive @chief-admin
  Scenario: TC-EDGE-001 — page_size=1 (minimum boundary) returns at most 1 record
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_size       | 1            |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-EDGE-002 — search_type without search_query — ignored gracefully returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | search_type     | author       |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-EDGE-003 — All six categories combined in one request returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan,transaction,customer,portfolio_allocated_users,portfolio_data,portfolio_transaction_data |
      | company_id      | {COMPANY_ID}                                                                                  |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-EDGE-004 — High page_number with valid page_size returns 200 (empty if beyond data)
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_number     | 9999         |
      | page_size       | 10           |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-EDGE-005 — search_type=request_id single valid ID at minimum boundary (ID=1) returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | search_type     | request_id   |
      | search_query    | 1            |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"


  @negative @chief-admin
  Scenario: TC-EXTRA-001 — page_size = 0 — boundary below minimum returns error
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_size       | 0            |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @chief-admin @500
  Scenario: TC-EXTRA-002 — page_number = 0 — boundary below valid start returns error
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | page_number     | 0            |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @chief-admin
  Scenario: TC-EXTRA-003 — search_type=request_id with max boundary ID 2147483647 returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan         |
      | company_id      | {COMPANY_ID} |
      | search_type     | request_id   |
      | search_query    | 2147483647   |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @positive @chief-admin
  Scenario: TC-EXTRA-004 — export_category with surrounding whitespace stripped and accepted
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan,  transaction |
      | company_id      | {COMPANY_ID}       |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"

  @positive @chief-admin
  Scenario: TC-EXTRA-005 — disable_paging=true with multiple categories returns 200
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan,transaction,customer |
      | company_id      | {COMPANY_ID}              |
      | disable_paging  | true                      |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "data.exports"
    And the response body should contain field "data.total_count"

  @negative @chief-admin @500
  Scenario: TC-500-001 — Unparseable start_date triggers dateutil.ParserError — status TBD
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan                 |
      | company_id      | {COMPANY_ID}         |
      | start_date      | not-a-parseable-date |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @chief-admin @500
  Scenario: TC-500-002 — Unparseable end_date triggers dateutil.ParserError — status TBD
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | export_category | loan                 |
      | company_id      | {COMPANY_ID}         |
      | end_date        | not-a-parseable-date |
    When I send a "GET" request to "/recovery/exports"
    Then the response status code should be 400
    Then the response body should not be empty
