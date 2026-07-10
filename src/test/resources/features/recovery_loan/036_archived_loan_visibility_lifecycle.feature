@api @recovery @data-operations @archive @loan-lifecycle
Feature: Archived loan visibility lifecycle


  @manual @creator
  Scenario: A loan allocated to the creator is visible, then hidden after the approver archives it, then not visible again after unarchive
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
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
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
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
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
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


  # ---------------------------------------------------------------------------
  # Same allocate -> visible -> archive -> hidden -> unarchive -> hidden
  # lifecycle as above, but the visibility oracle is a different read API each
  # time. Archive/unarchive are performed by the approver via data-operations;
  # the creator checks visibility through the target API at each stage.
  # ---------------------------------------------------------------------------

  @manual @creator @get-loan
  Scenario: Archived loan visibility lifecycle verified via get-loan API
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
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
    # Allocated -> visible via get-loan
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
    # Approver archives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Archived -> loan hidden via get-loan (poll for eventual-consistency propagation)
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | fields     | loan         |
    And I set the path parameters:
      | loanId | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/loan/{loanId}" until the response body does not contain "{LOAN_ID}"
    Then the response body should not contain text "{LOAN_ID}"
    # Approver unarchives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Unarchived -> loan visible again via get-loan (archive flag cleared; API not allocation-scoped)
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


  @manual @creator @linked-loans
  Scenario: Archived loan visibility lifecycle verified via linked-loans API
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
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
    # Allocated -> visible via linked-loans
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
    # Approver archives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Archived -> loan hidden via linked-loans (poll for eventual-consistency propagation)
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | loan_id          | {LOAN_ID}    |
      | allocation_month | overall      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/linked/loans" until the response body does not contain "{LOAN_ID}"
    Then the response body should not contain text "{LOAN_ID}"
    # Approver unarchives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Unarchived -> loan visible again via linked-loans (archive flag cleared; API not allocation-scoped)
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


  @manual @creator @loan-details
  Scenario: Archived loan editability lifecycle verified via loan-details API
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
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
    # Allocated -> loan-details PATCH accepted (200)
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
    # Approver archives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Archived, but loan-details PATCH is NOT allocation/archive-scoped -> still accepted (200)
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
  Scenario: Archived loan visibility lifecycle verified via v3 loan details API
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
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
    # Allocated -> visible via v3 loan details
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
    And the v3 loan response should contain data for loan "{LOAN_ID}"
    # Approver archives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Archived -> loan hidden via v3 loan details (poll for eventual-consistency propagation)
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/v3/loans/{loan_id}" until the response body does not contain "{LOAN_ID}"
    Then the response body should not contain text "{LOAN_ID}"
    # Approver unarchives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Unarchived -> loan visible again via v3 loan details (archive flag cleared; API not allocation-scoped)
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
    And the v3 loan response should contain data for loan "{LOAN_ID}"


  @manual @creator @v1-loan-details
  Scenario: Archived loan visibility lifecycle verified via get loan v1 API
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
    And I update JSON field "loan_id" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" to "{ALLOCATION_MONTH_OFFSET:0}"
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
    # Allocated -> visible via v1 loan details
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
    And the v1 loan details response should contain loan "{LOAN_ID}"
    # Approver archives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "archive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Archived -> loan hidden via v1 loan details (poll for eventual-consistency propagation)
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I poll a "GET" request to "/recovery/v1/loans/{loan_id}" until the response body does not contain "{LOAN_ID}"
    Then the response body should not contain text "{LOAN_ID}"
    # Approver unarchives the loan
    And I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "category": "loan",
        "operation_type": "unarchive",
        "data": ["{LOAN_ID}"],
        "allocation_month": "{ALLOCATION_MONTH_OFFSET:0}",
        "execution_mode": "real-time"
      }
      """
    When I send a "POST" request to "/recovery/data-operations"
    Then the response status code should be 200
    And the response body should not be empty
    # Unarchived -> loan visible again via v1 loan details (archive flag cleared; API not allocation-scoped)
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
    And the v1 loan details response should contain loan "{LOAN_ID}"
