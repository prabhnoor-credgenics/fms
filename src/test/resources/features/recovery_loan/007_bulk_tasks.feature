@api @bulk-tasks @recovery
Feature: Bulk tasks API

  @chief-admin
  Scenario: Verify get bulk tasks API request
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id     | 3e561a13-3be3-4672-85b0-e1c49a35d8fb |
      | page_size      |                                   10 |
      | event_type     | import_operations                    |
      | operation_type | loan_upload                          |
      | page           |                                    1 |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/recovery/success/recovery_bulk_tasks_success_schema.json"
    And the response body should contain field "success"
    And the response body should contain field "output"
    And the response body should contain field "output[0].status"
    And the response body should contain field "output[0].total_count"
    And the response body should contain field "output[0].success_count"
    And the response body should contain field "output[0].failure_count"
    And the response body should contain field "output[0].data_link"
    And the response body should contain field "output[0].data_key"
    #  And the response body should contain field "output[0].error_logs_link"
    #   And the response body should contain field "output[0].error_logs_key"
    And the response body should contain field "output[0].processing_started_at"
    And the response body should contain field "output[0].updated"
    And the response body should contain field "output[0].created"
    And the response body should contain field "output[0].created_by"
    And the response body should contain field "output[0].created_by.full_name"
    And the response body should contain field "output[0].created_by.username"
    And the response body should contain field "output[0].created_by.user_id"
    And the response body should contain field "output[0].request_id"
    And the response body should contain field "output[0].operation_type"
    And the response body should contain field "output[0].total_tasks"
    # And the response body should contain field "output[0].batch_name"
    # And the response body should contain field "output[0].batch_description"
    And the response body should contain field "output[0].task_type"
    And the response body should contain field "output[0].is_export_link"
    And the response body should contain field "message"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"
    
     @negative @auth @creator
  Scenario: API should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid authentication token"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 400
    And the response should match json schema "schemas/invalid_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 400
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" with value "invalid company id"
  @negative1 @creator
  Scenario: API should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 422
    And the response should match json schema "schemas/invalid_schema.json"
     And the response body should contain field "message" with value "one or more companies not found"
  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response should match json schema "schemas/invalid_schema.json"
 And the response body should contain field "message" with value "Invalid company_id"

  
  @positive @smoke @bulk-tasks-listing @creator
  Scenario: Minimal — event_type only returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | event_type | import_operations |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/recovery_bulk_tasks_success_schema.json"
    And the response body should contain field "success"
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @bulk-tasks-listing @creator
  Scenario: Pagination — page and page_size returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | event_type | import_operations |
      | page       |                 2 |
      | page_size  |                25 |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @bulk-tasks-listing @creator
  Scenario Outline: disable_paging "<disable_paging>" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id     | {COMPANY_ID}      |
      | event_type     | import_operations |
      | disable_paging | <disable_paging>  |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"

    Examples:
      | disable_paging |
      | true           |
      | false          |

  @positive @bulk-tasks-listing @creator
  Scenario Outline: sort_by "<sort_by>" with sort_by_type "<sort_by_type>" returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}      |
      | event_type   | import_operations |
      | sort_by      | <sort_by>         |
      | sort_by_type | <sort_by_type>    |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"

    Examples:
      | sort_by     | sort_by_type |
      | created     | desc         |
      | status      | asc          |
      | total_count | desc         |

  @positive @bulk-tasks-listing @creator
  Scenario: operation_type CSV for loan_operations returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id     | {COMPANY_ID}                    |
      | event_type     | loan_operations                 |
      | operation_type | allocate_loans,deallocate_loans |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @bulk-tasks-listing @creator
  Scenario: Search by author returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}      |
      | event_type   | import_operations |
      | search_type  | author            |
      | search_query | Ramesh            |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"

  @positive @bulk-tasks-listing @creator
  Scenario: Search by request_id returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}      |
      | event_type   | import_operations |
      | search_type  | request_id        |
      | search_query | {UUID}            |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"

  @positive @bulk-tasks-listing @creator
  Scenario: Date range (start_date + end_date) returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | event_type | import_operations |
      | start_date | 2026-01-01        |
      | end_date   | 2026-01-31        |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"

  @positive @bulk-tasks-listing @creator
  Scenario: Filter by status and author_id returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}        |
      | event_type | import_operations   |
      | status     | completed           |
      | author_id  | {USER_ID:creator0}  |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"

  @positive @bulk-tasks-listing @creator
  Scenario: Combined real-world filter set returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}      |
      | event_type   | import_operations |
      | status       | completed         |
      | search_type  | author            |
      | search_query | Ramesh            |
      | start_date   | 2026-01-01        |
      | end_date     | 2026-01-31        |
      | page         |                 1 |
      | page_size    |                50 |
      | sort_by      | created           |
      | sort_by_type | desc              |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message" with value "success"

  @positive @bulk-tasks-listing @approver
  Scenario: Listing succeeds for a non-creator role (no permission submodule on this route)
    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | event_type | import_operations |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"

  @positive @boundary @bulk-tasks-listing @creator
  Scenario: Large page_size is accepted (no documented maximum)
    # TODO: verify on staging — doc specifies no max page_size; expecting a tolerant 200.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | event_type | import_operations |
      | page_size  |              1000 |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 200
    And the response body should contain field "output"

  @negative @bulk-tasks-listing @creator
  Scenario Outline: Invalid querystring "<param>=<value>" returns 400
    # quart-schema RequestSchemaValidationError → {"message": "<field>: <msg>", "success": false}.
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | event_type | import_operations |
      | <param>    | <value>           |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 400
    And the response body should contain field "message"

    Examples:
      | param          | value         |
      | page           | 0             |
      | page           | -1            |
      | page_size      | 0             |
      | sort_by        | bogus_sort    |
      | sort_by_type   | upward        |
      | operation_type | not_a_real_op |
      | start_date     | 31-01-2026    |
      | start_date     | 2099-01-01    |
      | end_date       | 2099-01-01    |

  @negative @bulk-tasks-listing @creator
  Scenario: start_date after end_date returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}      |
      | event_type | import_operations |
      | start_date | 2026-02-01        |
      | end_date   | 2026-01-01        |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 400
    And the response body should contain field "message"

  @negative @bulk-tasks-listing @creator
  Scenario: Empty event_type is rejected by the required-field validator
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | event_type |              |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be 400
    And the response body should contain field "message"
