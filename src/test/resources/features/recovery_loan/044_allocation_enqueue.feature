@api @allocation-enqueue @recovery @manual
Feature: Allocation Enqueue — POST /recovery/allocation/enqueue


  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"
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


  @positive @smoke @creator
  Scenario: Minimal required fields enqueues the allocation (202)
    Given I prepare a request
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
        "callback_details": {}
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the response should match json schema "schemas/recovery/success/allocation_enqueue_success_schema.json"
    And the "allocation_enqueue" success response should be valid

  @positive @creator
  Scenario: All optional fields populated enqueues the allocation (202)
    Given I prepare a request
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
        "allocation_algorithm": "load_balancing",
        "callback_details": { "callback_url": "https://example.com/cb", "ref": "batch-1" },
        "workflow_id": 9001,
        "attribute_matching": [ { "operator": "=", "user_attribute": "location", "loan_attribute": "state" } ],
        "user_filters": { "professions": ["collections"], "teams": ["team_a"], "locations": ["maharashtra"], "roles": ["agent"] },
        "disable_previous_user_allocation": true,
        "enable_previous_allocation": true,
        "neglect_user_allocation_capacity": true,
        "allowed_previous_days": 60
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the "allocation_enqueue" success response should be valid

  @positive @creator
  Scenario: selected_users (entity→capacity map) enqueues the allocation (202)
    Given I prepare a request
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
        "allocation_algorithm": "load_balancing",
        "callback_details": {},
        "selected_users": { "abcd1234efgh5678": 50, "ijkl9012mnop3456": null }
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the "allocation_enqueue" success response should be valid

  @positive @creator
  Scenario: user_filters with all four allowed keys enqueues the allocation (202)
    Given I prepare a request
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
        "allocation_type": "telecalling",
        "allocation_algorithm": "one_to_one",
        "callback_details": {},
        "user_filters": { "professions": ["collections"], "teams": ["team_a", "team_b"], "locations": ["maharashtra"], "roles": ["agent"] }
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the "allocation_enqueue" success response should be valid

  @positive @creator
  Scenario: attribute_matching with operator "=" enqueues the allocation (202)
    Given I prepare a request
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
        "allocation_type": "telecalling",
        "allocation_algorithm": "one_to_one",
        "callback_details": {},
        "attribute_matching": [ { "operator": "=", "user_attribute": "location", "loan_attribute": "state" } ]
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the "allocation_enqueue" success response should be valid

  @positive @creator
  Scenario: All boolean flags true enqueues the allocation (202)
    Given I prepare a request
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
        "allocation_type": "telecalling",
        "allocation_algorithm": "one_to_one",
        "callback_details": {},
        "disable_previous_user_allocation": true,
        "enable_previous_allocation": true,
        "neglect_user_allocation_capacity": true
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @positive @creator
  Scenario: All boolean flags false (explicit) with allowed_previous_days enqueues the allocation (202)
    Given I prepare a request
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
        "allocation_type": "telecalling",
        "allocation_algorithm": "one_to_one",
        "callback_details": {},
        "disable_previous_user_allocation": false,
        "enable_previous_allocation": false,
        "neglect_user_allocation_capacity": false,
        "allowed_previous_days": 30
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @positive @creator
  Scenario: workflow_id provided enqueues the allocation (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "source": "workflow",
        "allocation_type": "telecalling",
        "allocation_algorithm": "one_to_one",
        "callback_details": { "callback_url": "https://example.com/cb" },
        "workflow_id": 12345
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @positive @creator
  Scenario Outline: source enum value "<source>" is accepted (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "<source>", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

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

  @positive @creator
  Scenario Outline: allocation_algorithm "<algorithm>" with telecalling is accepted (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "<algorithm>", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

    Examples:
      | algorithm      |
      | one_to_one     |
      | one_to_many    |
      | load_balancing |

  @positive @creator
  Scenario Outline: allocation_type "<type>" with one_to_one is accepted (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "<type>", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

    Examples:
      | type        |
      | field       |
      | telecalling |
      | other       |
      | user        |

  @positive @creator
  Scenario: Unknown body field is silently dropped (extra="ignore") returns 202
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {}, "totally_unknown_field": "dropped" }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @positive @creator
  Scenario: Duplicate loan_ids entries are tolerated returns 202
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}", "{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @positive @creator @multistep
  Scenario: Upload loan then enqueue its allocation returns 202
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "loan_upload", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the "allocation_enqueue" success response should be valid


  @positive @boundary @creator
  Scenario: selected_users key at min length (16 chars) is accepted (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "load_balancing", "callback_details": {}, "selected_users": { "abcdefgh12345678": 10 } }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @positive @boundary @creator
  Scenario: selected_users key at max length (36 chars) is accepted (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "load_balancing", "callback_details": {}, "selected_users": { "abcdefgh-1234-5678-9012-abcdefgh3456": 10 } }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @negative @boundary @creator
  Scenario: selected_users key one under min (15 chars) returns 400 (REC_0076)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "load_balancing", "callback_details": {}, "selected_users": { "abcdefgh1234567": 10 } }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the allocation enqueue validation error should be valid

  @negative @boundary @creator
  Scenario: selected_users value zero (not positive) returns 400 (REC_0076)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "load_balancing", "callback_details": {}, "selected_users": { "abcdefgh12345678": 0 } }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the allocation enqueue validation error should be valid

  @positive @creator
  Scenario: Empty attribute_matching array (default) is accepted (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {}, "attribute_matching": [] }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @negative @creator @fuzz
  Scenario: Fuzz random loan id is structurally valid and still enqueues (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["LN_{RANDOM_STRING:12}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202

  @negative @boundary @creator
  Scenario: Empty loan_ids array is structurally valid (no min_items) and still enqueues (202)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": [], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202


  @negative @creator
  Scenario: field allocation_type with one_to_many without enable_multiple_field_allocations returns 400 (REC_0015)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "field", "allocation_algorithm": "one_to_many", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the response body should contain field "error.code" with value "REC_0015"


  @negative @creator
  Scenario: Empty body {} (all required absent) returns 400 (REC_0076)
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
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the allocation enqueue validation error should be valid

  @negative @creator
  Scenario Outline: Required field "<missing>" absent returns 400 (REC_0076)
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
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the allocation enqueue validation error should be valid

    Examples:
      | missing              | body                                                                                                                       |
      | loan_ids             | { "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }   |
      | source               | { "loan_ids": ["{LOAN_ID}"], "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }|
      | allocation_type      | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_algorithm": "one_to_one", "callback_details": {} }          |
      | allocation_algorithm | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "callback_details": {} }              |
      | callback_details     | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one" }|

  @negative @creator
  Scenario: loan_ids present but null returns 400 (REC_0076)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": null, "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the allocation enqueue validation error should be valid

  @negative @creator
  Scenario: source present but empty string returns 400 (REC_0076)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the allocation enqueue validation error should be valid


  @negative @creator
  Scenario Outline: Invalid field "<case>" returns 400 (REC_0076)
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
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the allocation enqueue validation error should be valid

    Examples:
      | case                              | body                                                                                                                                                                      |
      | loan_ids string not list          | { "loan_ids": "L1", "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }                                |
      | source invalid enum               | { "loan_ids": ["{LOAN_ID}"], "source": "not_a_source", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }                    |
      | allocation_type invalid enum      | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "bogus", "allocation_algorithm": "one_to_one", "callback_details": {} }                             |
      | allocation_algorithm invalid enum | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "round_robin", "callback_details": {} }                      |
      | callback_details string not obj   | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": "x" }                      |
      | attribute_matching bad operator   | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {}, "attribute_matching": [ { "operator": ">", "user_attribute": "a", "loan_attribute": "b" } ] } |
      | user_filters invalid key          | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {}, "user_filters": { "departments": ["x"] } } |
      | parent_company_id non-uuid        | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {}, "parent_company_id": "not-a-uuid" } |
      | workflow_id non-integer           | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {}, "workflow_id": "abc" } |
      | allowed_previous_days non-integer | { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {}, "allowed_previous_days": "ninety" } |


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
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
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
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
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
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
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
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
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @approver
  Scenario: Approver enqueues an allocation (no enforcement decorator on the route)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "loan_ids": ["{LOAN_ID}"], "source": "portfolio", "allocation_type": "telecalling", "allocation_algorithm": "one_to_one", "callback_details": {} }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202


  @negative @creator
  Scenario: GET on the allocation enqueue endpoint is not allowed (405)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/allocation/enqueue"
    Then the response status code should be 405

