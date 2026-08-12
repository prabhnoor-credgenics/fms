@api @user @payload-transformation @outgoing-webhook
Feature: Advance Configuration — Payload Transformation (outgoing webhook v2 payload config)

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"
    And I prepare a request


  @positive @chief-admin
  Scenario: TC_ADV_038 / TC_ADV_017 — Save a payload config with a static string value
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Platform",
        "event_name": "payment",
        "is_enabled": true,
        "company_payloads": [],
        "config_data": {
          "loan_attributes_required": false,
          "allocation_attributes_required": false,
          "key_config": [
            { "key": "greeting", "data_type": "text", "value_source": "static", "static_value": "hello" }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 201
    And the response body should contain text "Webhook payload config added successfully."

  @positive @chief-admin
  Scenario: TC_ADV_018 / TC_ADV_019 / TC_ADV_042 — Static number & boolean values are accepted
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Platform",
        "event_name": "loan_allocation",
        "is_enabled": true,
        "config_data": {
          "key_config": [
            { "key": "count", "data_type": "integer", "value_source": "static", "static_value": 42 },
            { "key": "flag", "data_type": "boolean", "value_source": "static", "static_value": true }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 201
    And the response body should contain text "Webhook payload config added successfully."

  @positive @chief-admin @mapping
  Scenario: TC_ADV_015 / TC_ADV_016 — Mapped source key and nested dot-notation mapping are accepted
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Platform",
        "event_name": "loan_deallocation",
        "config_data": {
          "key_config": [
            { "key": "loan_ref", "data_type": "text", "value_source": "mapped", "source": { "type": "cg_payload", "path": "loan_id" } },
            { "key": "customer.name", "data_type": "text", "value_source": "mapped", "source": { "type": "cg_payload", "path": "data.applicant_name" } }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 201
    And the response body should contain text "Webhook payload config added successfully."

  @positive @chief-admin @conditional
  Scenario: TC_ADV_020..027 / TC_ADV_043 — Conditional IF/ELSE with comparison + AND/OR group is accepted
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Communications",
        "event_name": "email",
        "config_data": {
          "key_config": [
            {
              "key": "tier",
              "data_type": "text",
              "value_source": "conditional",
              "conditional": {
                "rules": [
                  {
                    "when": {
                      "node_type": "group",
                      "op": "AND",
                      "children": [
                        { "node_type": "comparison", "left": { "type": "cg_payload", "path": "amount" }, "op": "gt", "right": { "type": "static", "value": 1000 } },
                        { "node_type": "comparison", "left": { "type": "cg_payload", "path": "status" }, "op": "eq", "right": { "type": "static", "value": "active" } }
                      ]
                    },
                    "then": { "type": "static", "value": "gold" }
                  }
                ],
                "else": { "type": "static", "value": "silver" }
              }
            }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 201
    And the response body should contain text "Webhook payload config added successfully."

  @positive @chief-admin @formatting
  Scenario: TC_ADV_031..036 / TC_ADV_044 — Formatting rules (case, date, datetime, decimal) are accepted
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Communications",
        "event_name": "sms",
        "config_data": {
          "key_config": [
            { "key": "name_up", "data_type": "text", "value_source": "mapped", "source": { "type": "cg_payload", "path": "name" }, "formatting": "uppercase" },
            { "key": "name_low", "data_type": "text", "value_source": "mapped", "source": { "type": "cg_payload", "path": "name" }, "formatting": "lowercase" },
            { "key": "name_title", "data_type": "text", "value_source": "mapped", "source": { "type": "cg_payload", "path": "name" }, "formatting": "titlecase" },
            { "key": "dob", "data_type": "date", "value_source": "mapped", "source": { "type": "cg_payload", "path": "dob" }, "formatting": "DD/MM/YYYY" },
            { "key": "ts", "data_type": "datetime", "value_source": "mapped", "source": { "type": "cg_payload", "path": "ts" }, "formatting": "YYYY-MM-DD HH:mm:ss" },
            { "key": "amt", "data_type": "decimal", "value_source": "mapped", "source": { "type": "cg_payload", "path": "amount" }, "formatting": 2 }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 201
    And the response body should contain text "Webhook payload config added successfully."

  @positive @chief-admin @inclusion
  Scenario: TC_ADV_028..030 / TC_ADV_045 — Conditional key inclusion (do_not_send / null actions) is accepted
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Communications",
        "event_name": "whatsapp",
        "config_data": {
          "key_config": [
            {
              "key": "optional_field",
              "data_type": "text",
              "value_source": "conditional",
              "conditional": {
                "rules": [
                  { "when": { "node_type": "comparison", "left": { "type": "cg_payload", "path": "opt_in" }, "op": "eq", "right": { "type": "static", "value": "yes" } },
                    "then": { "type": "cg_payload", "path": "email" } }
                ],
                "else": { "type": "do_not_send" }
              }
            }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 201
    And the response body should contain text "Webhook payload config added successfully."

  @positive @chief-admin @nested
  Scenario: TC_ADV_037 / TC_ADV_011 / TC_ADV_013 — Nested output object via dot-notation key is accepted
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Communications",
        "event_name": "voice",
        "config_data": {
          "key_config": [
            { "key": "borrower.address.city", "data_type": "text", "value_source": "static", "static_value": "Mumbai" }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 201
    And the response body should contain text "Webhook payload config added successfully."

  @positive @chief-admin
  Scenario: TC_ADV_040 — Saved payload configurations are listed
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    When I send a "GET" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 200
    And the response body should contain field "data"

  @positive @chief-admin
  Scenario: TC_ADV_009 / TC_ADV_010 — Selectable source-key catalog (aliasing keys) is returned
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
    And I set the query parameters:
      | company_id  | {COMPANY_ID:creator0} |
      | module_name | Platform              |
      | event_name  | payment               |
    When I send a "GET" request to "/user/outgoing-webhook/v2/aliasing-keys/"
    Then the response status code should be 200
    And the response body should contain field "data"


  @negative @chief-admin
  Scenario: TC_ADV_003 — Missing/invalid module & event is rejected
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "NotARealModule",
        "event_name": "not_an_event",
        "config_data": { "key_config": [ { "key": "x", "data_type": "text", "value_source": "static", "static_value": "y" } ] }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 400
    And the response message should be "invalid event_name or module_name provided"

  @negative @chief-admin
  Scenario: TC_ADV_006a — Empty key_config is rejected (Invalid Configuration Payload)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Platform",
        "event_name": "payment",
        "config_data": { "key_config": [] }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 400
    And the response message should be "Invalid Configuration Payload"

  @negative @chief-admin
  Scenario: TC_ADV_006b — Formatting on an integer field is rejected (Invalid Configuration Payload)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Platform",
        "event_name": "payment",
        "config_data": {
          "key_config": [
            { "key": "n", "data_type": "integer", "value_source": "mapped", "source": { "type": "cg_payload", "path": "n" }, "formatting": "uppercase" }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 400
    And the response message should be "Invalid Configuration Payload"

  @negative @chief-admin
  Scenario: TC_ADV_006c — Mapped operand missing its path is rejected (Invalid Configuration Payload)
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Platform",
        "event_name": "payment",
        "config_data": {
          "key_config": [
            { "key": "x", "data_type": "text", "value_source": "mapped", "source": { "type": "cg_payload" } }
          ]
        }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be 400
    And the response message should be "Invalid Configuration Payload"

  @negative @chief-admin @edit
  Scenario: TC_ADV_039 — Editing a non-existent payload config id is rejected
    Given I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:chiefadmin0} |
      | content-type        | application/json         |
    And I set the path parameters:
      | configId | non-existent-config-{RANDOM_STRING:8} |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      { "is_enabled": false }
      """
    When I send a "PATCH" request to "/user/outgoing-webhook/v2/payload-config/{configId}"
    Then the response status code should be 400
    And the response message should be "Payload Configuration does not exist"

  @negative @auth @chief-admin
  Scenario: TC_ADV_006d — Save without an authentication token is rejected
    Given I set the request headers:
      | content-type | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request body:
      """
      {
        "module_name": "Platform",
        "event_name": "payment",
        "config_data": { "key_config": [ { "key": "x", "data_type": "text", "value_source": "static", "static_value": "y" } ] }
      }
      """
    When I send a "POST" request to "/user/outgoing-webhook/v2/payload-config/"
    Then the response status code should be one of "400,401"
    And the response body should not be empty
