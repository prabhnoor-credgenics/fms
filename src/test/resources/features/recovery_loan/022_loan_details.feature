@api @loan-details @recovery
Feature: Loan Details (Metadata) API

  @positive @update @creator
  Scenario: PATCH updates an applicant attribute
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I grant the current user all loan permissions
    And scenario loan id is unique
    # --- upload a fresh loan first, then the scenario validates the response below ---
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
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body:
      """
      {
        "source": "platform",
        "applicant_attributes": {
          "applicant_name": "Automation Test"
        },
          "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb"
      }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/loan_details_patch_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @update @creator
  Scenario: PATCH should fail when payload contains HTML tags
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the request body:
      """
      {
        "source": "platform",
        "applicant_attributes": {
          "applicant_email": [{ "value": "<script>alert(1)</script>" }]
        },
          "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb"
      }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid data provided"

  @negative @update @creator
  Scenario: PATCH should fail when no recognized section is provided
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the request body:
      """
      {
        "source": "platform",
            "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb"
      }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 403
    And the response body should contain field "message"


  @negative @update @creator
  Scenario: PATCH should fail for an invalid loan id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */*    |
      | authenticationtoken | {AUTH_TOKEN}                         |
      | Content-Type        | application/json                     |
    And I set the path parameters:
      | loan_id | undefined |
    And I set the request body:
      """
      {
        "source": "platform",
        "applicant_attributes": {
          "applicant_email": [{ "value": "automation@example.com" }]
        },
         "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb"
      }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be one of "400"
    And the response body should contain field "message"

  @negative @auth @update @creator @bug
  Scenario: PATCH should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept       | application/json, text/plain, */*    |
      | Content-Type | application/json                     |
    And I set the path parameters:
      | loan_id |Loan047122 |
    And I set the request body:
      """
      {
        "source": "platform",
        "applicant_attributes": {
          "applicant_email": [{ "value": "automation@example.com" }]
        },
        "company_id": "3e561a13-3be3-4672-85b0-e1c49a35d8fb"
      }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be one of "400,403"
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
