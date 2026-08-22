@api @recovery @select-loan @portfolio
Feature: Select Loan - Bulk Router API for Portfolio Tags

  @TC093 @positive @P0
  Scenario: TC093 - Upload fresh loan and apply tag to it via bulk router
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    # Step 1: Upload a fresh loan
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    # Step 2: Apply tag to the uploaded loan via bulk router
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
      | x-company-id        | {COMPANY_ID}     |
      | x-allow             | false            |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected": ["{LOAN_ID}"],
        "deselected": [],
        "module": "tags",
        "payload": {
          "tag_name": ["automation_tag"],
          "allocation_month": "{ALLOCATION_MONTH}",
          "loan_ids": ["{LOAN_ID}"]
        },
        "loan_key": "loan_id",
        "allocation_month": "{ALLOCATION_MONTH}",
        "linked": false,
        "module_method": "POST",
        "selection_payload": {
          "company_id": "{COMPANY_ID}",
          "query": "",
          "sort": null,
          "search_type": "loan_id",
          "allocation_month": "{ALLOCATION_MONTH}"
        }
      }
      """
    When I send a "POST" request to "/bulk/router"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/bulk_router_success_schema.json"
    And the response body should contain field "success" as "boolean" with value "true"
    And the response body should contain field "message" as "string" with value "success"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"
    And the response body should contain field "message_placeholder.total_count" as "integer" with value "1"
    And the response body should contain field "message_placeholder.request_type" as "string" with value "upload"

  @TC094 @positive @P0
  Scenario: TC094 - Upload fresh loan, apply tag, then remove tag via bulk router
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    # Step 1: Upload a fresh loan
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    # Step 2: Apply tag to the uploaded loan
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
      | x-company-id        | {COMPANY_ID}     |
      | x-allow             | false            |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected": ["{LOAN_ID}"],
        "deselected": [],
        "module": "tags",
        "payload": {
          "tag_name": ["remove_test_tag"],
          "allocation_month": "{ALLOCATION_MONTH}",
          "loan_ids": ["{LOAN_ID}"]
        },
        "loan_key": "loan_id",
        "allocation_month": "{ALLOCATION_MONTH}",
        "linked": false,
        "module_method": "POST",
        "selection_payload": {
          "company_id": "{COMPANY_ID}",
          "query": "",
          "sort": null,
          "search_type": "loan_id",
          "allocation_month": "{ALLOCATION_MONTH}"
        }
      }
      """
    When I send a "POST" request to "/bulk/router"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/bulk_router_success_schema.json"
    And the response body should contain field "success" as "boolean" with value "true"
    And the response body should contain field "message" as "string" with value "success"
    # Step 3: Remove tag from the loan
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
      | x-company-id        | {COMPANY_ID}     |
      | x-allow             | false            |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected": ["{LOAN_ID}"],
        "deselected": [],
        "module": "tags",
        "payload": {
          "tag_name": ["remove_test_tag"],
          "allocation_month": "{ALLOCATION_MONTH}",
          "loan_ids": ["{LOAN_ID}"]
        },
        "loan_key": "loan_id",
        "allocation_month": "{ALLOCATION_MONTH}",
        "linked": false,
        "module_method": "DELETE",
        "selection_payload": {
          "company_id": "{COMPANY_ID}",
          "query": "",
          "sort": null,
          "search_type": "loan_id",
          "allocation_month": "{ALLOCATION_MONTH}"
        }
      }
      """
    When I send a "POST" request to "/bulk/router"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/bulk_router_success_schema.json"
    And the response body should contain field "success" as "boolean" with value "true"
    And the response body should contain field "message" as "string" with value "success"
    And the response body should contain field "output"
    And the response body should contain field "message_placeholder.request_type" as "string" with value "removal"

  @TC099 @positive @P0
  Scenario: TC099 - Upload fresh loan and archive it via bulk router
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    # Step 1: Upload a fresh loan
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    # Step 2: Archive the loan via bulk router
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
      | x-company-id        | {COMPANY_ID}     |
      | x-allow             | false            |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected": ["{LOAN_ID}"],
        "deselected": [],
        "module": "archive",
        "payload": {
          "category": "loan",
          "operation_type": "archive",
          "data": ["{LOAN_ID}"],
          "allocation_month": "{ALLOCATION_MONTH}",
          "execution_mode": "queue",
          "source": "platform"
        },
        "loan_key": "data",
        "allocation_month": "{ALLOCATION_MONTH}",
        "linked": false,
        "module_method": "POST",
        "selection_payload": {
          "company_id": "{COMPANY_ID}",
          "query": "",
          "sort": null,
          "search_type": "loan_id",
          "allocation_month": "{ALLOCATION_MONTH}"
        }
      }
      """
    When I send a "POST" request to "/bulk/router"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/bulk_router_success_schema.json"
    And the response body should contain field "success" as "boolean" with value "true"
    And the response body should contain field "message" as "string" with value "success"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"

  @TC099_unarchive @positive @P0
  Scenario: TC099_unarchive - Upload fresh loan, archive it, then unarchive via bulk router
    Given scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    # Step 1: Upload a fresh loan
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/loan_recovery_request.json"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    # Step 2: Archive the loan
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
      | x-company-id        | {COMPANY_ID}     |
      | x-allow             | false            |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected": ["{LOAN_ID}"],
        "deselected": [],
        "module": "archive",
        "payload": {
          "category": "loan",
          "operation_type": "archive",
          "data": ["{LOAN_ID}"],
          "allocation_month": "{ALLOCATION_MONTH}",
          "execution_mode": "queue",
          "source": "platform"
        },
        "loan_key": "data",
        "allocation_month": "{ALLOCATION_MONTH}",
        "linked": false,
        "module_method": "POST",
        "selection_payload": {
          "company_id": "{COMPANY_ID}",
          "query": "",
          "sort": null,
          "search_type": "loan_id",
          "allocation_month": "{ALLOCATION_MONTH}"
        }
      }
      """
    When I send a "POST" request to "/bulk/router"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/bulk_router_success_schema.json"
    And the response body should contain field "success" as "boolean" with value "true"
    And the response body should contain field "message" as "string" with value "success"
    # Step 3: Unarchive the loan
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
      | Content-Type        | application/json |
      | x-company-id        | {COMPANY_ID}     |
      | x-allow             | false            |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "selected": ["{LOAN_ID}"],
        "deselected": [],
        "module": "archive",
        "payload": {
          "category": "loan",
          "operation_type": "unarchive",
          "data": ["{LOAN_ID}"],
          "allocation_month": "{ALLOCATION_MONTH}",
          "execution_mode": "queue",
          "source": "platform"
        },
        "loan_key": "data",
        "allocation_month": "{ALLOCATION_MONTH}",
        "linked": false,
        "module_method": "POST",
        "selection_payload": {
          "company_id": "{COMPANY_ID}",
          "query": "",
          "sort": null,
          "search_type": "loan_id",
          "allocation_month": "{ALLOCATION_MONTH}"
        }
      }
      """
    When I send a "POST" request to "/bulk/router"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/bulk_router_success_schema.json"
    And the response body should contain field "success" as "boolean" with value "true"
    And the response body should contain field "message" as "string" with value "success"
    And the response body should contain field "output"
    And the response body should contain field "message_template"
    And the response body should contain field "message_placeholder"
