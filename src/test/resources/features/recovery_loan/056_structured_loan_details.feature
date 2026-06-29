@api @structured-loan-details @recovery
Feature: Structured Loan Details API — GET /recovery/loan/details/<loan_id>



  @positive @smoke @creator
  Scenario: GET structured loan details with no fields param defaults to "all"
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @creator
  Scenario: GET structured loan details with fields=all returns every category
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | all          |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @creator
  Scenario: GET structured loan details with fields=loan returns loan_details
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | loan         |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "message" with value "success"
    And the response body should contain field "output.loan_details"

  @positive @creator
  Scenario: GET structured loan details with fields=applicant returns applicant_details
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | applicant    |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "message" with value "success"
    And the response body should contain field "output.applicant_details"

  @positive @creator
  Scenario: GET structured loan details with fields=recovery returns recovery_details
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | recovery     |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "message" with value "success"
    And the response body should contain field "output.recovery_details"

  @positive @creator
  Scenario: GET structured loan details with fields=additional_details returns additional_details
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}       |
      | fields     | additional_details |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "message" with value "success"
    And the response body should contain field "output.additional_details"

  @positive @creator
  Scenario Outline: GET structured loan details accepts fields selector "<fields>"
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | <fields>     |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

    Examples:
      | fields             |
      | all                |
      | loan               |
      | applicant          |
      | recovery           |
      | additional_details |

  @positive @creator
  Scenario: GET structured loan details with multiple comma-separated fields
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}              |
      | fields     | loan,applicant,recovery   |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"


  @positive @creator
  Scenario: GET structured loan details for a single allocation_month
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | fields           | recovery                    |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @creator
  Scenario: GET structured loan details additional_details for a specific allocation_month
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                |
      | fields           | additional_details          |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @creator
  Scenario: GET structured loan details combined — full detail for one month
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                  |
      | fields           | loan,applicant,recovery,additional_details    |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}                   |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

 

  @positive @edge @creator
  Scenario: GET structured loan details with an unknown fields token is silently ignored
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}     |
      | fields     | loan,bogus_token |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @edge @creator
  Scenario: GET structured loan details for an unknown loan_id returns 200 with empty output (no 404)
    # TODO: verify on staging — doc specifies the where-clause simply matches no rows → output={}, still 200.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | all          |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @edge @creator
  Scenario: GET structured loan details with an unvalidated allocation_month still returns 200
    # TODO: verify on staging — doc states allocation_month is a raw equality match with NO format
    # validation on this route; a non-matching value yields empty recovery/additional sections but 200.
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | fields           | recovery     |
      | allocation_month | not-a-date   |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  # =====================================================================
  # Negative — authentication (mirrors sibling recovery GET routes: 400 on staging)
  # =====================================================================

  @negative @auth @creator
  Scenario: GET structured loan details without authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept | application/json, text/plain, */* |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @auth @creator
  Scenario: GET structured loan details with an invalid authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  
  @positive @performance @creator
  Scenario: GET structured loan details responds within the time threshold
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | all          |
    When I send a "GET" request to "/recovery/loan/details/{loan_id}"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds
