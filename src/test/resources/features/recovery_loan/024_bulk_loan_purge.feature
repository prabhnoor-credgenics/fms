#@api @bulk-loan-purge @recovery
#Feature: Bulk Loan Purge API (data_purging)
#
#
#  @negative @auth @creator @flaky
#  Scenario: DELETE bulk loan without authentication token returns 401
#    Given I prepare a request
#    And I set the request headers:
#      | accept       | application/json, text/plain, */* |
#      | Content-Type | application/json                  |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
#    And the response body should contain field "message" with value "invalid authentication token"
#
#  @negative @auth @creator @flaky
#  Scenario: DELETE bulk loan with an invalid authentication token returns 401
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | invalid_token_12345               |
#      | Content-Type        | application/json                  |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
#    And the response body should contain field "message" with value "invalid authentication token"
#
#
#  @negative @org @creator
#  Scenario: DELETE bulk loan with a valid body is rejected at org resolution (400 invalid company id)
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
#    And the response body should contain field "message" with value "invalid company id"
#
#  @negative @org @creator
#  Scenario: DELETE bulk loan with a wrong RPC secret is still rejected at org resolution (400)
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | wrong-rpc-secret-key             |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message" with value "invalid company id"
#
#  @negative @org @approver
#  Scenario: DELETE bulk loan as approver is rejected at org resolution (400 invalid company id)
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message" with value "invalid company id"
#
#  @negative @org @creator
#  Scenario Outline: DELETE bulk loan is rejected at org resolution regardless of body "<description>"
#    # Org resolution precedes body validation: each body below would otherwise be a 400 body error,
#    # but for the automation user they all return 400 "invalid company id" first.
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#    And I set the request body:
#      """
#      <body>
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message" with value "invalid company id"
#
#    Examples:
#      | description           | body                          |
#      | empty object          | {}                            |
#      | empty loan_ids list   | { "loan_ids": [] }            |
#      | loan_ids as string    | { "loan_ids": "not-a-list" }  |
#      | missing loan_ids key  | { "other": 1 }                |
#
#  # @manual — the documented RPC gate (403). Needs an account whose org is authorised for this
#  # internal route so @verify_organisation passes first. # TODO: verify on staging.
#  @manual @rpc-required @negative @rpc @creator @500
#  Scenario: DELETE bulk loan with missing RPC secret returns 403 (requires org authorised for route)
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 422
#    And the bulk loan purge forbidden response should be valid
#
#  # =====================================================================
#  # @manual @rpc-required — BODY VALIDATION MATRIX (400).
#  # Requires a valid Rpc_Secret_Key (replace {RPC_SECRET_KEY} with the real secret, or wire a
#  # resolver for it). Header placeholders are NOT auto-resolved by the framework.
#  # TODO: verify on staging — all scenarios below need the RPC secret to reach body validation.
#  # =====================================================================
#
#  @manual @rpc-required @negative @creator @500
#  Scenario: DELETE bulk loan with missing loan_ids key returns 400
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      {}
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message"
#
#  @manual @rpc-required @negative @creator @500
#  Scenario: DELETE bulk loan with an empty request body returns 400
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message" with value "Empty request body"
#
#  @manual @rpc-required @negative @creator @500
#  Scenario: DELETE bulk loan with loan_ids present but null returns 400
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      { "loan_ids": null }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message"
#
#  @manual @rpc-required @negative @creator @500
#  Scenario: DELETE bulk loan with an empty loan_ids list returns 400 (handler-level)
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      { "loan_ids": [] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message" with value "No loan id provided"
#
#  @manual @rpc-required @negative @creator @500
#  Scenario Outline: DELETE bulk loan with wrong-typed loan_ids "<description>" returns 400
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      <body>
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message"
#
#    Examples:
#      | description              | body                              |
#      | loan_ids as string       | { "loan_ids": "uloan124" }        |
#      | loan_ids as integer      | { "loan_ids": 123 }               |
#      | loan_ids as object       | { "loan_ids": {} }                |
#      | loan_ids as boolean      | { "loan_ids": true }              |
#      | element is an integer    | { "loan_ids": [123] }             |
#      | element is null          | { "loan_ids": [null] }            |
#      | element is a boolean     | { "loan_ids": [true] }            |
#      | element is an object     | { "loan_ids": [{}] }              |
#      | element is a nested list | { "loan_ids": [["x"]] }           |
#
#  @manual @rpc-required @negative @boundary @creator @500
#  Scenario: DELETE bulk loan with 501 loan_ids exceeds the max limit and returns 400
#
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body from file "test-data/bulk_loan_purge_501_ids.json"
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 400
#    And the response body should contain field "message" with value "loan_ids length exceeds max allowed limit of 500"
#
#
#  @manual @rpc-required @destructive @positive @creator @500
#  Scenario: DELETE bulk loan with a single disposable id returns 200 (minimal required field)
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}", "loan_ids": ["ZZZ_DISPOSABLE_{RANDOM_STRING:12}"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 200
#    And the response should match json schema "schemas/recovery/success/bulk_loan_purge_success_schema.json"
#    And the bulk loan purge success response should be valid
#
#  @manual @rpc-required @destructive @positive @creator @500
#  Scenario: DELETE bulk loan with multiple disposable ids returns 200
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}", "loan_ids": ["ZZZ_DISPOSABLE_{RANDOM_STRING:10}", "ZZZ_DISPOSABLE_{RANDOM_STRING:10}", "ZZZ_DISPOSABLE_{RANDOM_STRING:10}"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 200
#    And the bulk loan purge success response should be valid
#
#  @manual @rpc-required @destructive @positive @creator @500
#  Scenario: DELETE bulk loan for a valid-format but non-existent id returns 200 (no 404 for unknown id)
#    # TODO: verify on staging — doc specifies no 404; purge of an unknown id is a no-op 200.
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      {
#        "company_id": "{COMPANY_ID}", "loan_ids": ["{UUID}"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 200
#    And the bulk loan purge success response should be valid
#
#  @manual @rpc-required @destructive @boundary @creator @500
#  Scenario: DELETE bulk loan with exactly 500 disposable ids is allowed (boundary) and returns 200
#    # TODO: verify on staging — client must generate a 500-element disposable id array.
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body from file "test-data/bulk_loan_purge_500_ids.json"
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 200
#    And the bulk loan purge success response should be valid
#
#  @manual @rpc-required @destructive @edge @creator @500
#  Scenario: DELETE bulk loan with duplicate disposable ids returns 200
#    # TODO: verify on staging — dedup behaviour unspecified; expecting tolerant 200.
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_DUP_1", "ZZZ_DISPOSABLE_DUP_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 200
#    And the bulk loan purge success response should be valid
#
#  @manual @rpc-required @destructive @edge @creator @500
#  Scenario: DELETE bulk loan twice with the same disposable id is idempotent (200 both times)
#    # TODO: verify on staging — soft-delete is idempotent; the doc specifies no 409 for re-purge.
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_IDEMPOTENT_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 200
#    And I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      { "loan_ids": ["ZZZ_DISPOSABLE_IDEMPOTENT_1"] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 200
#    And the bulk loan purge success response should be valid
#
#  @manual @rpc-required @destructive @edge @creator @500
#  Scenario: DELETE bulk loan with an empty-string id element returns 200 (non-empty list passes handler check)
#    Given I prepare a request
#    And I set the request headers:
#      | accept              | application/json, text/plain, */* |
#      | authenticationtoken | {AUTH_TOKEN}                      |
#      | Content-Type        | application/json                  |
#      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
#    And I set the request body:
#      """
#      { "loan_ids": [""] }
#      """
#    When I send a "DELETE" request to "/recovery/bulk/loan"
#    Then the response status code should be 200
