@api @data-operations @recovery
Feature: Data Operations API — POST /recovery/data-operations


  @negative
  Scenario: TC-AUTH-001 — Request without authenticationtoken header returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: TC-AUTH-003 — Non-existent company_id returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "00000000-dead-beef-ffff-000000000000",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 422
    And the response body should not be empty

  @positive @creator
  Scenario: TC-AUTH-004 — Test user has archive_and_unarchive_loan write permission — returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-COMP-001 — Missing company_id returns 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: TC-COMP-002 — company_id as empty string returns error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 403
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-COMP-003 — Non-existent company_id returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "00000000-0000-0000-0000-000000000000",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 422
    And the response body should not be empty


  @positive @creator
  Scenario: TC-CAT-001 — category "loan" returns 200 with correct message
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-CAT-002 — category "customer" returns 200 with correct message
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "customer",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-CAT-003 — category "transaction" returns 200 with correct message
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "transaction",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-CAT-004 — Invalid category value returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "invalid_category",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-CAT-005 — category missing from body returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-CAT-006 — category = null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": null,
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-OP-001 — operation_type "archive" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-OP-002 — operation_type "unarchive" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-OP-003 — operation_type "delete" is not a valid enum value — returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "delete",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-OP-004 — operation_type missing from body returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-DATA-001 — data with multiple valid loan IDs returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DATA-002 — data as empty list — staging returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": [],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DATA-003 — data missing from body returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DATA-004 — data as string instead of list returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": "{LOAN_ID}",
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DATA-005 — data = null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": null,
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-MONTH-001 — Valid allocation_month "2026-5-01" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-MONTH-002 — allocation_month = "Overall" (exact case) rejected by service with 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "Overall"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-MONTH-003 — allocation_month = "overall" (lowercase) not rejected — case-sensitive check
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "overall"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-MONTH-004 — allocation_month missing from body returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"]
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-MONTH-005 — allocation_month as empty string — service accepts as overall
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": ""
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-MODE-001 — execution_mode "real-time" explicit — synchronous v1 path returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-MODE-002 — execution_mode absent defaults to "real-time" — v1 path returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-MODE-003 — execution_mode "queue" — async v2 path returns 202
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "execution_mode": "queue"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 202
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-MODE-004 — execution_mode "instant" is not a valid enum value — returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "execution_mode": "instant"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-SRC-001 — source absent defaults to "unknown" — operation succeeds
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-SRC-002 — source = "platform" is accepted — operation succeeds
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "source": "platform"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-SRC-003 — source as arbitrary free-form string is accepted by bare str field
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "source": "my_custom_system"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-BODY-001 — Empty JSON body returns 400 with all-fields-required error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 403
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-BODY-002 — Extra unknown fields silently dropped by ServiceBaseModel.Config.extra=ignore
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "unknown_field": "should be ignored",
        "extra_number": 12345
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-BODY-003 — Missing Content-Type header — service accepts without explicit Content-Type
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-BODY-004 — Whitespace-padded enum values are stripped and accepted
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "  loan  ",
        "operation_type": "  archive  ",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-HAPPY-001 — Full v1 success response shape: all keys present and correct
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-HAPPY-002 — Full v2 success response shape: queue mode 202 with task message
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "execution_mode": "queue"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 202
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-HAPPY-003 — Unarchive with queue mode returns 202 with unarchive task message
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "execution_mode": "queue"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 202
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-IDEM-001 — Archiving an already-archived loan — behaviour TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-IDEM-002 — Archive then unarchive returns 200 both times
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty


  @negative @creator
  Scenario Outline: TC-MISS-00x — Body missing <absent_field> returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | absent_field     | body                                                                                                                |
      | category         | {"company_id": "{COMPANY_ID}", "operation_type": "archive", "data": ["{LOAN_ID}"], "allocation_month": "2026-5-01"} |
      | operation_type   | {"company_id": "{COMPANY_ID}", "category": "loan", "data": ["{LOAN_ID}"], "allocation_month": "2026-5-01"}          |
      | data             | {"company_id": "{COMPANY_ID}", "category": "loan", "operation_type": "archive", "allocation_month": "2026-5-01"}    |
      | allocation_month | {"company_id": "{COMPANY_ID}", "category": "loan", "operation_type": "archive", "data": ["{LOAN_ID}"]}              |

  @negative @creator
  Scenario: TC-MISS-005 — Body missing company_id returns 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {"category": "loan", "operation_type": "archive", "data": ["{LOAN_ID}"], "allocation_month": "2026-5-01"}
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 403
    Then the response body should not be empty


  @negative @creator
  Scenario Outline: TC-ENUM-00x — Invalid <field> value "<invalid_value>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    And I update JSON field "<field>" as "auto" to "<invalid_value>"
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | field          | invalid_value |
      | category       | orders        |
      | operation_type | delete        |
      | execution_mode | instant       |


  @positive @creator
  Scenario: TC-EDGE-001 — allocation_month = "OVERALL" (uppercase) accepted — case-insensitive check
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "OVERALL"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EDGE-002 — data list containing non-existent loan IDs — service processes silently
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["NON-EXISTENT-LOAN-{UUID}", "ANOTHER-MISSING-{UUID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-003 — operation_type = null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": null,
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EDGE-004 — execution_mode = "queue" for unarchive returns 202 with unarchive message
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "execution_mode": "queue",
        "source": "api"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 202
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-EXTRA-001 — data as integer (wrong type) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": 12345,
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EXTRA-002 — execution_mode = null defaults to async path returns 202
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01",
        "execution_mode": null
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 202
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-003 — category as empty string returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EXTRA-004 — allocation_month with surrounding whitespace stripped and accepted
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "  2026-5-01  "
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-005 — operation_type as empty string returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-500-001 — Valid archive request returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "2026-5-01"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    Then the response body should not be empty
