@api @recovery @multi-user @allocation @loan-lifecycle
Feature: Multi-user reporting hierarchy — four users authenticated at once



  @manual @multi-user-auth
  Scenario: All four users in the hierarchy authenticate and every token is independently usable

    Given I authenticate as "approver" slot 0 and remember as "u0"
    And I authenticate as "creator" slot 0 and remember as "u1"
    And I authenticate as "creator" slot 1 and remember as "u11"
    And I authenticate as "creator" slot 2 and remember as "u2"


    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:u0} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:u0} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200

    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:u1} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:u1} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200

    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:u11} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:u11} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200

    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:u2} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:u2} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200


  @manual @multi-user-auth @visibility
  Scenario: A loan u0 allocates to u1 is visible to u1 but not to peer creator u2
    Given scenario loan id is unique


    And I authenticate as "approver" slot 0 and remember as "u0"
    And I authenticate as "creator" slot 0 and remember as "u1"
    And I authenticate as "creator" slot 2 and remember as "u2"


    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:u0} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN:u0}  |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"


    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:u0} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN:u0}  |
    And I set the request body:
      """
      {
        "loan_ids": ["{LOAN_ID}"],
        "source": "portfolio",
        "allocation_type": "other",
        "allocation_algorithm": "one_to_one",
        "selected_users": { "{USER_ID:u1}": null }
      }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID:u1} |
      | search_type | loan_id         |
      | query       | {LOAN_ID}       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:u1} |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"


    And I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID:u2} |
      | search_type | loan_id         |
      | query       | {LOAN_ID}       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:u2} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"
