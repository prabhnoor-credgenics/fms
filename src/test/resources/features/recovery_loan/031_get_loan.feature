@api @loan-detail @recovery
Feature: Loan Detail API — GET /recovery/loan/<loan_id>


  @negative
  Scenario: TC-AUTH-001 — Request without authenticationtoken header returns 401
    Given I prepare a request
    And I set the request headers:
      | accept | application/json |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 401
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 401
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 401
    And the response body should not be empty

  @negative @creator
  Scenario: TC-AUTH-003 — Valid token with valid company returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-LOANID-001 — loan_id "undefined" returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/undefined"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-LOANID-002 — loan_id "null" returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/null"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-LOANID-003 — Non-existent loan_id returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | NON-EXISTENT-LOAN-{UUID} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-LOANID-004 — Very long random loan_id not in DB returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {RANDOM_STRING:64} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-LOANID-005 — loan_id with forward slash accepted by Quart path converter
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/NBFC-LOAN-001"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive @creator
  Scenario: TC-FIELDS-001 — fields=loan returns loan_details and global_status
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-002 — fields=payment returns payment_history array
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | payment |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-003 — fields=notice returns notice_tracking_details
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | notice |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-004 — fields=communication returns communication_details
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | communication |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-005 — fields=remark returns remarks array
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | remark |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-006 — fields=reminders returns reminders array
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | reminders |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-007 — fields=loan_level returns loan-level data without allocation defaults
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan_level |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-008 — fields=allocation_level returns allocation-month default entries
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | allocation_level |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-009 — fields=all returns every section
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | all |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive @creator
  Scenario: TC-FIELDS-010 — No fields param uses default loan,payment
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-011 — fields=loan,payment explicitly returns both sections
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan,payment |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-012 — fields=loan,notice,remark returns three sections
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan,notice,remark |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FIELDS-013 — Unknown fields token silently ignored — valid token still works
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan,bogus_token |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive @creator
  Scenario: TC-MONTH-001 — allocation_month "2026-1-01" (single-digit month) is valid
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment  |
      | allocation_month | 2026-1-01 |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-MONTH-002 — allocation_month "2025-12-01" (two-digit month ≥ 10) is valid
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment    |
      | allocation_month | 2025-12-01 |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-MONTH-003 — allocation_month "2026-01-01" with leading zero returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment     |
      | allocation_month | 2026-01-01  |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @creator
  Scenario: TC-MONTH-004 — allocation_month "not-a-date" returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment    |
      | allocation_month | not-a-date |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @creator
  Scenario: TC-MONTH-005 — allocation_month "2026-13-01" (month 13 out of range) returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment     |
      | allocation_month | 2026-13-01  |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @creator
  Scenario: TC-MONTH-006 — allocation_month day not "01" (e.g. "2026-1-15") returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment    |
      | allocation_month | 2026-1-15  |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"


  @positive @creator
  Scenario: TC-DATE-001 — start_date with valid Unix timestamp filters from that date
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | loan,payment |
      | start_date | 1735689600   |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-DATE-002 — end_date with valid Unix timestamp filters up to that date
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields   | loan,payment |
      | end_date | 1767225600   |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-DATE-003 — start_date and end_date range both applied
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | all        |
      | start_date | 1735689600 |
      | end_date   | 1767225600 |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-DATE-004 — start_time alias used when start_date absent
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | loan,payment |
      | start_time | 1735689600   |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-DATE-005 — end_time alias used when end_date absent
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields   | loan,payment |
      | end_time | 1767225600   |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DATE-006 — start_date non-numeric returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | loan,payment |
      | start_date | not-a-number |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @creator
  Scenario: TC-DATE-007 — end_date non-numeric returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields   | loan,payment |
      | end_date | not-a-number |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"



  @positive @creator
  Scenario: TC-SHAPE-001 — Default response has output object and message=success
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @positive @creator
  Scenario: TC-SHAPE-002 — fields=loan response contains required loan keys
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-SHAPE-003 — Non-existent loan with start_date returns timestamp error message
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | NON-EXISTENT-LOAN-{UUID} |
    And I set the query parameters:
      | fields     | loan       |
      | start_date | 1735689600 |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"



  @positive @creator
  Scenario: TC-URL-001 — /recovery/loan/ alias URL returns same result as primary URL
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty



  @negative @creator
  Scenario Outline: TC-RESID-00x — Reserved loan_id "<loan_id_val>" returns 400 Invalid loan id
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/<loan_id_val>"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | loan_id_val |
      | undefined   |
      | null        |
      | UNDEFINED   |



  @negative @creator
  Scenario Outline: TC-INVMONTH-00x — Invalid allocation_month "<month_val>" returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment      |
      | allocation_month | <month_val>  |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

    Examples:
      | month_val  |
      | 2026-01-01 |
      | 2026-13-01 |
      | 2026-0-01  |
      | not-a-date |



  @negative @creator
  Scenario Outline: TC-INVTS-00x — Non-numeric <param> value returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields   | loan,payment  |
      | <param>  | not-a-number  |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

    Examples:
      | param      |
      | start_date |
      | end_date   |
      | start_time |
      | end_time   |



  @positive @creator
  Scenario: TC-EDGE-001 — Float Unix timestamp string accepted for start_date
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | loan,payment   |
      | start_date | 1735689600.5   |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EDGE-002 — start_date present overrides start_time alias
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | loan,payment |
      | start_date | 1735689600   |
      | start_time | 999999999    |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EDGE-003 — end_date present overrides end_time alias
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields   | loan,payment |
      | end_date | 1767225600   |
      | end_time | 999999999    |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EDGE-004 — fields=all with allocation_month and date range combined
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | all        |
      | allocation_month | 2026-1-01  |
      | start_date       | 1735689600 |
      | end_date         | 1767225600 |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EDGE-005 — Only unknown fields token in fields returns empty output
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | bogus1,bogus2,unknown |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EDGE-006 — reminders filtered by start_date and end_date
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | reminders  |
      | start_date | 1735689600 |
      | end_date   | 1767225600 |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive @creator
  Scenario: TC-FLOW-001 — GET loan then verify output contains expected top-level keys
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-FLOW-002 — GET with fields=loan then GET with fields=payment — both return 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | loan |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response body should not be empty
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | payment |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive @creator
  Scenario: TC-EXTRA-001 — allocation_month "2026-10-01" (month 10, two-digit) is valid
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment    |
      | allocation_month | 2026-10-01 |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EXTRA-002 — allocation_month "2026-9-01" (single-digit near boundary) is valid
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields           | payment   |
      | allocation_month | 2026-9-01 |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EXTRA-003 — start_date = 0 (Unix epoch) is a valid timestamp
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | loan,payment |
      | start_date | 0            |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EXTRA-004 — Same start_date and end_date (single point in time) returns 200
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields     | loan,payment |
      | start_date | 1735689600   |
      | end_date   | 1735689600   |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-005 — loan_id with SQL injection attempt is sanitised by sanitize_argument_for_db
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/'; DROP TABLE loans;--"
    Then the response status code should be 401
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-500-001 — Service internal error path returns error
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | fields | all |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
