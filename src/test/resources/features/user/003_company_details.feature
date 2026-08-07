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
    And the "company_details" success response should be valid

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
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — multiple keys (CSV) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                   |
      | keys       | company_name,company_email,contact_number,tier |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — tenancy / config fields returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                                       |
      | keys       | tenant_type,parent_company_id,authentication_method,enable_sms_otp |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — address block returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                            |
      | keys       | address_text,address_city,address_state,address_pincode |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid


  @negative @creator
  Scenario: Malformed (non-UUID) company_id returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the "company_details" failure response should be valid

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


  @positive @creator
  Scenario: Projection — config / feature flags returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                                                        |
      | keys       | authentication_method,enable_sms_otp,is_vernac_enabled,enabled_languages,ui_version |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — branding & currency fields returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                                                                            |
      | keys       | company_name,trademark,company_logo,company_email,contact_number,country_isd_code,country_currency_code |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — auth / security configuration returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                                                 |
      | keys       | authentication_method,enable_sms_otp,company_whitelisted_ips,user_activation |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — data-purging / test-company fields returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                                                          |
      | keys       | is_test_company,is_purging_enabled,retention_in_months,is_uat_company |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — webhook fields returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                           |
      | keys       | webhook_details,webhook_payload_config |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — unknown column name is tolerated and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}                       |
      | keys       | company_name,not_a_real_column_xyz |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — empty keys value returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | keys       |              |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @positive @creator
  Scenario: Projection — explicit company_id in keys returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID}            |
      | keys       | company_id,company_name |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid
    And the response body should contain text "company_id"

  @positive @creator
  Scenario: Response envelope exposes data and message fields
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the response body should contain field "data"
    And the response body should contain field "message"

  @positive @creator
  Scenario: Response content type is JSON
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the response content type should be "application/json"

  @positive @creator
  Scenario: Default response always includes company_id
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the response body should contain text "company_id"

  @positive @creator
  Scenario: Unknown extra query parameter is ignored and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id     | {COMPANY_ID} |
      | unexpected_arg | foobar       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 200
    And the "company_details" success response should be valid

  @negative @creator
  Scenario: Empty company_id value is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: company_id with valid characters but wrong length is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | 123e4567-e89b-12d3-a456-4266141740000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the "company_details" failure response should be valid

  @negative @security @creator
  Scenario: SQL injection payload in company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | ' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the "company_details" failure response should be valid

  @negative @security @creator
  Scenario: XSS payload in company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | <xss>alert(1)</xss> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

  @negative @creator
  Scenario: Over-long company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {RANDOM_STRING:200} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the "company_details" failure response should be valid

  @negative @creator
  Scenario: Unicode company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | 123e4567-e89b-12d3-a456-42661417400ñ |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/company/"
    Then the response status code should be 400
    And the "company_details" failure response should be valid

  @negative @creator
  Scenario: Unsupported HTTP method on the company URL is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "DELETE" request to "/user/company/"
    Then the response status code should be one of "404,405"
    And the response body should not be empty
