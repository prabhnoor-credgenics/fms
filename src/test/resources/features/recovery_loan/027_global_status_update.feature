@api @global-status-update @recovery
Feature: Global Status Update API — PATCH /recovery/global-status/update/<loan_id>


  @negative
  Scenario: TC-AUTH-001 — Request without authenticationtoken header returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: TC-AUTH-003 — Valid token but organisation not found returns 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-LOAN-001 — loan_id path value "undefined" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/undefined"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-LOAN-002 — loan_id path value "null" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/null"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-LOAN-003 — Non-existent but valid-format loan_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | NON-EXISTENT-LOAN-{UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-LOAN-004 — Very long random loan_id not found in DB returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {RANDOM_STRING:64} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-LOAN-005 — loan_id containing a forward slash is accepted by Quart path converter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "PATCH" request to "/recovery/global-status/update/NBFC-LOAN-001"
    Then the response status code should be 400
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-MOD-001 — module field absent returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @creator
  Scenario: TC-MOD-002 — module sent as null returns 400 "Incorrect module provided"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": null,
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-MOD-003 — module = empty string returns 400 "Incorrect module provided"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-MOD-004 — module = "GLOBAL" (uppercase) returns 400 — value is case-sensitive
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "GLOBAL",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-MOD-005 — module = unrecognised string returns 400 "Incorrect module provided"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "local",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-STATUS-001 — Only status_name provided returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-STATUS-002 — Only status_id provided returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_id": 1
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-STATUS-003 — Both status_name and status_id provided — status_name wins
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed",
        "status_id": 99999
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-STATUS-004 — Neither status_name nor status_id provided returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-STATUS-005 — status_name not in company global statuses returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "NonExistentStatusXYZ"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-STATUS-006 — status_id not belonging to company returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_id": 999999
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-STATUS-007 — status_name is null (falsy), valid status_id used instead
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": null,
        "status_id": 1
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-STATUS-008 — status_id = 0 (falsy) and no status_name returns 400 "No status provided"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_id": 0
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-BODY-001 — Empty JSON body {} returns 400 "Please provide data"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {}
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-BODY-002 — Body has module only (no status fields) returns 400 "No status provided"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-BODY-003 — Extra unknown fields in body are ignored by raw JSON parsing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed",
        "unknown_field": "should be ignored",
        "extra_data": 12345
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-BODY-004 — Missing Content-Type header returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-BODY-005 — status_name as integer — raw JSON dict, no Pydantic coercion
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": 99999
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-HAPPY-001 — Full success update by status_name — complete shape verified
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-HAPPY-002 — Full success update by status_id — complete shape verified
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_id": 1
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-HAPPY-003 — Idempotent update — calling with same status twice both return 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-SHAPE-001 — Success response always contains exactly message and output keys
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "message"
    And the response body should contain field "output"

  @negative @creator
  Scenario: TC-SHAPE-002 — Failure response contains message="failed" and output with error description
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "NonExistentStatusXYZ"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should contain field "output"
    And the response body should not be empty


  @negative @creator
  Scenario: TC-EDGE-001 — status_id as string (type mismatch in raw JSON dict)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_id": "1"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-002 — status_id as negative integer — not a valid company status ID
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_id": -1
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-003 — status_name as empty string (falsy) with no status_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": ""
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-004 — module as integer returns 400 "Incorrect module provided"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": 1,
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-005 — Both status_name and status_id both null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": null,
        "status_id": null
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @negative @creator
  Scenario Outline: TC-LVAL-00x — Reserved loan_id value "<loan_id_value>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/<loan_id_value>"
    Then the response status code should be 403
    Then the response body should not be empty

    Examples:
      | loan_id_value |
      | undefined     |
      | null          |
      | UNDEFINED     |


  @negative @creator
  Scenario Outline: TC-MVAL-00x — module value "<module_value>" returns 400 Incorrect module
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    And I update JSON field "module" as "auto" to "<module_value>"
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | module_value |
      | GLOBAL       |
      | Global       |
      | local        |
      | disposition  |


  @negative @creator
  Scenario Outline: TC-SVAL-00x — <description> returns 400 No status provided
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      <body>
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | description                          | body                                                         |
      | status_name absent, status_id absent | {"module": "global"}                                         |
      | status_name null, status_id absent   | {"module": "global", "status_name": null}                    |
      | status_name absent, status_id null   | {"module": "global", "status_id": null}                      |
      | status_name null, status_id null     | {"module": "global", "status_name": null, "status_id": null} |


  @positive @performance @creator
  Scenario: TC-PERF-001 — PATCH response time should be within configured threshold
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response time should be within configured limit


  @negative @creator
  Scenario: TC-EXTRA-001 — PATCH with no body at all returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-002 — loan_id containing SQL injection characters is sanitised
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/'; DROP TABLE loans;--"
    Then the response status code should be 401
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-003 — Very long status_name (256 chars) not in company statuses returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "{RANDOM_STRING:256}"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-004 — status_id as very large number not in company statuses returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_id": 2147483647
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-500-001 — Internal server error when global status operations fetch fails
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "module": "global",
        "status_name": "Closed"
      }
      """
    When I send a "PATCH" request to "/recovery/global-status/update/{loanId}"
    Then the response status code should be 400
    Then the response body should not be empty
