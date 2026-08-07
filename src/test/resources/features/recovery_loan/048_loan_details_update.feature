@api @loan-details-update @recovery
Feature: Loan Details Update — PATCH /recovery/loan-details/<loan_id>


  Background:
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
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201


  @positive @smoke @creator
  Scenario: Update an applicant scalar attribute with source=platform returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_language": "hindi" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/loan_details_patch_success_schema.json"
    And the "loan_details_update" success response should be valid

  @positive @creator
  Scenario: Use v2=true instead of source=platform returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "v2": true, "applicant_attributes": { "applicant_monthly_income": 45000 } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid

  @positive @creator
  Scenario: Update applicant contact numbers (list) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_contact_number": [ { "phone_number": "9876543210", "contact_type": "primary", "is_valid": true, "is_active": true } ] } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid

  @positive @creator
  Scenario: Update applicant emails (list) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_email": [ { "email": "ramesh@example.com", "contact_type": "primary", "is_valid": true, "is_active": true } ] } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid

  @negative @creator
  Scenario: Applicant address replace path errors on staging (500)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "replace_existing_data": true, "applicant_attributes": { "applicant_address": [ { "address_line": "12 MG Road", "city": "Pune", "state": "maharashtra", "pincode": "411001" } ] } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 500
    And the response body should not be empty

  @positive @creator
  Scenario: replace_existing_data=false (merge) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "replace_existing_data": false, "applicant_attributes": { "applicant_contact_number": [ { "phone_number": "9123456780", "contact_type": "alternate" } ] } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid

  @positive @creator
  Scenario: Update co_applicant_attributes returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "co_applicant_attributes": [ { "co_applicant_name": "Sita Kumar", "co_applicant_contact_number": [ { "phone_number": "9988776655", "contact_type": "primary" } ] } ] }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid

  @positive @creator
  Scenario: Update applicant_references returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_references": [ { "reference_name": "Mahesh", "reference_contact_number": [ { "phone_number": "9090909090", "contact_type": "primary" } ] } ] }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid

  @positive @creator
  Scenario: Update loan_guarantor_attributes returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "loan_guarantor_attributes": [ { "guarantor_name": "Suresh", "guarantor_contact_number": [ { "phone_number": "9111122223", "contact_type": "primary" } ] } ] }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid

  @positive @creator @500
  Scenario: Combined — applicant scalar + contact + email returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "replace_existing_data": true, "applicant_attributes": { "applicant_language": "hindi", "applicant_monthly_income": 50000, "applicant_contact_number": [ { "phone_number": "9876543210", "contact_type": "primary" } ], "applicant_email": [ { "email": "ramesh@example.com", "contact_type": "primary" } ] } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid

  @positive @creator
  Scenario: Legacy path — non-platform source without v2 returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "fos_app", "applicant_attributes": { "applicant_language": "marathi" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: Update applicant attribute is accepted (200)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_language": "hindi" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 200
    And the "loan_details_update" success response should be valid


  @negative @creator
  Scenario: Body containing an HTML tag is rejected (400)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_name": "<b>x</b>" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 400
    And the "loan_details_update" failure response should be valid

  @negative @creator
  Scenario: Non-admin with no borrower section is forbidden (403)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform" }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: Empty borrower section returns 400 (nothing to update)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": {} }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 400
    And the "loan_details_update" failure response should be valid

  @negative @creator
  Scenario: Non-existent loan id returns 400 (Invalid loan id)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | NONEXISTENT-LOAN-9999 |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_language": "hindi" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 400
    And the "loan_details_update" failure response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_language": "hindi" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_language": "hindi" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id (org context unresolved) is rejected
    Given I prepare a request
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_language": "hindi" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected at org resolution
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "source": "platform", "applicant_attributes": { "applicant_language": "hindi" } }
      """
    When I send a "PATCH" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: DELETE on the loan-details endpoint is not allowed (405)
    Given I prepare a request
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "DELETE" request to "/recovery/loan-details/{loan_id}"
    Then the response status code should be 405
