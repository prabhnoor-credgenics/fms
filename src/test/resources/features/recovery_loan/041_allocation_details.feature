@api @allocation-details @recovery
Feature: Allocation Details fetch — POST /recovery/allocation/details


  @positive @smoke @creator
  Scenario: Filter by a single loan_id returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/allocation_details_success_schema.json"
    And the allocation details success response should be valid

  @positive @creator
  Scenario: Filter by multiple loan_ids returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001", "LOAN0002", "LOAN0003"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200
    And the allocation details success response should be valid

  @positive @creator
  Scenario: Filter by a single 16-char allocated_user_id returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocated_user_ids": ["abcd1234efgh5678"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200
    And the allocation details success response should be valid

  @positive @creator
  Scenario: Filter by multiple allocated_user_ids returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocated_user_ids": ["abcd1234efgh5678", "ijkl9012mnop3456"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200
    And the allocation details success response should be valid

  @positive @creator
  Scenario: Both filters together (loan_ids AND allocated_user_ids) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001", "LOAN0002"], "allocated_user_ids": ["abcd1234efgh5678"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200
    And the allocation details success response should be valid

  @positive @boundary @creator
  Scenario: allocated_user_id at exactly the 16-char boundary is accepted (200)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocated_user_ids": ["1234567890123456"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200

  @positive @creator
  Scenario: Duplicate loan_ids entries are tolerated (200)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001", "LOAN0001"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200

  @positive @creator
  Scenario: Unknown body field is silently dropped (extra="ignore") returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001"], "totally_unknown_field": "dropped", "extra_number": 99 }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200

  @positive @creator
  Scenario: Whitespace-padded loan_id is stripped (anystr_strip_whitespace) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["  LOAN0001  "] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200

  @positive @creator
  Scenario: loan_id with leading/trailing single quotes is sanitized and accepted (200)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["'LOAN0001'"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200

  @positive @creator
  Scenario: Non-existent valid-format loan_id returns 200 with empty output (not 404)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["NON-EXISTENT-{UUID}"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200
    And the allocation details success response should be valid

  @positive @fuzz @creator
  Scenario: Fuzz loan_id ({RANDOM_STRING}) is accepted (200)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LN_{RANDOM_STRING:8}"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200

  @positive @fuzz @creator
  Scenario: Fuzz 16-char allocated_user_id ({RANDOM_STRING:16}) is accepted (200)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocated_user_ids": ["{RANDOM_STRING:16}"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200

  @positive @creator @approver
  Scenario: A non-creator role (approver) may call the lookup — no permission submodule on this route
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200


  @manual @other-pod @creator @multistep
  Scenario: Upload a loan, allocate it to the creator, then read the allocation back by loan_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I store the current user id from the user profile
    And scenario loan id is unique
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I authenticate as "creator" slot 1 and remember as "creator1"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator1} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN:creator1}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "source": "portfolio",
        "allocation_type": "other",
        "allocation_algorithm": "one_to_one",
        "selected_users": { "{USER_ID:creator0}": null }
      }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200
    And the allocation details success response should be valid
    And the allocation details output should contain loan "{LOAN_ID}"

  @manual @other-pod @creator @multistep
  Scenario: Read the allocation back by the creator's allocated_user_id returns the loan
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I store the current user id from the user profile
    And scenario loan id is unique
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    And I authenticate as "creator" slot 1 and remember as "creator1"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "source": "portfolio",
        "allocation_type": "other",
        "allocation_algorithm": "one_to_one",
        "selected_users": { "{CREATOR_USER_ID}": null }
      }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocated_user_ids": ["{CREATOR_USER_ID}"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 200
    And the allocation details output should contain loan "{LOAN_ID}"


  @negative @creator
  Scenario: Empty body {} (no filters) returns 400
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
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the allocation details failure response should be valid

  @negative @creator
  Scenario: Both filters null returns 400 (Please send loan_ids or allocated_user_ids)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": null, "allocated_user_ids": null }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the allocation details failure response should be valid

  @negative @creator
  Scenario: Both filters empty arrays returns 400 (Please send loan_ids or allocated_user_ids)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": [], "allocated_user_ids": [] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the allocation details failure response should be valid

  @negative @creator
  Scenario: loan_id with an embedded single quote is rejected (400)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["bad'id"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the allocation details failure response should be valid


  @negative @boundary @creator
  Scenario Outline: allocated_user_id length "<case>" (not exactly 16) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "allocated_user_ids": ["<value>"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the allocation details failure response should be valid

    Examples:
      | case            | value             |
      | 15 (one below)  | abcd1234efgh567   |
      | 17 (one above)  | abcd1234efgh56789 |
      | 1 (far below)   | x                 |

  @negative @creator
  Scenario Outline: wrong field type "<case>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the allocation details failure response should be valid

    Examples:
      | case                              | body                                            |
      | loan_ids as string not list       | { "loan_ids": "LOAN0001" }                      |
      | loan_ids as integer               | { "loan_ids": 12345 }                           |
      | allocated_user_ids as string      | { "allocated_user_ids": "abcd1234efgh5678" }    |
      | allocated_user_ids int wrong length| { "allocated_user_ids": [123] }                 |


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Expired-style authenticationtoken is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json                                  |
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id (org context unresolved) is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LOAN0001"] }
      """
    When I send a "POST" request to "/recovery/allocation/details"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: GET on the allocation details endpoint is not allowed (405)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    When I send a "GET" request to "/recovery/allocation/details"
    Then the response status code should be 405

