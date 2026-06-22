@api @recovery @multi-user @all-loans @visibility
Feature: Cross-slot loan visibility in all-loans




  @manual @creator
  Scenario: A loan uploaded by slot 0 is visible in all-loans to the slot 1 user (reports to slot 1)
    Given scenario loan id is unique

    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I authenticate as "creator" slot 1 and remember as "creator1"

    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json      |
      | authenticationtoken | {AUTH_TOKEN:creator0} |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"

    And I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID:creator1} |
      | search_type | loan_id               |
      | query       | {LOAN_ID}             |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:creator1} |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"


  @manual @creator
  Scenario: A loan uploaded by slot 0 is NOT visible in all-loans to the slot 2 user (not under slot 2)
    Given scenario loan id is unique

    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I authenticate as "creator" slot 2 and remember as "creator2"

    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json      |
      | authenticationtoken | {AUTH_TOKEN:creator0} |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"

    And I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID:creator2} |
      | search_type | loan_id               |
      | query       | {LOAN_ID}             |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:creator2} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"
