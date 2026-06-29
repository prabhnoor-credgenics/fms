@api @user @outgoing-webhook
Feature: Outgoing Webhook — GET /user/outgoing-webhook/



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Minimal — enabled webhooks (collection) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/outgoing_webhook_success_schema.json"
    And the outgoing webhook success response should be valid

  @positive @creator
  Scenario: include_disabled=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the outgoing webhook success response should be valid

  @positive @creator
  Scenario: include_disabled=false (explicit default, may serve from cache) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the outgoing webhook success response should be valid

  @positive @creator
  Scenario: is_payload_config_required=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | is_payload_config_required | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the outgoing webhook success response should be valid

  @positive @creator
  Scenario: Both flags true (settings screen — full config) returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_disabled           | true         |
      | is_payload_config_required | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the outgoing webhook success response should be valid

  @positive @creator
  Scenario: Item form — a non-matching webhook id returns 200 with empty data (not 404)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | webhook_id | nonexistentwebhookid000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be 200


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected with 403
    # Observed on staging: this permission-gated endpoint returns 403 (not 400) when company_id is absent
    # — the permission/org check fails before handler-level parameter validation.
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: Unknown (well-formed) UUID company_id is rejected with 422
    # Observed on staging: a well-formed but non-existent company_id UUID resolves to 422 (org lookup
    # found no such company), distinct from a malformed/non-UUID company_id which is 400.
    Given I prepare a request
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 422
    And the response body should not be empty
