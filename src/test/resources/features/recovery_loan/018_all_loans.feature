@api @all-loans @recovery
Feature: All Loans API

  Background:
    Given scenario company id is from configuration
    And I prepare a request



  @positive @smoke @creator
  Scenario: GET all-loans smoke test returns loan list for configured company_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty
    And the response time should be within configured limit

  @positive @creator
  Scenario: GET all-loans with page_number=1 and page_size=5
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | page_number | 1            |
      | page_size   | 5            |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with page_number=2 and page_size=10
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | page_number | 2            |
      | page_size   | 10           |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=created_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | sort       | created_asc  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=created_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | sort       | created_desc |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=date_of_default_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}         |
      | sort       | date_of_default_asc  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=date_of_default_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}          |
      | sort       | date_of_default_desc  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=total_claim_amount_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}             |
      | sort       | total_claim_amount_asc   |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=total_claim_amount_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}             |
      | sort       | total_claim_amount_desc  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=default_emi_number_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}             |
      | sort       | default_emi_number_asc   |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=default_emi_number_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}             |
      | sort       | default_emi_number_desc  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator @500
  Scenario: GET all-loans with sort=number_of_transactions_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}                  |
      | sort       | number_of_transactions_asc    |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator @500
  Scenario: GET all-loans with sort=number_of_transactions_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}                  |
      | sort       | number_of_transactions_desc   |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator @500
  Scenario: GET all-loans with sort=distance_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | sort       | distance_asc |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator @500
  Scenario: GET all-loans with sort=distance_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}  |
      | sort       | distance_desc |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=principal_outstanding_amount_asc is silently ignored and returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}                          |
      | sort       | principal_outstanding_amount_asc      |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=principal_outstanding_amount_desc is silently ignored and returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}                          |
      | sort       | principal_outstanding_amount_desc     |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=loan_id and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | search_type | loan_id      |
      | query       | LN001        |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=applicant_name and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}   |
      | search_type | applicant_name |
      | query       | test           |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=applicant_email and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}      |
      | search_type | applicant_email   |
      | query       | test@example.com  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=applicant_contact_number and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}               |
      | search_type | applicant_contact_number   |
      | query       | 9876543210                 |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=business_name and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}  |
      | search_type | business_name |
      | query       | ABC           |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=client_customer_id and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}       |
      | search_type | client_customer_id |
      | query       | CID001             |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=group_id and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | search_type | group_id     |
      | query       | GRP001       |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=center_name and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | search_type | center_name  |
      | query       | CENTER01     |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator @500
  Scenario: GET all-loans with search_type=transaction_id and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}   |
      | search_type | transaction_id |
      | query       | TXN001         |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator
  Scenario: GET all-loans with archive=true returns archived loans
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | archive    | true         |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with archive=false returns non-archived loans explicitly
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | archive    | false        |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with allocation_month=overall
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | allocation_month | overall      |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with return_type=dict returns object keyed by loan_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | return_type | dict         |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_dict_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: GET all-loans with select_from=1 and select_to=5 row-range slice
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | select_from | 1            |
      | select_to   | 5            |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with user_hierarchy_join=true
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id          | {COMPANY_ID} |
      | user_hierarchy_join | true         |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with permission_group_id filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}          |
      | permission_group_id | pg-automation-test    |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @performance @creator
  Scenario: GET all-loans response time should be within threshold
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds



  @positive @smoke @creator
  Scenario: POST all-loans smoke test returns loan list for configured company_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"
    And the response time should be within configured limit

  @positive @creator
  Scenario: POST all-loans with page_number=1 and page_size=5
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_number": 1,
        "page_size": 5
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with page_number=2 and page_size=20
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_number": 2,
        "page_size": 20
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with page_size=1 boundary value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_size": 1
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with page_size=100
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_size": 100
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=created_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "created_asc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=created_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "created_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=date_of_default_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "date_of_default_asc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=date_of_default_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "date_of_default_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=total_claim_amount_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "total_claim_amount_asc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=total_claim_amount_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "total_claim_amount_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=default_emi_number_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "default_emi_number_asc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=default_emi_number_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "default_emi_number_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with sort=number_of_transactions_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "number_of_transactions_asc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with sort=number_of_transactions_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "number_of_transactions_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with sort=distance_asc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "distance_asc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with sort=distance_desc
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "distance_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=principal_outstanding_amount_asc is silently ignored and returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "principal_outstanding_amount_asc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sort=principal_outstanding_amount_desc is silently ignored and returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "principal_outstanding_amount_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search_type=loan_id and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "loan_id",
        "query": "LN001"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search_type=applicant_name and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "applicant_name",
        "query": "test"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search_type=applicant_email and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "applicant_email",
        "query": "test@example.com"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search_type=applicant_contact_number and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "applicant_contact_number",
        "query": "9876543210"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search_type=business_name and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "business_name",
        "query": "ABC"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search_type=client_customer_id and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "client_customer_id",
        "query": "CID001"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search_type=group_id and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "group_id",
        "query": "GRP001"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search_type=center_name and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "center_name",
        "query": "CENTER01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with search_type=transaction_id and query
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "transaction_id",
        "query": "TXN001"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with return_type=dict
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "return_type": "dict"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_dict_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with select_from=1 and select_to=10 row-range slice
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "select_from": 1,
        "select_to": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with select_from=1 and select_to=100 larger range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "select_from": 1,
        "select_to": 100
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocation_month=overall
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "overall"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with archive=true returns archived loans
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "archive": true
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with archive=false returns non-archived loans explicitly
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "archive": false
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with user_hierarchy_join=true
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_hierarchy_join": true
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with permission_group_id filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "permission_group_id": "pg-automation-test"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with deselected loan IDs excluded from result
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "deselected": ["LOAN001", "LOAN002"]
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with include_transactions=true
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "include_transactions": true
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"


  @positive @creator
  Scenario: POST all-loans with total_loan_amount_from only
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_from": 50000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with total_loan_amount_to only
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_to": 500000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with total_loan_amount_from and total_loan_amount_to valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_from": 1000,
        "total_loan_amount_to": 1000000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with principal_outstanding_amount_from and to valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_outstanding_amount_from": 5000,
        "principal_outstanding_amount_to": 500000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with total_claim_amount_from and to valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_claim_amount_from": 10000,
        "total_claim_amount_to": 1000000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with utilisation_from and utilisation_to valid range for credit-line loans
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "utilisation_from": 10.0,
        "utilisation_to": 80.0
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_bracket=0_30 single bracket filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_bracket": "0_30"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_bracket=31_60,61_90 multiple comma-separated brackets
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_bracket": "31_60,61_90"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_bracket=90_ open-ended bracket
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_bracket": "90_"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocation_dpd_bracket=0_30,31_60 multiple brackets
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_dpd_bracket": "0_30,31_60"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_from=30 and dpd_to=90 custom range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_from": 30,
        "dpd_to": 90
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_from=0 and dpd_to=30 zero-start custom range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_from": 0,
        "dpd_to": 30
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocation_dpd_value_from=30 and allocation_dpd_value_to=60
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_dpd_value_from": 30,
        "allocation_dpd_value_to": 60
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with default_emi_number=3 single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "default_emi_number": "3"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with default_emi_number=3,6,9 multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "default_emi_number": "3,6,9"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with product_type single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "product_type": "personal_loan"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with product_type multiple values comma-separated
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "product_type": "personal_loan,business_loan"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with center_name single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "center_name": "CENTER01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with center_name multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "center_name": "CENTER01,CENTER02"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_type single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_type": "secured"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with tenure_finished=true
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "tenure_finished": true
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with tenure_finished=false
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "tenure_finished": false
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_nbfc_name single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_nbfc_name": "TestNBFC"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_nbfc_name multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_nbfc_name": "TestNBFC,TestNBFC2"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_regional_manager_name filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_regional_manager_name": "test_manager"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_region single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_region": "west"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_region multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_region": "west,north"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with channel_partner filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "channel_partner": "partner_a"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_branch single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_branch": "mumbai_main"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_branch multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_branch": "mumbai_main,delhi_central"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_zone filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_zone": "zone_a"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with rbi_stage single value NPA
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "rbi_stage": "NPA"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with rbi_stage multiple values NPA,SMA-1,SMA-2
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "rbi_stage": "NPA,SMA-1,SMA-2"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with date_of_default_from only
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "date_of_default_from": "2024-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with date_of_default_to only
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "date_of_default_to": "2026-12-31"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with date_of_default_from and date_of_default_to valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "date_of_default_from": "2024-01-01",
        "date_of_default_to": "2025-12-31"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocated_date_of_default_start and end valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_date_of_default_start": "2024-01-01",
        "allocated_date_of_default_end": "2025-12-31"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with upload_date_from and upload_date_to valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "upload_date_from": "2024-01-01",
        "upload_date_to": "2026-12-31"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with update_date_from and update_date_to valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "update_date_from": "2025-01-01",
        "update_date_to": "2026-12-31"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with applicant_state single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_state": "maharashtra"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_state multiple values comma-separated
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_state": "maharashtra,karnataka"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_city single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_city": "mumbai"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_city multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_city": "mumbai,pune"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_pincode single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_pincode": "400001"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_pincode multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_pincode": "400001,400002"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_language single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_language": "hindi"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_language multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_language": "hindi,marathi"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with co_applicant_present=true without count filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": true
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with co_applicant_present=false
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": false
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with co_applicant_present=true and co_app_from=1 and co_app_upto=3 valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": true,
        "co_app_from": 1,
        "co_app_upto": 3
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with co_applicant_present=true and co_app_from=2 and co_app_upto=2 equal boundary
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": true,
        "co_app_from": 2,
        "co_app_upto": 2
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with allocated_user_profession filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_user_profession": "field_agent"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocated_user_team filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_user_team": "recovery_team_a"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocated_user_location filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_user_location": "mumbai"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator
  Scenario: POST all-loans should fail when allocated_user_name is not a valid NanoID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_user_name": "not-a-valid-nanoid@example.com"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator
  Scenario: POST all-loans should fail when multiple allocated_user_name values are not valid NanoIDs
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_user_name": "invalid1@example.com,invalid2@example.com"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocated_agency single UUID
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_agency": "11111111-1111-1111-1111-111111111111"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocated_agency multiple UUIDs
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_agency": "11111111-1111-1111-1111-111111111111,22222222-2222-2222-2222-222222222222"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with call_attempts_from=1 and call_attempts_to=10
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "call_attempts_from": 1,
        "call_attempts_to": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with call_attempts_from=5 only no upper bound
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "call_attempts_from": 5
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with call_attempts_from=0 treated as null should succeed
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "call_attempts_from": 0
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with ivr_message_heard=true
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "ivr_message_heard": true
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with ivr_message_heard=false
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "ivr_message_heard": false
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with recovery_status single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "promise_to_pay"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with recovery_status multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "promise_to_pay,paid"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with fos_status single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "fos_status": "visited"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with fos_status multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "fos_status": "visited,not_visited"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with telecalling_status single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "telecalling_status": "call_connected"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with telecalling_status multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "telecalling_status": "call_connected,call_not_connected"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with global_status filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status": "active"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with legal_status single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "legal_status": "filed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with legal_status multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "legal_status": "filed,pending"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with settlement_status filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "settlement_status": "offer_accepted"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with repossession_status filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "repossession_status": "repossessed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with proof_of_payment filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "proof_of_payment": "submitted"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with digital_communication_status single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "digital_communication_status": "sent"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with digital_communication_status multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "digital_communication_status": "sent,delivered"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with chatr_status filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "chatr_status": "engaged"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with voicebot_status filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "voicebot_status": "completed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with tags single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "tags": "high_value"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with tags multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "tags": "high_value,priority"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with batch_tag single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "batch_tag": "batch_jan_2025"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with uploaded_by single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "uploaded_by": "uploader@example.com"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with uploaded_by multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "uploaded_by": "uploader@example.com,uploader2@example.com"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with common_legal_process_-_current_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "common_legal_process_-_current_stages": "notice_sent"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with common_legal_process_-_next_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "common_legal_process_-_next_stages": "hearing_scheduled"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with common_legal_process_-_tat_breached filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "common_legal_process_-_tat_breached": "yes"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with criminal_proceedings_-_current_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "criminal_proceedings_-_current_stages": "fir_filed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with criminal_proceedings_-_next_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "criminal_proceedings_-_next_stages": "court_hearing"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with criminal_proceedings_-_tat_breached filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "criminal_proceedings_-_tat_breached": "yes"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with arbitration_-_current_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "arbitration_-_current_stages": "notice_issued"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with arbitration_-_next_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "arbitration_-_next_stages": "award_passed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with arbitration_-_tat_breached filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "arbitration_-_tat_breached": "yes"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sarfaesi_-_current_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sarfaesi_-_current_stages": "demand_notice_issued"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sarfaesi_-_next_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sarfaesi_-_next_stages": "possession_notice"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with sarfaesi_-_tat_breached filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sarfaesi_-_tat_breached": "yes"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with civil_-_current_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "civil_-_current_stages": "suit_filed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with civil_-_next_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "civil_-_next_stages": "decree_execution"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with civil_-_tat_breached filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "civil_-_tat_breached": "yes"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with against_-_current_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "against_-_current_stages": "complaint_filed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with against_-_next_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "against_-_next_stages": "reply_to_be_filed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with against_-_tat_breached filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "against_-_tat_breached": "yes"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with ibc_-_current_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "ibc_-_current_stages": "petition_filed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with ibc_-_next_stages filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "ibc_-_next_stages": "admission_hearing"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with ibc_-_tat_breached filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "ibc_-_tat_breached": "yes"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with ongoing_case_-_types filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "ongoing_case_-_types": "civil"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with case_status filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "case_status": "active"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with apply_litigation_filter_via_table=true and civil current stages
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "apply_litigation_filter_via_table": true,
        "civil_-_current_stages": "suit_filed"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"



  @positive @creator @500
  Scenario: POST all-loans with speedpost_status=delivered
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "speedpost_status": "delivered"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with speedpost_status=undelivered
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "speedpost_status": "undelivered"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with speedpost_status=in-transit
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "speedpost_status": "in-transit"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with speedpost_status=undelivered,in-transit multiple values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "speedpost_status": "undelivered,in-transit"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with last_digital_notice_generated filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "last_digital_notice_generated": "demand_notice"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with last_physical_notice_generated filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "last_physical_notice_generated": "legal_notice"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with digital_notice_clicked=true
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "digital_notice_clicked": true
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with digital_notice_clicked=false
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "digital_notice_clicked": false
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with digital_notice_opened=true
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "digital_notice_opened": true
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans with digital_notice_opened=false
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "digital_notice_opened": false
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans high-value NPA loans combined filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "overall",
        "sort": "total_claim_amount_desc",
        "applicant_state": "maharashtra",
        "dpd_from": 60,
        "dpd_to": 120,
        "rbi_stage": "NPA",
        "total_claim_amount_from": 100000,
        "page_size": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans field agent workload combined filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_user_profession": "field_agent",
        "legal_status": "filed",
        "page_size": 50
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans settlement pipeline combined filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "promise_to_pay",
        "settlement_status": "offer_accepted",
        "sort": "total_claim_amount_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans export all as dict using select range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "select_from": 1,
        "select_to": 1000,
        "return_type": "dict"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_dict_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans notice escalation combined filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "speedpost_status": "undelivered",
        "digital_notice_opened": false,
        "dpd_from": 90
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"

  @positive @creator @500
  Scenario: POST all-loans SARFAESI TAT breached board report combined filter
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "overall",
        "sarfaesi_-_tat_breached": "yes",
        "apply_litigation_filter_via_table": true,
        "sort": "total_claim_amount_desc"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should contain field "message"



  @positive @performance @creator
  Scenario: POST all-loans response time should be within threshold
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds



  @negative @auth @creator
  Scenario: GET all-loans should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @auth @creator
  Scenario: GET all-loans should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @auth @creator
  Scenario: POST all-loans should fail when authentication token is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @auth @creator
  Scenario: POST all-loans should fail with invalid authentication token
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | invalid_token_12345               |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"



  @negative @creator
  Scenario: GET all-loans should fail when company_id query parameter is missing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: GET all-loans should fail when company_id is invalid UUID format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | invalid-company-id |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: GET all-loans should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: POST all-loans should fail when company_id is missing from body
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "page_number": 1,
        "page_size": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: POST all-loans should fail when company_id does not exist
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "00000000-0000-0000-0000-000000000000"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 422
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"



  @negative @creator
  Scenario: POST all-loans should fail when search_type value is invalid
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "invalid_type",
        "query": "test"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: POST all-loans should fail when sort value is invalid
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "invalid_sort_value"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: POST all-loans should fail when allocation_month format is invalid not-a-date
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "not-a-date"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: POST all-loans should fail when allocation_month format has invalid month 99-2099
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "99-2099"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: POST all-loans with empty query and valid search_type should succeed as edge case
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "loan_id",
        "query": ""
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator
  Scenario: POST all-loans with very large page_size=10000 should be handled by API
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_size": 10000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator
  Scenario: POST all-loans with page_number=0 edge case returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_number": 0,
        "page_size": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @negative @creator @500
  Scenario: POST all-loans should fail when co_app_from is greater than co_app_upto
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": true,
        "co_app_from": 5,
        "co_app_upto": 2
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @positive @creator
  Scenario: POST all-loans co_app_from=0 and co_app_upto=0 are treated as null and succeed
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": true,
        "co_app_from": 0,
        "co_app_upto": 0
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator @500
  Scenario: POST all-loans should fail when call_attempts_from is greater than call_attempts_to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "call_attempts_from": 10,
        "call_attempts_to": 3
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator @500
  Scenario: POST all-loans should fail when total_loan_amount_from is greater than total_loan_amount_to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_from": 500000,
        "total_loan_amount_to": 1000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator @500
  Scenario: POST all-loans should fail when principal_outstanding_amount_from is greater than to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_outstanding_amount_from": 200000,
        "principal_outstanding_amount_to": 1000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator @500
  Scenario: POST all-loans should fail when total_claim_amount_from is greater than total_claim_amount_to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_claim_amount_from": 100000,
        "total_claim_amount_to": 500
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator @500
  Scenario: POST all-loans should fail when date_of_default_from is after date_of_default_to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "date_of_default_from": "2025-12-31",
        "date_of_default_to": "2024-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator @500
  Scenario: POST all-loans should fail when upload_date_from is after upload_date_to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "upload_date_from": "2026-12-31",
        "upload_date_to": "2024-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @positive @creator
  Scenario: POST all-loans with inverted utilisation range succeeds on non-credit-line company
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "utilisation_from": 90.0,
        "utilisation_to": 10.0
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: GET all-loans with allocation_month in MM-YYYY format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | allocation_month  | 05-2026      |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with allocation_month as first day of month YYYY-MM-DD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | allocation_month  | 2026-05-01   |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with page_size=1 boundary value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | page_size   | 1            |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with page_size=100 large value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | page_size   | 100          |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with page_number=5 higher page
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | page_number | 5            |
      | page_size   | 10           |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with dpd_bracket=31_60 different bracket value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | dpd_bracket | 31_60        |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with dpd_bracket=61_90,90_ multiple including open-ended
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | dpd_bracket | 61_90,90_    |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with select_from=11 and select_to=20 second window
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | {COMPANY_ID} |
      | select_from  | 11           |
      | select_to    | 20           |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with applicant_state query param single value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | applicant_state  | delhi        |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with recovery_status query param
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}    |
      | recovery_status  | promise_to_pay  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with sort=created_asc and page_size=5 combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | sort        | created_asc  |
      | page_size   | 5            |
      | page_number | 1            |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with product_type query param
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id   | {COMPANY_ID}  |
      | product_type | personal_loan |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @positive @creator
  Scenario: GET all-loans with search_type=group_id and empty query returns all
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID} |
      | search_type | group_id     |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response body should not be empty

  @negative @creator
  Scenario: GET all-loans should fail when allocation_month is random text
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id        | {COMPANY_ID} |
      | allocation_month  | not-a-date   |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: GET all-loans should fail when sort value is invalid
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID}  |
      | sort       | invalid_sort  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: GET all-loans should fail when search_type is invalid
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id  | {COMPANY_ID}  |
      | search_type | invalid_type  |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"



  @positive @creator
  Scenario: POST all-loans with allocation_month in MM-YYYY format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "05-2026"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocation_month as YYYY-MM-DD full date
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-05-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator
  Scenario: POST all-loans should fail when allocation_month is 99-2099 invalid month
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "99-2099"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: POST all-loans should fail when allocation_month is YYYY-MM wrong format
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_month": "2026-13"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"



  @positive @creator
  Scenario: POST all-loans with page_number=1 and page_size=1 minimum page
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_number": 1,
        "page_size": 1
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with page_number=100 high page returns empty list
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_number": 100,
        "page_size": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with page_size=50 mid-range value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_size": 50
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with select_from=1 and select_to=1 single row
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "select_from": 1,
        "select_to": 1
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with select_from=51 and select_to=100 third window
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "select_from": 51,
        "select_to": 100
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with select_from and select_to combined with return_type=dict
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "select_from": 1,
        "select_to": 20,
        "return_type": "dict"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_dict_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with dpd_bracket=31_60 single bracket
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_bracket": "31_60"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_bracket=61_90 single bucket
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_bracket": "61_90"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_bracket=90_ open-ended bucket
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_bracket": "90_"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_bracket all standard buckets
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_bracket": "0_30,31_60,61_90,90_"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_from=0 and dpd_to=30 zero-start custom range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_from": 0,
        "dpd_to": 30
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_from=90 and dpd_to=180 large DPD range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_from": 90,
        "dpd_to": 180
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with dpd_from=dpd_to equal boundary values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_from": 60,
        "dpd_to": 60
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with default_emi_number=1 first EMI default
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "default_emi_number": "1"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with allocation_dpd_bracket=61_90,90_ multiple allocation brackets
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocation_dpd_bracket": "61_90,90_"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with total_loan_amount_from only lower bound
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_from": 100000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with total_loan_amount_to only upper bound
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_to": 500000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with total_loan_amount_from=total_loan_amount_to equal boundary
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_from": 100000,
        "total_loan_amount_to": 100000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with principal_outstanding_amount_from only
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_outstanding_amount_from": 50000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with total_claim_amount_to only upper bound
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_claim_amount_to": 1000000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator @500
  Scenario: POST all-loans should fail when principal_outstanding_amount_from greater than to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "principal_outstanding_amount_from": 500000,
        "principal_outstanding_amount_to": 1000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator @500
  Scenario: POST all-loans should fail when total_claim_amount_from greater than to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_claim_amount_from": 200000,
        "total_claim_amount_to": 5000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"



  @positive @creator
  Scenario: POST all-loans with date_of_default_from only lower bound
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "date_of_default_from": "2025-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with date_of_default_to only upper bound
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "date_of_default_to": "2026-12-31"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with date_of_default_from=date_of_default_to same date boundary
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "date_of_default_from": "2025-06-01",
        "date_of_default_to": "2025-06-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with upload_date_from only
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "upload_date_from": "2025-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with update_date_to only upper bound
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "update_date_to": "2026-12-31"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator @500
  Scenario: POST all-loans should fail when allocated_date_of_default_start greater than end
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "allocated_date_of_default_start": "2025-12-31",
        "allocated_date_of_default_end": "2025-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator @500
  Scenario: POST all-loans should fail when update_date_from greater than update_date_to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "update_date_from": "2026-12-31",
        "update_date_to": "2025-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"



  @positive @creator
  Scenario: POST all-loans with applicant_state=UP uppercased value lowercased internally
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_state": "UP"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_state three states comma-separated
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_state": "maharashtra,delhi,karnataka"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with applicant_pincode multiple pincodes
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_pincode": "110001,400001,560001"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with co_applicant_present=true and co_app_from=1 co_app_upto=1 equal range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": true,
        "co_app_from": 1,
        "co_app_upto": 1
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with co_applicant_present=true and co_app_from=1 co_app_upto=5 valid range
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": true,
        "co_app_from": 1,
        "co_app_upto": 5
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with co_applicant_present=false explicitly no co-applicant
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": false
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @negative @creator @500
  Scenario: POST all-loans should fail when co_app_from equals co_app_upto=0 zero boundary
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "co_applicant_present": true,
        "co_app_from": 5,
        "co_app_upto": 0
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"



  @positive @creator
  Scenario: POST all-loans with call_attempts_from=1 and call_attempts_to=1 single attempt
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "call_attempts_from": 1,
        "call_attempts_to": 1
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with call_attempts_to=20 only upper bound
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "call_attempts_to": 20
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with call_attempts_from=0 treated as null per spec
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "call_attempts_from": 0,
        "call_attempts_to": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with recovery_status=not_contacted
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "not_contacted"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with recovery_status=partial_payment
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "partial_payment"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with recovery_status=dispute
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "dispute"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with three recovery_status values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "promise_to_pay,partial_payment,dispute"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with rbi_stage=SMA-0
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "rbi_stage": "SMA-0"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with rbi_stage=SMA-1,SMA-2,NPA three stages
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "rbi_stage": "SMA-1,SMA-2,NPA"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with tenure_finished=false loans still running
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "tenure_finished": false
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan_region multiple regions
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "loan_region": "North,South,East"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with product_type three values
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "product_type": "personal_loan,home_loan,auto_loan"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with deselected as list with one item
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "deselected": ["LOAN001"]
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with deselected as list with multiple items
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "deselected": ["LOAN001", "LOAN002", "LOAN003", "LOAN004", "LOAN005"]
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with empty deselected list
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "deselected": []
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @positive @creator
  Scenario: POST all-loans with dpd_bracket and applicant_state combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_bracket": "0_30,31_60",
        "applicant_state": "maharashtra,delhi"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with loan amount and date of default combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_from": 50000,
        "total_loan_amount_to": 1000000,
        "date_of_default_from": "2024-01-01",
        "date_of_default_to": "2026-12-31"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with recovery_status and dpd_from dpd_to combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "promise_to_pay,partial_payment",
        "dpd_from": 30,
        "dpd_to": 90
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with product_type and rbi_stage and applicant_state combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "product_type": "personal_loan",
        "rbi_stage": "NPA",
        "applicant_state": "maharashtra"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans sort by claim amount desc with page_number=2
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "sort": "total_claim_amount_desc",
        "page_number": 2,
        "page_size": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with tags multiple and upload_date_from combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "tags": "high_value,priority",
        "upload_date_from": "2025-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans archive=true with allocation_month=overall combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "archive": true,
        "allocation_month": "overall"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with search across applicant_email and applicant_state
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "search_type": "applicant_email",
        "query": "test",
        "applicant_state": "maharashtra"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with legal_status and settlement_status combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "legal_status": "filed,notice_sent",
        "settlement_status": "offer_accepted"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"

  @positive @creator
  Scenario: POST all-loans with multiple status filters combined
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "recovery_status": "promise_to_pay",
        "fos_status": "visited",
        "global_status": "active"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"
    And the response body should contain field "message"



  @negative @creator
  Scenario: POST all-loans with empty JSON body missing company_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @positive @creator
  Scenario: POST all-loans with page_size=0 is accepted by API using default value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_size": 0
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"

  @positive @creator
  Scenario: POST all-loans with page_number=0 is accepted by API using default value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_number": 0
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"

  @positive @creator
  Scenario: POST all-loans with page_number=-1 negative is accepted by API using default value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "page_number": -1
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"

  @positive @creator
  Scenario: POST all-loans with select_from greater than select_to is accepted by API
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "select_from": 50,
        "select_to": 10
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"

  @positive @creator
  Scenario: POST all-loans with negative dpd_from is accepted by API
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "dpd_from": -10,
        "dpd_to": 30
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"

  @positive @creator
  Scenario: POST all-loans with negative total_loan_amount_from is accepted by API
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "total_loan_amount_from": -1000,
        "total_loan_amount_to": 500000
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/all_loans_list_success_schema.json"
    And the response body should contain field "output"

  @negative @creator @shouldfail
  Scenario: POST all-loans should fail when applicant_pincode contains negative value
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "applicant_pincode": "-110001"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator
  Scenario: POST all-loans should fail when company_id is not a valid UUID
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "invalid-company"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

  @negative @creator @500
  Scenario: POST all-loans should fail when upload_date_from greater than upload_date_to
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept               | application/json, text/plain, */* |
      | authenticationtoken  | {AUTH_TOKEN}                      |
      | Content-Type         | application/json                  |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "upload_date_from": "2026-12-31",
        "upload_date_to": "2025-01-01"
      }
      """
    When I send a "POST" request to "/recovery/all-loans"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/all_loans_error_schema.json"

