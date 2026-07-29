@api @creditline @creditline-customer-transaction-profile @recovery
Feature: Credit-line Customer Transaction Profile — GET /recovery/customer/transaction/profile/<client_customer_id>/<transaction_id>

  Background: 
    Given scenario loan id is unique
    And I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
      | transaction_id     | TXN_{LOAN_ID}  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
      | transaction_id     | TXN_{LOAN_ID}  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
      | transaction_id     | TXN_{LOAN_ID}  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @positive @smoke @multistep @creditline
  Scenario: Upload a transaction then fetch its customer transaction profile returns 200 success
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I grant the current user all loan permissions
    And I switch active user to "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "transaction_data": [ { "client_customer_id": "CUST_{LOAN_ID}", "transaction_id": "TXN_{LOAN_ID}", "total_loan_amount": 50000, "amount_recovered": 1000 } ] }
      """
    When I send a "POST" request to "/recovery/v1/bulk/transaction-upload"
    Then the response status code should be 202
    And the response body should contain field "data.request_id"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
      | transaction_id     | TXN_{LOAN_ID}  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/customer_transaction_profile_success_schema.json"

  @negative @creditline
  Scenario: Unknown client_customer_id and transaction_id return 400 Invalid transaction id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | CUST_NOPE_{LOAN_ID} |
      | transaction_id     | TXN_NOPE_{LOAN_ID}  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "Invalid transaction id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Valid client_customer_id but unknown transaction_id returns 400 Invalid transaction id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID}     |
      | transaction_id     | TXN_UNKNOWN_{UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "Invalid transaction id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline @boundary
  Scenario: Random UUID ids that do not exist return 400 Invalid transaction id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | {UUID} |
      | transaction_id     | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "Invalid transaction id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Path parameter negatives (undefined / null) ----------
  @negative @creditline
  Scenario: Undefined transaction_id path segment returns 400 Invalid transaction id
    # transaction_id path parameter left as the literal token "undefined".
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
      | transaction_id     | undefined      |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "Invalid transaction id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Null-literal transaction_id path segment returns 400 Invalid transaction id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | CUST_{LOAN_ID} |
      | transaction_id     | null           |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "Invalid transaction id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Undefined client_customer_id path segment returns 400 Invalid transaction id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | undefined     |
      | transaction_id     | TXN_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "Invalid transaction id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Null-literal client_customer_id path segment returns 400 Invalid transaction id
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the path parameters:
      | client_customer_id | null          |
      | transaction_id     | TXN_{LOAN_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/customer/transaction/profile/{client_customer_id}/{transaction_id}"
    Then the response status code should be 400
    And the response message should be "Invalid transaction id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"
