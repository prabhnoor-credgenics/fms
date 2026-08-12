@api @creditline @creditline-v3-customers @recovery
Feature: Credit-line v3 Customers — GET /recovery/v3/customers/<customer_id>[/transactions/<transaction_id>]


  Background:
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |


  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id       | {COMPANY_ID}       |
      | attribute_levels | customer_variables |
    And I set the path parameters:
      | customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id       | {COMPANY_ID}       |
      | attribute_levels | customer_variables |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    And I set the path parameters:
      | customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | attribute_levels | customer_variables |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @smoke @creditline @multistep
  Scenario: Upload a transaction then fetch customer details returns 200 success
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "client_customer_id" as "auto" to "CUST_{LOAN_ID}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}       |
      | attribute_levels | customer_variables |
    And I set the path parameters:
      | customer_id | CUST_{LOAN_ID} |
    And I wait for 5 seconds
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 200
    And the response message should be "Successfully fetched customer details"
    And the response body should contain field "success"
    And the response body should contain field "data"
    And the response should match json schema "schemas/creditline/success/v3_customers_success_schema.json"

  @positive @creditline @multistep @500
  Scenario: Fetch customer details with attribute_variables selector returns 200 success
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "client_customer_id" as "auto" to "CUST_{LOAN_ID}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}                |
      | attribute_variables | customer_total_claim_amount |
    And I set the path parameters:
      | customer_id | CUST_{LOAN_ID} |
    And I wait for 5 seconds
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 200
    And the response message should be "Successfully fetched customer details"
    And the response should match json schema "schemas/creditline/success/v3_customers_success_schema.json"


  @positive @creditline @multistep
  Scenario: Upload a transaction then fetch the transaction sub-path returns 200 success
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id            | {COMPANY_ID} |
      | replace_previous_data | false        |
      | replace_given_data    | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request body from file "test-data/creditline/creditline_loan_recovery_request.json"
    And I update JSON field "client_customer_id" as "auto" to "CUST_{LOAN_ID}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be 201
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}          |
      | attribute_levels | transaction_variables |
    And I set the path parameters:
      | customer_id    | CUST_{LOAN_ID} |
      | transaction_id | {LOAN_ID}      |
    And I wait for 5 seconds
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}/transactions/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "Successfully fetched customer details"
    And the response should match json schema "schemas/creditline/success/v3_customers_success_schema.json"


  @negative @creditline
  Scenario: Unknown customer_id returns 400 REC_0007 INVALID_IDS
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}       |
      | attribute_levels | customer_variables |
    And I set the path parameters:
      | customer_id | NOPE_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response body should contain text "REC_0007"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Unknown transaction_id on the sub-path returns 400 REC_0007 INVALID_IDS
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}          |
      | attribute_levels | transaction_variables |
    And I set the path parameters:
      | customer_id    | NOPE_{LOAN_ID} |
      | transaction_id | NOTX_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}/transactions/{transaction_id}"
    Then the response status code should be 400
    And the response body should contain text "REC_0007"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @negative @creditline
  Scenario: Invalid attribute_levels value returns 400 REC_0003
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}           |
      | attribute_levels | not_a_valid_attr_level |
    And I set the path parameters:
      | customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response body should contain text "REC_0003"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario Outline: attribute_levels accepts each valid CreditLineAttributeLevels value (no REC_0003)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}      |
      | attribute_levels | <attribute_level> |
    And I set the path parameters:
      | customer_id | NOPE_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response body should not contain text "REC_0003"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

    Examples:
      | attribute_level       |
      | applicant             |
      | customer_variables    |
      | transaction_variables |
      | payments              |
      | tags                  |


  @negative @creditline
  Scenario: Neither attribute_levels nor attribute_variables returns 400 REC_0002
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | customer_id | NOPE_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response body should contain text "REC_0002"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"


  @positive @creditline
  Scenario Outline: source query param accepts each valid enum value (unknown id -> 400 REC_0007, source not rejected)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}       |
      | attribute_levels | customer_variables |
      | source           | <source>           |
    And I set the path parameters:
      | customer_id | NOPE_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response body should contain text "REC_0007"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

    Examples:
      | source        |
      | unknown       |
      | notice        |
      | workflow      |
      | frontend      |
      | litigation    |
      | communication |
      | calling       |
      | settlement    |


  @positive @creditline
  Scenario: Valid allocation_month format is accepted (unknown id -> 400 REC_0007)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}       |
      | attribute_levels | customer_variables |
      | allocation_month | 2026-7-01          |
    And I set the path parameters:
      | customer_id | NOPE_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response body should contain text "REC_0007"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline @boundary
  Scenario: Malformed allocation_month returns 400 validation error
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}       |
      | attribute_levels | customer_variables |
      | allocation_month | 2026-07-15         |
    And I set the path parameters:
      | customer_id | CUST_{LOAN_ID} |
    When I send a "GET" request to "/recovery/v3/customers/{customer_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"
