@api @assign-default @recovery
Feature: Assign Default Dispositions API — POST /recovery/assign-default


  @negative
  Scenario: TC-AUTH-001 — Request without authenticationtoken header returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: TC-AUTH-003 — Valid token but non-existent organisation returns 422
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "00000000-dead-beef-ffff-000000000000",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 422
    And the response body should not be empty


  @negative @creator
  Scenario: TC-COMP-001 — Missing company_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-COMP-002 — company_id sent as null triggers server-side error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": null,
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-COMP-003 — company_id as empty string triggers server-side error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-COMP-004 — Non-existent company_id returns 422
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "00000000-0000-0000-0000-000000000000",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 422
    And the response body should not be empty


  @negative @creator
  Scenario: TC-USER-001 — Missing user_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-USER-002 — user_id sent as null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": null,
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-USER-003 — user_id as empty string triggers server-side error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator @500
  Scenario: TC-USER-004 — user_id with surrounding whitespace — behaviour TBD on staging
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "  usr_AbCdEfGhIjKlMnOp  ",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 200
    Then the response body should not be empty


  @positive @creator @500
  Scenario: TC-TYPE-001 — company_type "loan" creates full disposition set and returns 201
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 201
    Then the response body should not be empty

  @positive @creator @500
  Scenario: TC-TYPE-002 — company_type "credit line" creates filtered disposition set and returns 201
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "credit line"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 201
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-TYPE-003 — Missing company_type returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-TYPE-004 — company_type sent as null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": null
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator @500
  Scenario: TC-TYPE-005 — Unrecognised company_type accepted; service defaults to loan disposition path
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "unknown_type"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator @500
  Scenario: TC-TYPE-006 — company_type with surrounding whitespace is stripped to "credit line"
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "  credit line  "
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 200
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-BODY-001 — Empty JSON body returns 400 with all-fields-required error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator @500
  Scenario: TC-BODY-002 — Extra unknown fields are silently ignored by serializer
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan",
        "unknown_field": "should be ignored",
        "extra_number": 99999
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-BODY-003 — Integer values for all string fields — Pydantic coercion TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": 12345,
        "user_id": 67890,
        "company_type": true
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive @creator @500
  Scenario: TC-HAPPY-001 — Full success loan company — complete response shape verified
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should not be empty

  @positive @creator @500
  Scenario: TC-HAPPY-002 — Full success credit line company — complete response shape verified
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "credit line"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should not be empty


  @negative @creator @500
  Scenario: TC-IDEM-001 — Second call with same company_id fails with 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-IDEM-002 — Second call with same company_id and different user_id fails with 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "different-user-{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty



  @positive @creator @500
  Scenario: TC-SHAPE-001 — Success response contains exactly data, message, success keys
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 200
    Then the response body should not be empty
    And the response body should contain field "message"

  @negative @creator @500
  Scenario: TC-SHAPE-002 — Failure response contains output and message keys
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should not be empty


  @negative @creator @500
  Scenario Outline: TC-NULL-00x — Required field <field> set to null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    And I update JSON field "<field>" to null
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | field        |
      | company_id   |
      | user_id      |
      | company_type |


  @negative @creator
  Scenario Outline: TC-MISS-00x — Body missing only <absent_field> returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | absent_field | body                                                                   |
      | company_id   | {"user_id": "{UUID}", "company_type": "loan"}                          |
      | user_id      | {"company_id": "{COMPANY_ID}", "company_type": "loan"}                 |
      | company_type | {"company_id": "{COMPANY_ID}", "user_id": "{UUID}"}                    |



  @negative @creator @500
  Scenario Outline: TC-WS-00x — Field <field> as whitespace-only string behaviour TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    And I update JSON field "<field>" to "   "
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 422
    Then the response body should not be empty

    Examples:
      | field        |
      | company_id   |
      | user_id      |
      | company_type |


  @negative @creator
  Scenario: TC-EDGE-001 — Integer value for company_id field
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": 99999,
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-002 — company_id as 256-character random string returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{RANDOM_STRING:256}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-EDGE-003 — user_id as 256-character random string
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{RANDOM_STRING:256}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-EDGE-004 — Boolean value for company_type field
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": true
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty


  @negative @creator @500
  Scenario: TC-SVC-001 — DB transaction failure during disposition insert returns 400 with failure message
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty
    And the response body should not be empty

  @negative @creator @500
  Scenario: TC-SVC-002 — Move-loan restriction insert failure returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty



  @negative @creator
  Scenario: TC-EXTRA-001 — company_id as integer — Pydantic coercion behaviour TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": 99999,
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-002 — company_id with whitespace stripped by anystr_strip_whitespace
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "  00000000-0000-0000-0000-000000000000  ",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-EXTRA-003 — All three required fields null simultaneously returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": null,
        "user_id": null,
        "company_type": null
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-004 — company_type as list (wrong type) — Pydantic rejects non-string
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": ["loan"]
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator @500
  Scenario: TC-500-001 — Unhandled exception path (Kafka/DB failure) returns error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "user_id": "{UUID}",
        "company_type": "loan"
      }
      """
    When I send a "POST" request to "/recovery/assign-default"
    Then the response status code should be 400
    Then the response body should not be empty
