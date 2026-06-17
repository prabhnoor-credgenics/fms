@api @quick-deallocation @recovery @allocation
Feature: Quick De-Allocation API — POST /recovery/deallocation

  @negative @auth @creator
  Scenario: AUTH-001 — POST deallocation without authenticationtoken header is rejected
    Given I prepare a request
    And I set the request headers:
      | accept       | application/json |
      | Content-Type | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response body should contain field "message"

  @negative @auth @creator
  Scenario: AUTH-002 — POST deallocation with an invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json    |
      | authenticationtoken | invalid_token_12345 |
      | Content-Type        | application/json    |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response body should contain field "message"

  @negative @auth @creator
  Scenario: AUTH-003 — POST deallocation with an expired-style token is rejected
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json                                  |
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
      | Content-Type        | application/json                                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @org @creator
  Scenario: ORG-001 — POST deallocation without company_id query parameter is rejected at org resolution (400)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response body should contain field "message"

  @negative @org @creator
  Scenario: ORG-002 — POST deallocation with an unknown (random UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response body should contain field "message"

  @manual @negative @permission @approver
  Scenario: PERM-001 — POST deallocation as a role without allocate_and_deallocate_loans:write returns 403
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 403
    And the response body should not be empty

  @manual @negative @org @creator
  Scenario: ORG-003 — POST deallocation for a valid company the caller is not a member of returns 403
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {OTHER_COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 403
    And the response body should not be empty


  @negative @validation @creator
  Scenario Outline: REQ-001 — Missing required field "<missing>" returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response should match json schema "schemas/recovery/error/quick_deallocation_error_schema.json"

    Examples:
      | missing  | body                         |
      | loan_ids | { "source": "portfolio" }    |
      | source   | { "loan_ids": ["LN1001"] }   |

  @negative @validation @creator
  Scenario: REQ-002 — All required fields absent (empty body object) returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @validation @creator
  Scenario Outline: REQ-003 — Required field "<field>" present but null returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | field    | body                                          |
      | loan_ids | { "loan_ids": null, "source": "portfolio" }   |
      | source   | { "loan_ids": ["LN1001"], "source": null }    |

  @negative @validation @creator
  Scenario: REQ-004 — Required enum field source present but empty string returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

  # =====================================================================
  # FIELD TYPE / FORMAT VALIDATION (400)
  # =====================================================================

  @negative @validation @type @creator
  Scenario Outline: TYPE-001 — "<case>" returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | case                                  | body                                                                                                          |
      | loan_ids as string not list           | { "loan_ids": "LN1001", "source": "portfolio" }                                                               |
      | loan_ids as integer                   | { "loan_ids": 123, "source": "portfolio" }                                                                    |
      | loan_ids as object                    | { "loan_ids": {}, "source": "portfolio" }                                                                     |
      | source as integer                     | { "loan_ids": ["LN1001"], "source": 1 }                                                                       |
      | allocation_type as integer            | { "loan_ids": ["LN1001"], "source": "portfolio", "allocation_type": 5 }                                       |
      | workflow_id as non-numeric string     | { "loan_ids": ["LN1001"], "source": "portfolio", "workflow_id": "abc" }                                       |
      | parent_company_id not a UUID          | { "loan_ids": ["LN1001"], "source": "legal", "allocation_type": "agency", "parent_company_id": "not-a-uuid" } |
      | user_filters value not a list         | { "loan_ids": ["LN1001"], "source": "portfolio", "user_filters": { "teams": "team-north" } }                  |
      | selected_users value is a string      | { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_abc1234567890xy": "x" } }           |

  @negative @validation @enum @creator
  Scenario Outline: ENUM-001 — Invalid enum value for "<field>" returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | field           | body                                                                                |
      | source          | { "loan_ids": ["LN1001"], "source": "bogus_src" }                                   |
      | allocation_type | { "loan_ids": ["LN1001"], "source": "portfolio", "allocation_type": "bogus_type" }  |


  @negative @validation @creator
  Scenario Outline: NEST-001 — selected_users "<case>" returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | case                              | body                                                                                                                                            |
      | key shorter than 16 chars         | { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "short_key": null } }                                                      |
      | key longer than 36 chars          | { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_this_key_is_definitely_far_too_long_to_be_valid": null } }            |
      | value is a positive integer       | { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_abc1234567890xy": 5 } }                                               |
      | value is zero                     | { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_abc1234567890xy": 0 } }                                               |
      | value is a boolean                | { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_abc1234567890xy": true } }                                            |

  @negative @validation @creator
  Scenario: NEST-002 — user_filters with a key outside the four allowed literals returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio", "user_filters": { "departments": ["sales"] } }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @boundary @creator
  Scenario: BOUND-001 — selected_users key one char below min (15) returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "u15charslong123": null } }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @boundary @creator
  Scenario: BOUND-002 — selected_users key one char above max (37) returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_this_key_is_thirty_seven_chars_xx": null } }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty

  @manual @positive @boundary @creator
  Scenario: BOUND-003 — selected_users key at min length 16 (value null) passes body validation
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_16charskey00": null } }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

  @manual @positive @boundary @creator
  Scenario: BOUND-004 — selected_users key at max length 36 (value null) passes body validation
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_this_key_is_exactly_36_chars_xxx": null } }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

  @manual @positive @edge @creator
  Scenario: EDGE-001 — Empty user_filters object is accepted (no filter keys)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio", "user_filters": {} }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

  @manual @positive @edge @creator
  Scenario: EDGE-002 — user_filters list with duplicate entries is tolerated
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "calling", "allocation_type": "telecalling", "user_filters": { "teams": ["team-north", "team-north"], "roles": ["agent", "agent"] } }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

  @manual @positive @fuzz @creator
  Scenario: EDGE-003 — Fuzz inputs via placeholders (random loan id, random workflow_id) pass validation
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN_{RANDOM_STRING:8}"], "source": "api", "allocation_type": "user", "workflow_id": {RANDOM_INT:1:99999} }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid


  @negative @business @creator
  Scenario: BIZ-001 — More than one loan id is rejected by the service (400)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001", "LN1002"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/quick_deallocation_error_schema.json"
    And the quick deallocation multi-loan rejection response should be valid

  @negative @business @creator
  Scenario: BIZ-002 — Three loan ids are also rejected (single-id rule) (400)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001", "LN1002", "LN1003"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the quick deallocation multi-loan rejection response should be valid

  @manual @negative @business @creator
  Scenario: BIZ-003 — Neither loan_ids nor entities provided returns 400 (intended)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": [], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the quick deallocation no-input rejection response should be valid

  @manual @positive @business @workflow @creator
  Scenario: BIZ-004 — source=workflow on a loan with no allocation short-circuits to 200
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["NO-ALLOC-{UUID}"], "source": "workflow", "workflow_id": 42 }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation workflow short-circuit response should be valid

  @manual @negative @business @creator
  Scenario: BIZ-005 — Agency de-allocation with no parent companies found returns a failure envelope
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "legal", "allocation_type": "agency", "parent_company_id": "{UUID}" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the quick deallocation failure response should be valid

  @manual @negative @business @creator
  Scenario: BIZ-006 — De-allocation for a valid-format but non-existent loan id returns a failure envelope
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["NON-EXISTENT-{UUID}"], "source": "portfolio", "allocation_type": "user" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response body should not be empty


  @manual @positive @creator
  Scenario: HAPPY-001 — Minimal required fields only (single loan, source only) returns 200
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/quick_deallocation_success_schema.json"
    And the quick deallocation success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-002 — All optional fields populated returns 200
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "loan_ids": ["LN1001"],
        "source": "workflow",
        "workflow_id": 77,
        "allocation_type": "telecalling",
        "selected_users": { "usr_abc1234567890xy": null },
        "user_filters": { "professions": ["telecaller"], "teams": ["team-north"], "locations": ["maharashtra"], "roles": ["agent"] }
      }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/quick_deallocation_success_schema.json"
    And the quick deallocation success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-003 — selected_users with multiple null-valued entity ids returns 200
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio", "selected_users": { "usr_abc1234567890xy": null, "usr_def1234567890zz": null } }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-004 — user_filters with all four allowed keys returns 200
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "calling", "allocation_type": "telecalling", "user_filters": { "professions": ["telecaller"], "teams": ["team-north"], "locations": ["maharashtra"], "roles": ["agent"] } }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-005 — Agency de-allocation with parent_company_id returns 200
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "legal", "allocation_type": "agency", "parent_company_id": "{PARENT_COMPANY_ID}" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-006 — allocation_type omitted defaults to "other" and returns 200
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "excel" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

  @manual @positive @creator
  Scenario Outline: HAPPY-007 — Each source enum value "<source>" is accepted (200)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "<source>" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

    Examples:
      | source       |
      | portfolio    |
      | excel        |
      | legal        |
      | user_service |
      | loan_archive |
      | data_purge   |
      | calling      |
      | api          |
      | internal_api |

  @manual @positive @creator
  Scenario Outline: HAPPY-008 — Each allocation_type value "<type>" is accepted (200)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "<source>", "allocation_type": "<type>" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid

    Examples:
      | type        | source    |
      | field       | portfolio |
      | telecalling | calling   |
      | other       | portfolio |
      | user        | portfolio |


  @negative @flow @creator
  Scenario: FLOW-001 — A rejected multi-loan POST followed by a fresh single-loan POST each behave independently
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001", "LN1002"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the quick deallocation multi-loan rejection response should be valid
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "portfolio" }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response body should not be empty

  @manual @flow @creator
  Scenario: FLOW-002 — De-allocating the same loan twice is tolerated (re-run, no 409)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "workflow", "workflow_id": 42 }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN1001"], "source": "workflow", "workflow_id": 42 }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And the quick deallocation success response should be valid
