@api @v3-loan-details @recovery
Feature: V3 Loan Details API


  @positive @smoke @creator
  Scenario: GET loan details with minimal required input (loan_id + one attribute selector)

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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}      |
      | attribute_variables | total_loan_amount |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/v3_loan_details_success_schema.json"
    And the v3 loan success envelope should be valid
    And the response body should contain field "data.variable_data"

  @positive @creator @test12345
  Scenario: GET loan details returns variable_data keyed by the requested loan id

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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels | applicant    |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the response body should contain text "{LOAN_ID}"

  @positive @creator
  Scenario: GET loan details with all optional parameters populated
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id           | {COMPANY_ID}                                                      |
      | source               | settlement                                                        |
      | allocation_month     | {ALLOCATION_MONTH_OFFSET:0}                                       |
      | attribute_levels     | applicant,guarantors,document_details,loan_variables,ds_variables |
      | attribute_variables  | loan_amount,applicant_name                                        |
      | audit_info           | true                                                              |
      | nested_audit_info    | true                                                              |
      | id_info              | true                                                              |
      | data_type_conversion | true                                                              |
      | apply_transform      | true                                                              |
      | trigger              | ops_review                                                        |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/v3_loan_details_success_schema.json"
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with all boolean flags false (explicit defaults)
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id           | {COMPANY_ID}      |
      | audit_info           | false             |
      | nested_audit_info    | false             |
      | id_info              | false             |
      | data_type_conversion | false             |
      | apply_transform      | false             |
      | attribute_variables  | total_loan_amount |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with calculation-function level forces data_type_conversion
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                                                |
      | attribute_levels | allocation_variables,allocation_statuses,allocation_details |
      | allocation_month | {ALLOCATION_MONTH_OFFSET:0}                                 |
      | audit_info       | true                                                        |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with nested_audit_info triggers post-processing
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}                     |
      | source              | calling                          |
      | attribute_variables | applicant_name,total_loan_amount |
      | nested_audit_info   | true                             |
      | id_info             | true                             |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with comma-separated attribute_variables
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}                     |
      | attribute_variables | applicant_name,total_loan_amount |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with a free-form trigger label
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}      |
      | trigger             | manual_refresh    |
      | attribute_variables | total_loan_amount |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid


  @positive @boundary @creator
  Scenario Outline: GET loan details accepts boundary-valid allocation_month "<allocation_month>"
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
    And I update JSON field "defaults[0].allocation_month" as "auto" to "<allocation_month>"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}       |
      | allocation_month    | <allocation_month> |
      | attribute_variables | total_loan_amount  |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

    Examples:
      | allocation_month            |
      | 2026-1-01                   |
      | {ALLOCATION_MONTH_OFFSET:2} |
      | 2000-1-01                   |


  @positive @creator
  Scenario Outline: GET loan details accepts source "<source>"
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}      |
      | source              | <source>          |
      | attribute_variables | total_loan_amount |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

    Examples:
      | source        |
      | notice        |
      | workflow      |
      | frontend      |
      | litigation    |
      | communication |
      | calling       |
      | fos           |
      | fos_app       |
      | unknown       |
      | settlement    |
      | scrape        |
      | approval      |

  @positive @creator
  Scenario Outline: GET loan details accepts case-insensitive source "<source>"
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}      |
      | source              | <source>          |
      | attribute_variables | total_loan_amount |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200

    Examples:
      | source     |
      | NOTICE     |
      | Frontend   |
      | SETTLEMENT |


  @positive @creator
  Scenario Outline: GET loan details accepts attribute_levels "<attribute_level>"
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}      |
      | attribute_levels | <attribute_level> |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

    Examples:
      | attribute_level                 |
      | applicant                       |
      | co_applicants                   |
      | references                      |
      | guarantors                      |
      | document_details                |
      | loan_additional_variables       |
      | loan_variables                  |
      | loan_statuses                   |
      | allocation_statuses             |
      | applicant_addresses             |
      | allocation_variables            |
      | allocation_additional_variables |
      | payments                        |
      | tags                            |
      | ds_variables                    |
      | allocation_details              |

  @positive @creator
  Scenario: GET loan details accepts multiple comma-separated attribute_levels
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                          |
      | attribute_levels | applicant,co_applicants,payments,tags |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid


  @positive @creator
  Scenario Outline: GET loan details accepts boolean flag <flag>=<value>
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}      |
      | <flag>              | <value>           |
      | attribute_variables | total_loan_amount |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200

    Examples:
      | flag                 | value |
      | audit_info           | true  |
      | audit_info           | false |
      | nested_audit_info    | true  |
      | nested_audit_info    | false |
      | id_info              | true  |
      | id_info              | false |
      | data_type_conversion | true  |
      | data_type_conversion | false |
      | apply_transform      | true  |
      | apply_transform      | false |


  @positive @edge @creator
  Scenario: GET loan details with empty attribute_levels string coerces to null
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | attribute_levels |              |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400

  @positive @edge @creator
  Scenario: GET loan details with empty attribute_variables string coerces to null
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID} |
      | attribute_variables |              |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400

  @positive @edge @creator
  Scenario: GET loan details with duplicate attribute_levels entries
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                  |
      | attribute_levels | applicant,applicant,applicant |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200


  @negative @auth @creator
  Scenario: GET loan details without authentication token returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept | application/json, text/plain, */* |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "invalid authentication token"

  @negative @auth @creator
  Scenario: GET loan details with an invalid authentication token returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "invalid authentication token"

  @negative @auth @creator
  Scenario: GET loan details with a malformed UUID-style token returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {UUID}                            |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400


  @positive @approver
  Scenario: GET loan details succeeds for a non-creator role (no permission submodule on this route)

    Given I authenticate as "approver" slot 0 and remember as "approver0"
    And scenario loan id is unique
    And I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the request headers:
      | Content-Type        | application/json      |
      | authenticationtoken | {AUTH_TOKEN:creator0} |
    And I set the request body from file "test-data/loan_recovery_request_allocation_flow.json"
    And I update JSON field "loan_id" as "auto" to "{LOAN_ID}"
    And I update JSON field "defaults[0].allocation_month" as "auto" to "{ALLOCATION_MONTH_OFFSET:0}"
    When I send a "POST" request to "/recovery/v1/loan/{loan_id}"
    Then the response status code should be one of "201"
    And I switch active user to "approver0"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}      |
      | attribute_variables | total_loan_amount |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200


  @negative @creator
  Scenario: GET loan details with loan_id "undefined" is rejected by validity check
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | undefined |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" as "auto" with value "Invalid loan id provided"

  @negative @creator
  Scenario: GET loan details with loan_id "null" is rejected by validity check
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | null |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" as "auto" with value "Invalid loan id provided"

  @negative @creator
  Scenario Outline: GET loan details with forbidden character in loan_id "<loan_id>" returns INVALID_IDS
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | <loan_id> |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/v3_loan_details_error_schema.json"
    And the response body should contain field "error.code" as "auto" with value "REC_0007"

    Examples:
      | loan_id  |
      | loan~123 |
      | loan;123 |
      | loan'123 |

  @negative @creator
  Scenario Outline: GET loan details with forbidden character in loan_id "<loan_id>" (encoding-sensitive)

    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | <loan_id> |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_0007"

    Examples:
      | loan_id  |
      | loan%123 |
      | loan}123 |


  @negative @creator
  Scenario: GET loan details with an invalid source value returns validation error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | source     | not_a_real_source |
      | company_id | {COMPANY_ID}      |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/v3_loan_details_error_schema.json"
    And the response body should contain field "error.code" as "auto" with value "REC_0003"

  @negative @creator
  Scenario Outline: GET loan details with invalid attribute_levels "<attribute_levels>" returns validation error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_levels | <attribute_levels> |
      | company_id       | {COMPANY_ID}       |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/v3_loan_details_error_schema.json"
    And the response body should contain field "error.code" as "auto" with value "REC_0003"

    Examples:
      | attribute_levels   |
      | foobar             |
      | applicant,foobar   |
      | APPLICANT_NOT_REAL |

  @negative @creator
  Scenario Outline: GET loan details with badly-formatted allocation_month "<allocation_month>" returns validation error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | allocation_month | <allocation_month> |
      | company_id       | {COMPANY_ID}       |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/v3_loan_details_error_schema.json"
    And the response body should contain field "error.code" as "auto" with value "REC_0003"

    Examples:
      | allocation_month | # reason                          |
      | 01-12-2026       | # DD-MM-YYYY instead of YYYY-M-01 |
      | 2026-12-15       | # day must be 01                  |
      | 2026-13-01       | # month out of range              |
      | 1999-12-01       | # year not 20xx                   |
      | notadate         | # non-date string                 |
      | 2026/12/01       | # wrong separators                |

  @negative @creator
  Scenario Outline: GET loan details with non-boolean flag value <flag>=<value> returns validation error

    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | <flag>     | <value>      |
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "error.code" as "auto" with value "REC_0003"

    Examples:
      | flag                 | value |
      | audit_info           | maybe |
      | data_type_conversion | abcd  |
      | id_info              | 7     |

  @negative @boundary @creator
  Scenario: GET loan details with a very long random loan_id

    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {RANDOM_STRING:200} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400

  @negative @boundary @creator
  Scenario: GET loan details with a single-character loan_id

    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | x |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400

  @negative @creator
  Scenario: GET loan details for a valid-format but non-existent loan id

    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400


  @positive @multistep @creator
  Scenario: GET full attribute set then GET a narrowed variable both succeed
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id       | {COMPANY_ID}                       |
      | attribute_levels | applicant,co_applicants,references |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | attribute_variables | applicant_name |
      | company_id          | {COMPANY_ID}   |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid


  @positive @performance @creator
  Scenario: GET loan details responds within the time threshold
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
    Then the response status code should be one of "201"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {LOAN_ID} |
    And I set the query parameters:
      | company_id          | {COMPANY_ID}   |
      | attribute_variables | applicant_name |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds
