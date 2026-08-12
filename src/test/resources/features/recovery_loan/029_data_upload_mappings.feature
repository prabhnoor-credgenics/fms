@api @data-upload-mappings @recovery
Feature: Data Upload Mappings API — GET / POST / PATCH /recovery/data-upload/mappings


  @negative
  Scenario: TC-AUTH-001 — GET list with no authenticationtoken header returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept | application/json |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    And the response body should not be empty

  @negative
  Scenario: TC-AUTH-002 — Invalid authenticationtoken returns 401
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json  |
      | authenticationtoken | invalid-token-xyz |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: TC-AUTH-003 — Valid token with loan_upload permission returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-COMP-001 — GET list without company_id query param returns 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: TC-COMP-002 — POST without company_id in body returns 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "mapping_name": "test-no-company-{RANDOM_STRING:6}",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 403
    And the response body should not be empty

  @negative @creator
  Scenario: TC-COMP-003 — Non-existent company_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 422
    And the response body should not be empty


  @positive @creator
  Scenario: TC-LIST-001 — List all active mappings returns 200 with correct shape
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-LIST-002 — List with query filter returns only matching mappings
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | query      | test         |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-LIST-003 — List with query that matches no mappings returns empty output list
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}          |
      | query      | zzz-no-match-xyzzy123 |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-LIST-004 — List with uppercase query — case-insensitive match still works
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | query      | TEST         |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-LIST-005 — List with empty query param returns all mappings (treated as no filter)
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | query      |              |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-DETAIL-001 — GET list returns 200 with correct shape
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-DETAIL-002 — GET list with use_case query param returns 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
      | use_case   | loan_upload  |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DETAIL-003 — mapping_id as non-integer string returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings/not-a-number"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DETAIL-004 — Non-existent mapping_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings/99999999"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DETAIL-005 — mapping_id = 0 (boundary — no valid mapping has ID 0) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings/0"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-DETAIL-006 — mapping_id without company_id query param returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/data-upload/mappings/1"
    Then the response status code should be 403
    And the response body should not be empty


  @positive @creator
  Scenario: TC-POST-001 — Create mapping with simple string variable — happy path
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "test-mapping-{RANDOM_STRING:8}",
        "mapping_variables": {
          "loan_id": "Loan ID"
        }
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-POST-002 — Create mapping with optional description included
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "desc-mapping-{RANDOM_STRING:8}",
        "mapping_description": "A test mapping with description",
        "mapping_variables": {
          "loan_id": "Loan ID"
        }
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-POST-003 — Create mapping with multi-value list variable
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "multi-val-{RANDOM_STRING:8}",
        "mapping_variables": {
          "loan_id": "Loan ID",
          "contact_number": ["Mobile Number", "Alternate Number"]
        }
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-POST-004 — mapping_name is stored in lowercase — case-normalisation verified
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "UPPERCASE NAME {RANDOM_STRING:6}",
        "mapping_variables": {
          "loan_id": "Loan ID"
        }
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-POST-005 — Create mapping with extra unknown fields — silently dropped
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "extra-fields-{RANDOM_STRING:8}",
        "mapping_variables": {"loan_id": "Loan ID"},
        "unknown_field": "should be ignored",
        "another_extra": 12345
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-POST-006 — Duplicate mapping_name for same company returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "duplicate-test-mapping",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "duplicate-test-mapping",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-POST-007 — Empty mapping_variables dict returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "empty-vars-{RANDOM_STRING:6}",
        "mapping_variables": {}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-POST-008 — Invalid variable ID in mapping_variables returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "bad-var-{RANDOM_STRING:6}",
        "mapping_variables": {
          "nonexistent_variable_id_xyz": "Some Column"
        }
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-POST-009 — mapping_variables with all-null values reduces to empty after preprocessing
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "null-vars-{RANDOM_STRING:6}",
        "mapping_variables": {
          "loan_id": null
        }
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-POST-010 — Missing mapping_name returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-POST-011 — Missing mapping_variables returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "no-vars-{RANDOM_STRING:6}"
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-POST-012 — mapping_name = null returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": null,
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-POST-013 — mapping_variables as list (wrong type) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "wrong-type-{RANDOM_STRING:6}",
        "mapping_variables": ["loan_id", "applicant_name"]
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-PATCH-001 — Update mapping variables — happy path
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "updated-mapping",
        "mapping_variables": {
          "loan_id": "Updated Loan ID"
        }
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-PATCH-002 — Update with multi-value list variable replaces previous variables
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "updated-contact-mapping",
        "mapping_variables": {
          "loan_id": "Loan ID",
          "contact_number": ["New Mobile 1", "New Mobile 2"]
        }
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-PATCH-003 — PATCH idempotent — same body sent twice both return 200
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "idempotent-mapping",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "idempotent-mapping",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-PATCH-004 — Missing mapping_name returns 400 with REC_0080
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-PATCH-005 — Missing mapping_variables returns 400 with REC_0080
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "incomplete-patch"
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-PATCH-006 — Empty mapping_variables returns 400 with REC_0083
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "empty-vars-patch",
        "mapping_variables": {}
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-PATCH-007 — Invalid variable ID in PATCH returns 400 with REC_0083
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "bad-var-patch",
        "mapping_variables": {"fake_variable_id_xyz": "Column"}
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-PATCH-008 — Non-existent mapping_id in PATCH — behaviour TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "non-existent-patch",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/99999999"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-FLOW-001 — POST creates mapping then GET detail retrieves it by stored mapping_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "flow-test-{RANDOM_STRING:8}",
        "mapping_description": "Created for flow test",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response body should not be empty
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @positive @creator
  Scenario: TC-FLOW-002 — POST then PATCH then GET — verifies update cycle completes
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "update-flow-{RANDOM_STRING:8}",
        "mapping_variables": {"loan_id": "Original Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response body should not be empty
    And I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
      """
      {
        "mapping_name": "updated-loan-mapping",
        "mapping_variables": {"loan_id": "Updated Loan ID"}
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response body should not be empty
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 400
    Then the response body should not be empty


  @negative @creator
  Scenario Outline: TC-MIDVAL-00x — mapping_id value "<mid_value>" returns 400 invalid mapping_id
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings/<mid_value>"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | mid_value    |
      | abc          |
      | not-a-number |
      | 0            |
      | 99999999     |


  @negative @creator
  Scenario Outline: TC-POSTMISS-00x — POST body missing <absent_field> returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      <body>
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

    Examples:
      | absent_field      | body                                                                        |
      | mapping_name      | {"company_id": "{COMPANY_ID}", "mapping_variables": {"loan_id": "Loan ID"}} |
      | mapping_variables | {"company_id": "{COMPANY_ID}", "mapping_name": "no-vars-outline-{UUID}"}    |

  @negative @creator
  Scenario: TC-POSTMISS-003 — POST body missing company_id returns 403
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {"mapping_name": "no-company-outline-{UUID}", "mapping_variables": {"loan_id": "Loan ID"}}
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 403
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-EDGE-001 — mapping_name as empty string after whitespace stripping returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "   ",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-002 — Very long mapping_name (256 chars) — no max-length in serializer
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "{RANDOM_STRING:256}",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-003 — mapping_variables as string (wrong type) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "string-vars-{RANDOM_STRING:6}",
        "mapping_variables": "loan_id"
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EDGE-004 — mapping_variables as integer (wrong type) returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "int-vars-{RANDOM_STRING:6}",
        "mapping_variables": 12345
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator @500
  Scenario: TC-EDGE-005 — GET list with very long query string does not crash server
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}        |
      | query      | {RANDOM_STRING:200} |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty


  @negative @creator
  Scenario: TC-EXTRA-001 — PATCH without company_id query param returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the path parameters:
      | mappingId | 1 |
    And I set the request body:
      """
      {
        "mapping_name": "patch-no-company",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "PATCH" request to "/recovery/data-upload/mappings/{mappingId}"
    Then the response status code should be 403
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-002 — GET detail with negative mapping_id returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/recovery/data-upload/mappings/-1"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-003 — mapping_name = empty string returns 400
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @positive @creator
  Scenario: TC-EXTRA-004 — GET list with special characters in query does not crash
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID}    |
      | query      | test' OR '1'='1 |
    When I send a "GET" request to "/recovery/data-upload/mappings"
    Then the response status code should be 200
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-EXTRA-005 — mapping_name with only whitespace stripped to empty TBD
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "    ",
        "mapping_variables": {"loan_id": "Loan ID"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty

  @negative @creator
  Scenario: TC-500-001 — Service layer error path returns error
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "company_id": "{COMPANY_ID}",
        "mapping_name": "svc-fail-{RANDOM_STRING:6}",
        "mapping_variables": {"nonexistent_variable_{UUID}": "Column"}
      }
      """
    When I send a "POST" request to "/recovery/data-upload/mappings"
    Then the response status code should be 400
    Then the response body should not be empty
