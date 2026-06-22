@api @user @company-details
Feature: Company Details — GET /user/company/



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal — full default company detail set returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/company_details_success_schema.json"
    And the company details success response should be valid

  @positive @creator
  Scenario: Projection — single key returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | keys       | company_name |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the company details success response should be valid

  @positive @creator
  Scenario: Projection — multiple keys (CSV) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                       |
      | keys       | company_name,company_email,contact_number,tier     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the company details success response should be valid

  @positive @creator
  Scenario: Projection — tenancy / config fields returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                                          |
      | keys       | tenant_type,parent_company_id,authentication_method,enable_sms_otp     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the company details success response should be valid

  @positive @creator
  Scenario: Projection — address block returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                              |
      | keys       | address_text,address_city,address_state,address_pincode   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the company details success response should be valid


  @negative @creator
  Scenario: Malformed (non-UUID) company_id returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the company details failure response should be valid

  @negative @creator
  Scenario: Unknown (random UUID) company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the response body should not be empty


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the response body should not be empty
