@api @quick-allocation @recovery @allocation
Feature: Quick Allocation API — POST /recovery/allocation

  @negative @auth @creator
  Scenario: AUTH-001 — POST allocation without authenticationtoken header is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept       | application/json |
      | Content-Type | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response body should contain field "message"

  @negative @auth @creator
  Scenario: AUTH-002 — POST allocation with an invalid authenticationtoken is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json    |
      | authenticationtoken | invalid_token_12345 |
      | Content-Type        | application/json    |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response body should contain field "message"

  @negative @auth @creator
  Scenario: AUTH-003 — POST allocation with an expired-style token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json                                  |
      | authenticationtoken | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.expired.sig |
      | Content-Type        | application/json                                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @org @creator
  Scenario: ORG-001 — POST allocation without company_id query parameter is rejected at org resolution (400)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 403
    And the response body should not be empty
    And the response body should contain field "message"

  @negative @org @creator
  Scenario: ORG-002 — POST allocation with an unknown (random UUID) company_id is rejected at org resolution
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response body should contain field "message"

  @manual @negative @permission @approver
  Scenario: PERM-001 — POST allocation as a role without allocate_and_deallocate_loans:write returns 200
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the response body should not be empty

  @manual @negative @org @creator
  Scenario: ORG-003 — POST allocation for a valid company the caller is not a member of returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {OTHER_COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @validation @creator
  Scenario Outline: REQ-001 — Missing required field "<missing>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty
    And the response should match json schema "schemas/recovery/error/quick_allocation_error_schema.json"

    Examples:
      | missing              | body                                                                                          |
      | loan_ids             | { "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }     |
      | source               | { "loan_ids": ["Loan000631"], "allocation_type": "user", "allocation_algorithm": "one_to_one" }    |
      | allocation_type      | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_algorithm": "one_to_one" }        |
      | allocation_algorithm | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user" }                   |

  @negative @validation @creator
  Scenario: REQ-002 — All required fields absent (empty body object) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @validation @creator
  Scenario Outline: REQ-003 — Required field "<field>" present but null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | field                | body                                                                                                                |
      | loan_ids             | { "loan_ids": null, "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }         |
      | source               | { "loan_ids": ["Loan000631"], "source": null, "allocation_type": "user", "allocation_algorithm": "one_to_one" }          |
      | allocation_type      | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": null, "allocation_algorithm": "one_to_one" }     |
      | allocation_algorithm | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": null }           |

  @negative @validation @creator
  Scenario Outline: REQ-004 — Enum field "<field>" present but empty string returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | field                | body                                                                                                          |
      | source               | { "loan_ids": ["Loan000631"], "source": "", "allocation_type": "user", "allocation_algorithm": "one_to_one" }      |
      | allocation_type      | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "", "allocation_algorithm": "one_to_one" } |
      | allocation_algorithm | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "" }       |


  @negative @validation @type @creator
  Scenario Outline: TYPE-001 — "<case>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | case                                  | body                                                                                                                                  |
      | loan_ids as string not list           | { "loan_ids": "Loan000631", "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }                       |
      | loan_ids as integer                   | { "loan_ids": 123, "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }                            |
      | loan_ids as object                    | { "loan_ids": {}, "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }                             |
      | source as integer                     | { "loan_ids": ["Loan000631"], "source": 1, "allocation_type": "user", "allocation_algorithm": "one_to_one" }                              |
      | allocation_type as integer            | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": 5, "allocation_algorithm": "one_to_one" }                         |
      | allocation_algorithm as boolean       | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": true }                            |
      | workflow_id as non-numeric string     | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "workflow_id": "abc" } |
      | disable_previous flag as "yes"        | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "disable_previous_user_allocation": "yes" } |
      | neglect_capacity flag as "yes"        | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "neglect_user_allocation_capacity": "yes" } |
      | parent_company_id not a UUID          | { "loan_ids": ["Loan000631"], "source": "legal", "allocation_type": "agency", "allocation_algorithm": "one_to_one", "parent_company_id": "not-a-uuid" } |
      | selected_users value as string        | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "usr_abc1234567890xy": "five" } } |
      | user_filters value not a list         | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "user_filters": { "teams": "team-north" } } |

  @negative @validation @enum @creator
  Scenario Outline: ENUM-001 — Invalid enum value for "<field>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | field                | body                                                                                                                       |
      | source               | { "loan_ids": ["Loan000631"], "source": "bogus_src", "allocation_type": "user", "allocation_algorithm": "one_to_one" }          |
      | allocation_type      | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "bogus_type", "allocation_algorithm": "one_to_one" }    |
      | allocation_algorithm | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "bogus_algo" }          |


  @negative @validation @creator
  Scenario Outline: NEST-001 — selected_users "<case>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | case                          | body                                                                                                                                                   |
      | key shorter than 16 chars     | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "short_key": 5 } } |
      | key longer than 36 chars      | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "usr_this_key_is_definitely_far_too_long_to_be_valid": 5 } } |
      | value zero (not positive)     | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "usr_abc1234567890xy": 0 } } |
      | value negative                | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "usr_abc1234567890xy": -3 } } |

  @negative @validation @creator
  Scenario: NEST-002 — user_filters with a key outside the four allowed literals returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "user_filters": { "departments": ["sales"] } }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @validation @creator
  Scenario Outline: NEST-003 — attribute_matching "<case>" returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

    Examples:
      | case                        | body                                                                                                                                                                                          |
      | operator other than '='     | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "field", "allocation_algorithm": "one_to_one", "attribute_matching": [ { "operator": ">", "user_attribute": "city", "loan_attribute": "borrower_city" } ] } |
      | empty operator              | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "field", "allocation_algorithm": "one_to_one", "attribute_matching": [ { "operator": "", "user_attribute": "city", "loan_attribute": "borrower_city" } ] }  |
      | empty user_attribute        | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "field", "allocation_algorithm": "one_to_one", "attribute_matching": [ { "operator": "=", "user_attribute": "", "loan_attribute": "borrower_city" } ] }     |
      | empty loan_attribute        | { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "field", "allocation_algorithm": "one_to_one", "attribute_matching": [ { "operator": "=", "user_attribute": "city", "loan_attribute": "" } ] }              |


  @negative @boundary @creator
  Scenario: BOUND-001 — selected_users key one char below min (15) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "u15charslong123": 5 } }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @boundary @creator
  Scenario: BOUND-002 — selected_users key one char above max (37) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "usr_this_key_is_thirty_seven_chars_xx": 5 } }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

  @manual @positive @boundary @creator
  Scenario: BOUND-003 — selected_users key at min length 16 fails body validation
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "usr_16charskey00": 5 } }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the "quick_allocation" success response should be valid

  @manual @positive @boundary @creator
  Scenario: BOUND-004 — selected_users key at max length 36 fails body validation
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "selected_users": { "usr_this_key_is_exactly_36_chars_xxx": 5 } }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the "quick_allocation" success response should be valid

  @manual @positive @edge @creator
  Scenario: EDGE-001 — Empty attribute_matching array is accepted (default behaviour)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "attribute_matching": [] }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

  @manual @positive @edge @creator
  Scenario: EDGE-002 — Empty user_filters object is accepted (no filter keys)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "user_filters": {} }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

  @manual @positive @edge @creator
  Scenario: EDGE-003 — user_filters list with duplicate entries is tolerated
    Given I authenticate as "creator" slot 1 and remember as "creator1"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "calling", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "user_filters": { "teams": ["team-north", "team-north"], "roles": ["agent", "agent"] } }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

  @manual @positive @fuzz @creator
  Scenario: EDGE-004 — Fuzz inputs via placeholders (random loan id, random workflow_id) fails validation
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["LN_{RANDOM_STRING:8}"], "source": "api", "allocation_type": "user", "allocation_algorithm": "one_to_one", "workflow_id": {RANDOM_INT:1:99999} }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the "quick_allocation" success response should be valid


  @negative @business @creator
  Scenario: BIZ-001 — More than one loan id is rejected by the service (400)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631", "LN1002"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/quick_allocation_error_schema.json"
    And the quick allocation multi-loan rejection response should be valid

  @negative @business @creator
  Scenario: BIZ-002 — Three loan ids are also rejected (single-id rule) (400)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631", "LN1002", "LN1003"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the quick allocation multi-loan rejection response should be valid

  @manual @negative @business @creator
  Scenario: BIZ-003 — field + one_to_many without enable_multiple_field_allocations returns 400
    Given I authenticate as "creator" slot 1 and remember as "creator1"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "field", "allocation_algorithm": "one_to_many" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the quick allocation field one-to-many rejection response should be valid

  @manual @negative @business @creator @500
  Scenario: BIZ-004 — Agency allocation with no parent companies found returns a failure envelope
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "legal", "allocation_type": "agency", "allocation_algorithm": "one_to_one", "parent_company_id": "{UUID}" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the "quick_allocation" failure response should be valid

  @manual @negative @business @creator
  Scenario: BIZ-005 — Allocation for a valid-format but non-existent loan id returns a failure envelope
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["NON-EXISTENT-{UUID}"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

  @manual @edge @business @creator
  Scenario: BIZ-006 — Empty loan_ids array proceeds past the single-id check
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": [], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the response body should not be empty


  @manual @positive @creator
  Scenario: HAPPY-001 — Minimal required fields only (single loan, user / one_to_one) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/quick_allocation_success_schema.json"
    And the "quick_allocation" success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-002 — All optional fields populated returns 200
    Given I authenticate as "creator" slot 1 and remember as "creator1"
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
        "loan_ids": ["Loan000631"],
        "source": "workflow",
        "workflow_id": 42,
        "allocation_type": "telecalling",
        "allocation_algorithm": "load_balancing",
        "attribute_matching": [ { "operator": "=", "user_attribute": "city", "loan_attribute": "borrower_city" } ],
        "selected_users": { "{USER_ID:creator0}": 5 },
        "user_filters": { "professions": ["telecaller"], "teams": ["team-north"], "locations": ["maharashtra"], "roles": ["agent"] },
        "disable_previous_user_allocation": true,
        "neglect_user_allocation_capacity": true
      }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/quick_allocation_success_schema.json"
    And the "quick_allocation" success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-003 — selected_users (entity -> capacity) with a null capacity returns 200
    Given I authenticate as "creator" slot 2 and remember as "approver2"
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "workflow", "workflow_id": 42, "allocation_type": "telecalling", "allocation_algorithm": "load_balancing", "selected_users": { "{USER_ID:creator1}": 5, "{USER_ID:creator2}": null } }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-004 — user_filters with all four allowed keys returns 200
    Given I authenticate as "creator" slot 1 and remember as "creator1"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "calling", "allocation_type": "telecalling", "allocation_algorithm": "one_to_many", "user_filters": { "professions": ["telecaller"], "teams": ["team-north"], "locations": ["maharashtra"], "roles": ["agent"] } }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

  @manual @positive @creator
  Scenario: HAPPY-005 — attribute_matching with the only valid operator '=' returns 200
    Given I authenticate as "creator" slot 1 and remember as "creator1"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "field", "allocation_algorithm": "one_to_one", "attribute_matching": [ { "operator": "=", "user_attribute": "city", "loan_attribute": "borrower_city" } ] }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

  @manual @positive @creator
  Scenario Outline: HAPPY-006 — Boolean flags disable=<disable> neglect=<neglect> returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one", "disable_previous_user_allocation": <disable>, "neglect_user_allocation_capacity": <neglect> }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

    Examples:
      | disable | neglect |
      | true    | true    |
      | false   | false   |
      | true    | false   |
      | false   | true    |


  @manual @positive @creator
  Scenario Outline: HAPPY-008 — Each source enum value "<source>" is accepted (200)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "<source>", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

    Examples:
      | source       |
      | portfolio    |
      | workflow     |
      | excel        |
      | legal        |
      | calling      |
      | loan_upload  |
      | api          |
      | internal_api |

  @manual @positive @creator
  Scenario Outline: HAPPY-009 — Each allocation_type value "<type>" is accepted (200)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "<source>", "allocation_type": "<type>", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

    Examples:
      | type        | source    |
      | field       | portfolio |
      | telecalling | calling   |
      | other       | portfolio |
      | user        | portfolio |

  @manual @positive @creator
  Scenario Outline: HAPPY-010 — Each allocation_algorithm value "<algo>" is accepted (200)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "<type>", "allocation_algorithm": "<algo>" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid

    Examples:
      | algo           | type        |
      | one_to_one     | user        |
      | one_to_many    | telecalling |
      | load_balancing | user        |


  @negative @flow @creator
  Scenario: FLOW-001 — A rejected multi-loan POST followed by a fresh single-loan POST each behave independently
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631", "LN1002"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the quick allocation multi-loan rejection response should be valid
    And I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response body should not be empty

  @manual @flow @creator
  Scenario: FLOW-002 — Allocating the same loan twice is tolerated (re-run, no 409)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
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
      { "loan_ids": ["Loan000631"], "source": "portfolio", "allocation_type": "user", "allocation_algorithm": "one_to_one" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the "quick_allocation" success response should be valid
