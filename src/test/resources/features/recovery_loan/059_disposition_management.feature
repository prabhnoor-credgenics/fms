@api @disposition-management @recovery
Feature: Disposition Management API — create/update Global & Module dispositions

  Background:
    Given scenario company id is from configuration
    And I prepare a request


  @positive @creator
  Scenario: TC_MOD_021 / TC_MOD_023 — Create a new Global Disposition with valid data
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_{RANDOM_STRING:8}",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 201
    And the response message should be "Global Disposition Created"
    And the response body should contain field "success"

  @positive @creator
  Scenario: TC_MOD_022 / TC_MOD_042 / TC_MOD_047 — Newly created Global Disposition appears in the listing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_Visible",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response body should contain text "AutoQA_GS_Visible"

  @negative @creator
  Scenario: TC_MOD_025 — Duplicate Global Disposition cannot be created
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_Dup",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_Dup",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response message should be "Global Disposition Already exists"

  @negative @creator
  Scenario: TC_MOD_040 — Global Disposition name is mandatory (blank name rejected)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: TC_MOD_040b — Global Disposition name field missing is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: TC_MOD_041 — Special characters in Global Disposition name are rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_@#$%_{RANDOM_STRING:5}",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: TC_MOD_040d — Global Disposition priority out of range (-1..3) is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_Prio_{RANDOM_STRING:5}",
        "priority": 99
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator
  Scenario: TC_MOD_043 — Multiple Global Dispositions can be created one after another
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_MultiA_{RANDOM_STRING:6}",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 201
    And the response message should be "Global Disposition Created"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_MultiB_{RANDOM_STRING:6}",
        "priority": 1
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 201
    And the response message should be "Global Disposition Created"

  @positive @creator
  Scenario: TC_MOD_049 / TC_MOD_055 — Existing dispositions remain intact after adding a new one
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_Intact_{RANDOM_STRING:6}",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 201
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And the response should match json schema "schemas/global_status/success/global_status_success_schema.json"
    And the response body should not be empty

  @negative @auth @creator
  Scenario: TC_MOD_006b — Create Global Disposition without authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | content-type | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_NoAuth",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response body should not be empty


  @positive @creator @edit
  Scenario: TC_MOD_034 — Update the priority of an existing Global Disposition
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_Priority",
        "priority": 0
      }
      """
    When I send a "POST" request to "/recovery/global-status"
    Then the response status code should be one of "201,400"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_Priority",
        "priority": 3
      }
      """
    When I send a "PATCH" request to "/recovery/global-status"
    Then the response status code should be 201
    And the response message should be "Global Disposition updated"

  @negative @creator @edit
  Scenario: TC_MOD_034c — Updating a non-existent Global Disposition is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_DoesNotExist_{RANDOM_STRING:6}",
        "priority": 2
      }
      """
    When I send a "PATCH" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response message should be "Global Disposition does not exists"

  @negative @auth @creator @edit
  Scenario: TC_MOD_034b — Update Global Disposition priority without auth token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | content-type | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "global_status_name": "AutoQA_GS_Priority",
        "priority": 3
      }
      """
    When I send a "PATCH" request to "/recovery/global-status"
    Then the response status code should be 400
    And the response body should not be empty


  @positive @creator
  Scenario: TC_MOD_026 — Create a parent Module Disposition (no children)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_Parent_{RANDOM_STRING:6}",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "is_committed_amount_required": false,
        "is_remark_required": false,
        "is_reminder_required": false,
        "is_sub_disposition_required": false,
        "is_settlement_enabled": false,
        "is_voicebot_enabled": false,
        "is_chatr_enabled": false,
        "is_repossession_requests_enabled": false,
        "max_reminder_interval": 30,
        "sub_dispositions": null,
        "global_status_id": {MAPPING_ID},
        "product_type": [],
        "is_foreclosure_enabled": false,
        "is_repossession_enabled": false
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 201
    And the response message should be "Disposition Created"

  @positive @creator
  Scenario: TC_MOD_027 — Create a Module Disposition with a single child (sub-disposition)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_Parent1_{RANDOM_STRING:6}",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "is_sub_disposition_required": true,
        "max_reminder_interval": 30,
        "global_status_id": {MAPPING_ID},
        "product_type": [],
        "sub_dispositions": [
          {
            "name": "AutoQA_MD_Child_{RANDOM_STRING:6}",
            "is_calling_enabled": true,
            "is_fos_enabled": false,
            "is_legal_enabled": false,
            "is_fos_collections_enabled": false,
            "is_sub_disposition_required": false,
            "sub_dispositions": null
          }
        ]
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 201
    And the response message should be "Disposition Created"

  @positive @creator
  Scenario: TC_MOD_028 / TC_MOD_045 — Multiple unique child dispositions under one parent are saved
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_MultiChild_{RANDOM_STRING:6}",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "is_sub_disposition_required": true,
        "max_reminder_interval": 30,
        "global_status_id": {MAPPING_ID},
        "product_type": [],
        "sub_dispositions": [
          { "name": "AutoQA_Child_A_{RANDOM_STRING:5}", "is_calling_enabled": true, "is_fos_enabled": false, "is_legal_enabled": false, "is_fos_collections_enabled": false, "sub_dispositions": null },
          { "name": "AutoQA_Child_B_{RANDOM_STRING:5}", "is_calling_enabled": true, "is_fos_enabled": false, "is_legal_enabled": false, "is_fos_collections_enabled": false, "sub_dispositions": null }
        ]
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 201
    And the response message should be "Disposition Created"

  @positive @creator
  Scenario: TC_MOD_031 — Create a multi-level (3-deep) disposition hierarchy in one save
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_L1_{RANDOM_STRING:6}",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "is_sub_disposition_required": true,
        "max_reminder_interval": 30,
        "global_status_id": {MAPPING_ID},
        "product_type": [],
        "sub_dispositions": [
          {
            "name": "AutoQA_MD_L2_{RANDOM_STRING:5}",
            "is_calling_enabled": true,
            "is_fos_enabled": false,
            "is_legal_enabled": false,
            "is_fos_collections_enabled": false,
            "is_sub_disposition_required": true,
            "sub_dispositions": [
              {
                "name": "AutoQA_MD_L3_{RANDOM_STRING:5}",
                "is_calling_enabled": true,
                "is_fos_enabled": false,
                "is_legal_enabled": false,
                "is_fos_collections_enabled": false,
                "is_sub_disposition_required": false,
                "sub_dispositions": null
              }
            ]
          }
        ]
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 201
    And the response message should be "Disposition Created"

  @positive @creator @mapping
  Scenario: TC_MOD_039 — Module Disposition is mapped to a Global Disposition via global_status_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_Mapped_{RANDOM_STRING:6}",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "max_reminder_interval": 30,
        "global_status_id": {MAPPING_ID},
        "product_type": [],
        "sub_dispositions": null
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 201
    And the response message should be "Disposition Created"

  @negative @creator @mapping
  Scenario: TC_MOD_039b — Module Disposition with an invalid global_status_id is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_BadMap_{RANDOM_STRING:6}",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "max_reminder_interval": 30,
        "global_status_id": 999999999,
        "product_type": [],
        "sub_dispositions": null
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 400
    And the response message should be "Incorrect Global Disposition ID"

  @negative @creator
  Scenario: TC_MOD_030 — Child disposition with a blank name is rejected (mandatory validation)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_BadChild_{RANDOM_STRING:6}",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "is_sub_disposition_required": true,
        "max_reminder_interval": 30,
        "global_status_id": {MAPPING_ID},
        "product_type": [],
        "sub_dispositions": [
          { "name": "", "is_calling_enabled": true, "is_fos_enabled": false, "is_legal_enabled": false, "is_fos_collections_enabled": false, "sub_dispositions": null }
        ]
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: TC_MOD_038 / TC_MOD_040c — Parent Module Disposition with a blank name is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "max_reminder_interval": 30,
        "global_status_id": {MAPPING_ID},
        "product_type": [],
        "sub_dispositions": null
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator @siblings
  Scenario: TC_MOD_044 — Sibling children in a single create call are NOT de-duplicated (accepted 201)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_DupChildParent_{RANDOM_STRING:6}",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "is_sub_disposition_required": true,
        "max_reminder_interval": 30,
        "global_status_id": {MAPPING_ID},
        "product_type": [],
        "sub_dispositions": [
          { "name": "AutoQA_SameChild_{RANDOM_STRING:4}", "is_calling_enabled": true, "is_fos_enabled": false, "is_legal_enabled": false, "is_fos_collections_enabled": false, "sub_dispositions": null }
        ]
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 201
    And the response message should be "Disposition Created"

  @negative @auth @creator
  Scenario: TC_MOD_007b — Create Module Disposition with an invalid authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
      | content-type        | application/json                  |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "name": "AutoQA_MD_InvalidAuth",
        "is_calling_enabled": true,
        "is_fos_enabled": false,
        "is_legal_enabled": false,
        "is_fos_collections_enabled": false,
        "sub_dispositions": null
      }
      """
    When I send a "POST" request to "/recovery/disposition"
    Then the response status code should be 400
    And the response body should not be empty


  @positive @creator @edit
  Scenario: TC_MOD_032 / TC_MOD_037 — Edit a Module Disposition (update flags) returns 200 and persists
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And I store response field "data[0].id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the path parameters:
      | dispId | {MAPPING_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_calling_enabled": true,
        "max_reminder_interval": 33,
        "global_status_id": {VARIABLE_ID}
      }
      """
    When I send a "PATCH" request to "/recovery/disposition/{dispId}"
    Then the response status code should be 200
    And the response message should be "Disposition Updated"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response body should contain field "data"

  @positive @creator @edit
  Scenario: TC_MOD_033 / TC_MOD_051 — Update advanced configuration flags on an existing disposition
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And I store response field "data[0].id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the path parameters:
      | dispId | {MAPPING_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_committed_amount_required": true,
        "is_remark_required": true,
        "is_reminder_required": true,
        "is_calling_enabled": true,
        "max_reminder_interval": 45,
        "global_status_id": {VARIABLE_ID}
      }
      """
    When I send a "PATCH" request to "/recovery/disposition/{dispId}"
    Then the response status code should be 200
    And the response message should be "Disposition Updated"

  @negative @creator @edit
  Scenario: TC_MOD_035 — Edit with an invalid global_status_id is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And I store response field "data[0].id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the path parameters:
      | dispId | {MAPPING_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_calling_enabled": true,
        "global_status_id": 999999999
      }
      """
    When I send a "PATCH" request to "/recovery/disposition/{dispId}"
    Then the response status code should be 400
    And the response message should be "Enter valid global status id to update"

  @positive @creator @edit
  Scenario: TC_MOD_036 — Existing values are returned for an edit form (pre-fill / GET-by-list)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response body should not be empty
    And the response body should contain field "data"

  @positive @creator @edit
  Scenario: TC_MOD_054 — Update returns the "Disposition Updated" acknowledgement
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as variable id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And I store response field "data[0].id" as mapping id
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the path parameters:
      | dispId | {MAPPING_ID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_calling_enabled": true,
        "global_status_id": {VARIABLE_ID}
      }
      """
    When I send a "PATCH" request to "/recovery/disposition/{dispId}"
    Then the response status code should be 200
    And the response message should be "Disposition Updated"

  @negative @auth @creator @edit
  Scenario: TC_MOD_038b — Edit with an invalid authentication token is rejected
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
      | content-type        | application/json                  |
    And I set the path parameters:
      | dispId | 216855 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_calling_enabled": true
      }
      """
    When I send a "PATCH" request to "/recovery/disposition/{dispId}"
    Then the response status code should be 400
    And the response body should not be empty


  @positive @creator @read-back
  Scenario: TC_MOD_029 / TC_MOD_048 — Saved disposition hierarchy is returned on re-fetch
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And I store response field "data[0].id" as "hierarchyDispId"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | dispId | {CAPTURED:hierarchyDispId} |
    When I send a "GET" request to "/recovery/disposition/{dispId}"
    Then the response status code should be one of "200,400"
    And the response body should not be empty

  @positive @creator @read-back
  Scenario: TC_MOD_052 — Fields not sent in the PATCH keep their stored value on re-fetch
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as "partialGlobalId"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And I store response field "data[0].id" as "partialDispId"
    And I store response field "data[0].name" as "partialDispName"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the path parameters:
      | dispId | {CAPTURED:partialDispId} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "max_reminder_interval": 21,
        "global_status_id": {CAPTURED:partialGlobalId}
      }
      """
    When I send a "PATCH" request to "/recovery/disposition/{dispId}"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response body should contain text "{CAPTURED:partialDispName}"

  @positive @creator @read-back
  Scenario: TC_MOD_053 — Editing one disposition leaves a sibling disposition untouched
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/global-status"
    Then the response status code should be 200
    And I store response field "data[0].global_status_id" as "siblingGlobalId"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And I store response field "data[0].id" as "editTargetId"
    And I store response field "data[1].name" as "siblingName"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | content-type        | application/json                  |
    And I set the path parameters:
      | dispId | {CAPTURED:editTargetId} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "is_calling_enabled": true,
        "max_reminder_interval": 17,
        "global_status_id": {CAPTURED:siblingGlobalId}
      }
      """
    When I send a "PATCH" request to "/recovery/disposition/{dispId}"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And the response body should contain text "{CAPTURED:siblingName}"

  @positive @creator @read-back
  Scenario: TC_MOD_046 — Sub-disposition endpoint resolves for a parent disposition
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/disposition"
    Then the response status code should be 200
    And I store response field "data[0].id" as "childParentId"
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the path parameters:
      | dispId  | {CAPTURED:childParentId} |
      | subDisp | {UUID}                   |
    When I send a "GET" request to "/recovery/disposition/{dispId}/sub_disposition/{subDisp}"
    Then the response status code should be one of "200,400,404"
    And the response body should not be empty
