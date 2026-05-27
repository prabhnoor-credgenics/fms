Feature: Bulk tasks API

  @chief-admin
  Scenario: Verify get bulk tasks API request
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
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | x-company-id | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be one of "401"
    And the response body should contain field "message" with value "Session expired, please login again"

  @negative @auth @creator
  Scenario: API should fail with invalid authentication token
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
      | x-company-id        | {COMPANY_ID}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be one of "401,403"
    And the response should match json schema "schemas/invalid_schema.json"

  @negative @creator
  Scenario: API should fail when company_id query parameter is missing
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                      |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be one of "400,401,403,422"
    And the response should match json schema "schemas/invalid_schema.json"
    And the response body should contain field "message" with value "invalid company id"
  @negative @creator
  Scenario: API should fail when company_id does not exist
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | x-company-id        | 00000000-0000-0000-0000-000000000000 |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/bulk/tasks"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/invalid_schema.json"
     And the response body should contain field "message" with value "forbidden: invalid company id"
  @negative @creator
  Scenario: API should fail when company_id is invalid UUID format
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | invalid-company-id                |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be one of "400,401,403,404,422"
    And the response should match json schema "schemas/invalid_schema.json"
 And the response body should contain field "message" with value "Session expired, please login again"
