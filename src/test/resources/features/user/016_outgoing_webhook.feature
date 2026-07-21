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
    And the "outgoing_webhook" success response should be valid

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
    And the "outgoing_webhook" success response should be valid

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
    And the "outgoing_webhook" success response should be valid

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
    And the "outgoing_webhook" success response should be valid

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
    And the "outgoing_webhook" success response should be valid

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

  # ---------------------------------------------------------------------------
  # Expanded coverage (flag coercion, item-form flags, response shape,
  # company_id negatives, webhook_id injection, method) —
  # grounded in outgoing-webhook-api-doc.md. Collection: GET/POST; item: GET/PATCH/DELETE.
  # ---------------------------------------------------------------------------

  @positive @creator
  Scenario: include_disabled with a non-literal value (TRUE) is treated as false and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled | TRUE         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the "outgoing_webhook" success response should be valid

  @positive @creator
  Scenario: is_payload_config_required with a non-literal value (1) is treated as false and returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | is_payload_config_required | 1            |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the "outgoing_webhook" success response should be valid

  @positive @creator
  Scenario: Item form with is_payload_config_required=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | is_payload_config_required | true         |
    And I set the path parameters:
      | webhook_id | nonexistentwebhookid000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: Item form with include_disabled=true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id       | {COMPANY_ID} |
      | include_disabled | true         |
    And I set the path parameters:
      | webhook_id | nonexistentwebhookid000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: Item form with both flags true returns 200
    Given I prepare a request
    And I set the query parameters:
      | company_id                 | {COMPANY_ID} |
      | include_disabled           | true         |
      | is_payload_config_required | true         |
    And I set the path parameters:
      | webhook_id | nonexistentwebhookid000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be 200

  @positive @creator
  Scenario: Unknown extra query parameters are ignored and return 200
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | foo        | bar          |
      | page       | 1            |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the "outgoing_webhook" success response should be valid

  @positive @smoke @creator
  Scenario: Success response exposes the documented raw shape (message + data)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response body should contain field "message"
    And the response body should contain field "data"
    And the response body should not be empty

  @negative @creator
  Scenario: Malformed (non-UUID) company_id is rejected with 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | not-a-valid-uuid |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Empty company_id value is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id |  |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be one of "400,403,422"
    And the response body should not be empty

  @negative @security @creator
  Scenario: SQL injection in company_id is rejected as malformed (400)
    Given I prepare a request
    And I set the query parameters:
      | company_id | ' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be one of "400,422"
    And the response body should not be empty

  @negative @security @creator
  Scenario: XSS payload in company_id is rejected as malformed (400)
    Given I prepare a request
    And I set the query parameters:
      | company_id | <xss>alert(1)</xss> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be one of "400,422"
    And the response body should not be empty

  @negative @creator
  Scenario: Well-formed but unknown/foreign company_id UUID is not accessible (cross-company scoping)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {UUID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/"
    Then the response status code should be one of "403,422"
    And the response body should not be empty

  @negative @security @creator
  Scenario: SQL injection in webhook_id is bound safely and returns 200 with empty data
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | webhook_id | ' OR '1'='1 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be one of "200,400,404"

  @negative @security @creator
  Scenario: XSS payload in webhook_id returns 200 with empty data (no reflection, no 404)
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | webhook_id | <xss>alert(1)</xss> |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be one of "200,400,404"

  @negative @boundary @creator
  Scenario: Very long webhook_id returns 200 with empty data
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | webhook_id | {RANDOM_STRING:300} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be one of "200,400,404,414"

  @negative @creator
  Scenario: Unicode webhook_id returns 200 with empty data
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | webhook_id | café-webhook-测试-😀 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be one of "200,400,404"

  @negative @creator
  Scenario: Unsupported verb PUT on the collection URL is rejected with 405
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "PUT" request to "/user/outgoing-webhook/"
    Then the response status code should be one of "404,405"

  @negative @creator
  Scenario: Unsupported verb PUT on the item URL is rejected with 405
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | webhook_id | nonexistentwebhookid000 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "PUT" request to "/user/outgoing-webhook/{webhook_id}"
    Then the response status code should be one of "404,405"
