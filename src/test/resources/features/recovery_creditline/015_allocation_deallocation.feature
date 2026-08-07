@api @creditline @creditline-allocation @recovery
Feature: Credit-line Allocation / Deallocation — POST /recovery/allocation, /recovery/deallocation

  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |


  @negative @creditline
  Scenario: Allocation without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["CUST_{LOAN_ID}"], "user_id": "usr_dummy_id" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Allocation with invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["CUST_{LOAN_ID}"], "user_id": "usr_dummy_id" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Allocation without company_id returns 403
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "loan_ids": ["CUST_{LOAN_ID}"], "user_id": "usr_dummy_id" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 403
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @negative @creditline
  Scenario: Allocation with empty body returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Deallocation without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "loan_ids": ["CUST_{LOAN_ID}"] }
      """
    When I send a "POST" request to "/recovery/deallocation"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @creditline @env-blocked
  Scenario: Allocate a credit-line transaction to a user returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "source" : "api","allocation_algorithm" : "one_to_one", "allocation_type" : "other", "loan_ids": ["CUST_{LOAN_ID}"], "user_id": "usr_dummy_id" }
      """
    When I send a "POST" request to "/recovery/allocation"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creditline @env-blocked
  Scenario: Bulk allocate credit-line transactions returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      { "source" : "api","allocation_algorithm" : "one_to_one","loan_ids": ["CUST_{LOAN_ID}"], "user_id": "usr_dummy_id" }
      """
    When I send a "POST" request to "/recovery/allocation/bulk"
    Then the response status code should be 200
    And the response body should not be empty
