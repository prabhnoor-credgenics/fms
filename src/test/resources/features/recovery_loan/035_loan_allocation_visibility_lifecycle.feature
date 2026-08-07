@api @recovery @allocation @loan-lifecycle
Feature: Loan allocation visibility lifecycle


  @manual @creator
  Scenario: A loan allocated to the creator becomes visible, then invisible after de-allocation
    Given scenario loan id is unique

    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I store the current user id from the user profile
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    Then the response status code should be one of "201"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | search_type | loan_id      |
      | query       | {LOAN_ID}    |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
        "selected_users": { "{CREATOR_USER_ID}": null }
      }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | search_type | loan_id      |
      | query       | {LOAN_ID}    |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"



  @manual @creator
  Scenario: A loan uploaded by creator should be visible to the creator
    Given scenario loan id is unique

    And I authenticate as "creator" slot 0 and remember as "creator0"
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
    Then the response status code should be one of "201"
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | search_type | loan_id      |
      | query       | {LOAN_ID}    |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/all-loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"



  @manual @creator @get-loan
  Scenario: Allocated loan is visible via get-loan API, then invisible after de-allocation
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I store the current user id from the user profile
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    Then the response status code should be one of "201"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | loan         |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/loan/{loanId}" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
        "selected_users": { "{CREATOR_USER_ID}": null }
      }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | loan         |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/loan/{loanId}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"


  @manual @creator @linked-loans
  Scenario: Allocated loan is visible via linked-loans API, then invisible after de-allocation
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I store the current user id from the user profile
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    Then the response status code should be one of "201"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | loan_id          | {LOAN_ID}    |
      | allocation_month | overall      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/linked/loans" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
        "selected_users": { "{CREATOR_USER_ID}": null }
      }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | loan_id          | {LOAN_ID}    |
      | allocation_month | overall      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/linked/loans"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"


  @manual @creator @loan-details
  Scenario: Allocated loan is editable via loan-details API, then rejected after de-allocation
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I store the current user id from the user profile
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    Then the response status code should be one of "201"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
        "source": "platform",
        "applicant_attributes": {
          "applicant_name": "VisibilityProbe"
        },
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
        "selected_users": { "{CREATOR_USER_ID}": null }
      }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      {
        "source": "platform",
        "applicant_attributes": {
          "applicant_name": "VisibilityProbe"
        },
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200


  @manual @creator @v3-loan-details
  Scenario: Allocated loan is visible via v3 loan details API, then invisible after de-allocation
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I store the current user id from the user profile
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    Then the response status code should be one of "201"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/v3/loans/{loan_id}" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
        "selected_users": { "{CREATOR_USER_ID}": null }
      }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"


  @manual @creator @v1-loan-details
  Scenario: Allocated loan is visible via get loan v1 API, then invisible after de-allocation
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I store the current user id from the user profile
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    Then the response status code should be one of "201"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/v1/loans/{loan_id}" until the response body contains "{LOAN_ID}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
        "selected_users": { "{CREATOR_USER_ID}": null }
      }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 200
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/v1/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"


  @manual @creator
  Scenario: A loan not allocated to the creator should not be accessible
    Given scenario loan id is unique

    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I store the current user id from the user profile
    And I authenticate as "approver" slot 0 and remember as "approver0"
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
    Then the response status code should be one of "201"
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | search_type | loan_id      |
      | query       | {LOAN_ID}    |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not contain text "{LOAN_ID}"
