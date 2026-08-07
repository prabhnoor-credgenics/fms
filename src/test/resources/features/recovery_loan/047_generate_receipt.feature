@api @generate-receipt @recovery
Feature: Generate Receipt — POST /recovery/generate/receipt



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal required fields enqueues the receipt (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-{TIMESTAMP}", "data": { "amount": 5000 }, "is_cancelled": false, "receipt_source": "platform" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/generate_receipt_error_schema.json"
    And the response body should contain field "error.code" as "auto" with value "REC_RT015"

  @positive @creator
  Scenario: With callback_details enqueues the receipt (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-{TIMESTAMP}", "data": { "amount": 7500 }, "is_cancelled": false, "receipt_source": "platform", "callback_details": { "callback_url": "https://example.com/cb", "ref": "txn-42" } }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_RT015"

  @positive @creator
  Scenario: is_preview true enqueues the receipt (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-{TIMESTAMP}", "data": { "amount": 1000 }, "is_cancelled": false, "receipt_source": "platform", "is_preview": true }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_RT015"

  @positive @creator
  Scenario: is_preview false (explicit) enqueues the receipt (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-{TIMESTAMP}", "data": { "amount": 1000 }, "is_cancelled": false, "receipt_source": "platform", "is_preview": false }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_RT015"

  @positive @creator
  Scenario: Cancellation receipt (is_cancelled true) enqueues the receipt (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-{TIMESTAMP}", "data": { "reason": "duplicate payment" }, "is_cancelled": true, "receipt_source": "platform" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_RT015"

  @positive @creator
  Scenario Outline: receipt_source "<source>" enqueues the receipt (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-{TIMESTAMP}", "data": { "amount": 1000 }, "is_cancelled": false, "receipt_source": "<source>" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_RT015"

    Examples:
      | source   |
      | platform |
      | billzy   |
      | fos      |
      | other    |


  @negative @creator
  Scenario: Empty body {} (all required absent) returns 400 (REC_RT007)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the generate receipt validation error should be valid

  @negative @creator
  Scenario Outline: Required field "<missing>" absent returns 400 (REC_RT007)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the generate receipt validation error should be valid

    Examples:
      | missing        | body                                                                                                                       |
      | company_id     | { "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": false, "receipt_source": "platform" }                    |
      | identifier     | { "company_id": "{COMPANY_ID}", "data": { "amount": 1 }, "is_cancelled": false, "receipt_source": "platform" }              |
      | data           | { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "is_cancelled": false, "receipt_source": "platform" }               |
      | is_cancelled   | { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "receipt_source": "platform" }             |
      | receipt_source | { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": false }                    |

  @negative @creator
  Scenario: data present but null returns 400 (REC_RT007)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": null, "is_cancelled": false, "receipt_source": "platform" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the generate receipt validation error should be valid


  @negative @creator
  Scenario Outline: Invalid field "<case>" returns 400 (REC_RT007)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the generate receipt validation error should be valid

    Examples:
      | case                        | body                                                                                                                           |
      | receipt_source invalid enum | { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": false, "receipt_source": "paper" } |
      | is_cancelled invalid bool   | { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": "maybe", "receipt_source": "platform" } |
      | data string not object      | { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": "x", "is_cancelled": false, "receipt_source": "platform" }       |


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": false, "receipt_source": "platform" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": false, "receipt_source": "platform" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json                                  |
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": false, "receipt_source": "platform" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id (org context unresolved) is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": false, "receipt_source": "platform" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "company_id": "{COMPANY_ID}", "identifier": "RCPT-1", "data": { "amount": 1 }, "is_cancelled": false, "receipt_source": "platform" }
      """
    When I send a "POST" request to "/recovery/generate/receipt"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: GET on the generate receipt endpoint is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/generate/receipt"
    Then the response status code should be 405

