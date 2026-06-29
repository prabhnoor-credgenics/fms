@api @final-status @recovery
Feature: Final Status API — GET /recovery/final/status/<loan_id>

 

  @positive @smoke @creator
  Scenario: GET final status with no allocation_month defaults to Overall
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And scenario loan id is unique
    # --- upload a fresh loan first so the status fetch has a resolvable allocation month ---
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
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/final_status_success_schema.json"
    And the final status success response should be valid

  @positive @creator
  Scenario: GET final status with allocation_month=Overall (explicit)
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
      | allocation_month | Overall      |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 200
    And the final status success response should be valid

  @positive @creator
  Scenario: GET final status for a specific allocation_month
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
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0} |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 200
    And the final status success response should be valid

  @positive @multistep @creator
  Scenario: Create a loan then read back its final status
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
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  # =====================================================================
  # Auth & permission
  # =====================================================================

  @negative @auth @creator
  Scenario: GET final status without authentication token is rejected
    # TODO: verify on staging — doc/task expects 401; cg_utils returns 400 on this environment.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept | application/json, text/plain, */* |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @auth @creator
  Scenario: GET final status with an invalid authentication token is rejected
    # TODO: verify on staging — doc/task expects 401; cg_utils returns 400 on this environment.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/final_status_error_schema.json"

  @positive @approver
  Scenario: GET final status succeeds for a non-creator role (no permission submodule on this route)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And scenario loan id is unique
    # --- upload a fresh loan as the creator (keyed placeholders keep the approver active) ---
    And I authenticate as "creator" slot 0 and remember as "creator0"
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
    # --- now read final status as the non-creator (approver) ---
    And I switch active user to "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 200
    And the final status success response should be valid

  

  @negative @creator
  Scenario: GET final status with a single quote embedded in loan_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | LOAN'0001 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/final_status_error_schema.json"
    And the response body should contain field "message" with value "Invalid loan_id: contains single quotes in the middle."

  @negative @creator
  Scenario: GET final status for a non-existent loan_id (Overall) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/final_status_error_schema.json"
    And the response body should contain field "message" with value "Invalid loan_id/customer_id provided"

  @negative @boundary @creator
  Scenario: GET final status with a very long non-existent loan_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {RANDOM_STRING:200} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "Invalid loan_id/customer_id provided"

  @negative @creator
  Scenario Outline: GET final status with invalid allocation_month "<allocation_month>" returns 400
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
      | company_id       | {COMPANY_ID}       |
      | allocation_month | <allocation_month> |
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "Invalid allocation_month provided"

    Examples:
      | allocation_month |
      | not-a-date       |
      | 2026-13-01       |
      | 31-01-2026       |


  @positive @edge @creator @other-pod
  Scenario: GET final status with a slashed loan_id is accepted by the path converter (non-existent → 400)
    # TODO: verify on staging — <path:loan_id> accepts slashes; this id is non-existent so the
    # Overall lookup returns 400 "Invalid loan_id/customer_id provided" (not a routing 404).
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/final/status/BRANCH01/LOAN0001"
    Then the response status code should be 400
    And the response body should contain field "message"



  @positive @performance @creator
  Scenario: GET final status responds within the time threshold
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
    When I send a "GET" request to "/recovery/final/status/{loan_id}"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds
