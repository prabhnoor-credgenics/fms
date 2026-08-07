@api @allocation @allocation-enqueue @recovery
Feature: Allocation — algorithm, capacity & breach coverage (POST /recovery/allocation[/enqueue])

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
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201


  @positive @approver @algorithm
  Scenario Outline: <tc> — <type>/<algorithm> allocation is accepted (enqueued 202)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
        "allocation_type": "<type>",
        "allocation_algorithm": "<algorithm>",
        "callback_details": {}
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the response body should not be empty


    Examples:
      | tc         | type        | algorithm      |
      | TC_ALC_006 | field       | one_to_one     |
      | TC_ALC_007 | field       | load_balancing |
      | TC_ALC_008 | other       | one_to_one     |
      | TC_ALC_009 | other       | one_to_many    |
      | TC_ALC_014 | telecalling | one_to_one     |


  @positive @approver @capacity
  Scenario: TC_ALC_011 — Allocation within a user's capacity is accepted
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
        "callback_details": {},
        "selected_users": { "abcd1234efgh5678": 100 }
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the response body should not be empty

  @positive @approver @capacity @breach
  Scenario: TC_ALC_013 — Breach-capacity (neglect_user_allocation_capacity=true) allows over-capacity allocation
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
        "callback_details": {},
        "selected_users": { "abcd1234efgh5678": 1 },
        "neglect_user_allocation_capacity": true
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the response body should not be empty

  @negative @approver @capacity
  Scenario: TC_ALC_010 — Capacity of 0 is rejected (must be a number greater than zero)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
        "callback_details": {},
        "selected_users": { "{USER_ID:creator0}": 0 }
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator @capacity
  Scenario: TC_ALC_010b — Non-numeric capacity is rejected
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
        "callback_details": {},
        "selected_users": { "{USER_ID:creator0}": "not_a_number" }
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator @capacity @multistep
  Scenario: TC_ALC_012 — Over-capacity selection is enqueued; capacity enforcement happens async
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
        "callback_details": {},
        "selected_users": { "{USER_ID:creator0}": 1 }
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the response body should not be empty


  @positive @creator @async
  Scenario: TC_ALC_027 — Bulk (async) allocation is queued for processing (202)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
        "callback_details": {}
      }
      """
    When I send a "POST" request to "/recovery/allocation/enqueue"
    Then the response status code should be 202
    And the response body should not be empty


  @positive @creator @async
  Scenario: TC_ALC_028 — Bulk (async) deallocation is queued for processing (202)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
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
        "callback_details": {}
      }
      """
    When I send a "POST" request to "/recovery/deallocation/enqueue"
    Then the response status code should be 202
    And the response message should be "Loan deallocation task has been accepted"


  @positive @creator @user-count
  Scenario: TC_ALC_029 — Fetch allocation user count for a selection returns the summary
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "user_ids": ["abcd1234efgh5678"],
        "add_empty_as_zero": true,
        "fetch_unallocated_loans_count": true
      }
      """
    When I send a "POST" request to "/recovery/allocation/user/count"
    Then the response status code should be one of "200"
    And the response body should not be empty

  @negative @creator @user-count
  Scenario: TC_ALC_029b — User count with an empty user_ids list is rejected (min length 1)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "user_ids": [] }
      """
    When I send a "POST" request to "/recovery/allocation/user/count"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator @user-count
  Scenario: TC_ALC_029c — User count with a user_id not 16 chars is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "user_ids": ["short_id"] }
      """
    When I send a "POST" request to "/recovery/allocation/user/count"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator @validation
  Scenario: TC_ALC_031 — Allocating to a non-existent/deleted user is rejected (users don't match)
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
        "selected_users": { "deaduser000000000": null }
      }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response body should not be empty

