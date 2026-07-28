@api @creditline @creditline-fetch-customers @recovery
Feature: Credit-line Fetch Customers — GET /recovery/fetch/customers
  # Credit-line product (company_type == "credit line"). Flat-envelope read endpoint
  # (auth login + org check, no loan permission required). Returns the list of
  # client_customer_id strings matching the filters.
  #   query (all optional): start_time / end_time (epoch seconds),
  #     status (only "open" is honored; forced to "" for credit line),
  #     events (CSV, default "loan,communication"; allowed values all|loan|communication|notice).
  #   Success 200 flat {output:[cust_ids], message:"success"}.
  #   Errors 400: {message:"status is invalid"} for a bad status;
  #     {output:"Invalid event provided", message:"failure"} for a bad event;
  #     {output:"start_time is incorrect"|"end_time is incorrect", message:"failure"} for bad epochs.

  Background:
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |

  # ---------- Auth & permission ----------

  @negative @creditline
  Scenario: Request without authenticationtoken header returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Invalid authenticationtoken returns 400
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid_token_12345 |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 400
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Missing company_id returns 400 "invalid company id"
    # Observed on staging: this GET endpoint returns 400 (not 403) with message "invalid company id".
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 400
    And the response message should be "invalid company id"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- Happy path (GET needs no loan permission) ----------

  @positive @smoke @creditline
  Scenario: Fetch customers with no filters returns 200 with a list of customer ids
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "output"
    And the response should match json schema "schemas/creditline/success/fetch_customers_success_schema.json"

  # ---------- events filter (Scenario Outline over valid values) ----------

  @positive @creditline @500
  Scenario Outline: events filter accepts each valid value and returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | events     | <events>     |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/fetch_customers_success_schema.json"

    Examples:
      | events             |
      | loan               |
      | communication      |
      | loan,communication |

    # TODO: verify on staging — creditline company data/config dependent (returns 500 "something went wrong").
    # The "notice" event (and "all", which includes it) triggers a notice-details fetch that fails on this staging company.
    @env-blocked
    Examples:
      | events             |
      | all                |
      | notice             |

  @negative @creditline
  Scenario: Invalid event value returns 400 "Invalid event provided"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID}    |
      | events     | not_a_valid_event |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 400
    And the response message should be "failure"
    And the response body should contain field "output" with value "Invalid event provided"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- status filter ----------

  @positive @creditline
  Scenario: status "open" is accepted and returns 200 (forced to "" for credit line)
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | status     | open         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/fetch_customers_success_schema.json"

  @negative @creditline
  Scenario: Invalid status value returns 400 "status is invalid"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID}  |
      | status     | not_a_status  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 400
    And the response message should be "status is invalid"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- start_time / end_time validation ----------

  @negative @creditline
  Scenario: Non-numeric start_time returns 400 "start_time is incorrect"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID}   |
      | start_time | not_an_epoch   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 400
    And the response message should be "failure"
    And the response body should contain field "output" with value "start_time is incorrect"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  @negative @creditline
  Scenario: Non-numeric end_time returns 400 "end_time is incorrect"
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | end_time   | not_an_epoch |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 400
    And the response message should be "failure"
    And the response body should contain field "output" with value "end_time is incorrect"
    And the response should match json schema "schemas/creditline/error/creditline_error_schema.json"

  # ---------- time-range filters (positive) ----------

  @positive @creditline @env-blocked @424
  # TODO: verify on staging — creditline company data/config dependent (returns 424 "Unable to get calling details").
  # Providing start_time/end_time triggers a downstream calling-details fetch that fails on this staging company.
  Scenario: start_time/end_time range using {NOW:epoch_seconds} returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID}       |
      | start_time | 1577836800         |
      | end_time   | {NOW:epoch_seconds} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/fetch_customers_success_schema.json"

  @positive @creditline @env-blocked @424
  # TODO: verify on staging — creditline company data/config dependent (returns 424 "Unable to get calling details").
  # Providing start_time/end_time triggers a downstream calling-details fetch that fails on this staging company.
  Scenario: start_time/end_time range using a captured time returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I capture the current time as "fetchTime"
    And I set the query parameters:
      | company_id | {COMPANY_ID}                          |
      | start_time | 1577836800                            |
      | end_time   | {CAPTURED_TIME:fetchTime:epoch_seconds} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/fetch_customers_success_schema.json"

  @positive @creditline @env-blocked @424
  # TODO: verify on staging — creditline company data/config dependent (returns 424 "Unable to get calling details").
  # Providing start_time triggers a downstream calling-details fetch that fails on this staging company.
  Scenario: start_time alone (open-ended range) returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | start_time | 1577836800   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/fetch_customers_success_schema.json"

  @positive @creditline @env-blocked @424
  # TODO: verify on staging — creditline company data/config dependent (returns 424 "Unable to get calling details").
  # Providing end_time triggers a downstream calling-details fetch that fails on this staging company.
  Scenario: end_time alone using {NOW:epoch_seconds} returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID}        |
      | end_time   | {NOW:epoch_seconds} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/fetch_customers_success_schema.json"

  # ---------- combined filters ----------

  @positive @creditline @env-blocked @424
  # TODO: verify on staging — creditline company data/config dependent (returns 424 "Unable to get calling details").
  # Providing start_time/end_time triggers a downstream calling-details fetch that fails on this staging company.
  Scenario: events + time range combined returns 200
    Given I authenticate as "creator" for "creditline" slot 0 and remember as "creatorc0"
    And I set the query parameters:
      | company_id | {COMPANY_ID}        |
      | events     | loan,communication  |
      | start_time | 1577836800          |
      | end_time   | {NOW:epoch_seconds} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/fetch/customers"
    Then the response status code should be 200
    And the response message should be "success"
    And the response should match json schema "schemas/creditline/success/fetch_customers_success_schema.json"
