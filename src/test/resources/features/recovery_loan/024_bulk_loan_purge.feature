@api @bulk-loan-purge @recovery
Feature: Bulk Loan Purge API (data_purging)
  # DELETE {BASE_ROUTE}/bulk/loan  -> soft-deletes loan/customer data across 9 tables.
  # Source: app/routes/data_routes.py:196 (endpoint data_purging). Body: { "loan_ids": [<str>...] }.
  #
  # ⚠️ DESTRUCTIVE + RPC-GATED. Documented decorator order:
  #   @login_required -> @verify_organisation -> @validate_rpc -> @validate_request(DataPurgingModel)
  #
  # OBSERVED ON STAGING (automation user, public host api.staging.credgenics.com):
  #   * No / invalid auth token            -> 401 "Session expired, please login again". [VERIFIED]
  #   * Authenticated (valid token, with or without x-company-id, any RPC key, any body)
  #                                        -> 400 "invalid company id". [VERIFIED]
  #     i.e. @verify_organisation rejects this internal route for the automation user BEFORE the RPC
  #     gate, body validation, or purge are ever reached. The same company id (3e561a13) that works
  #     on other recovery routes is rejected here — this route is internal/RPC-only and the
  #     automation org is not authorised for it.ch
  #
  # NOT REACHABLE for the automation user (documented per the source, tagged @manual + # TODO):
  #   * RPC gate           -> 403 "you have insufficient access rights" (needs an org authorised for
  #                           this route so verify_organisation passes first).
  #   * Body validation    -> 400 (missing/empty/typed loan_ids) — needs a valid org AND the RPC secret.
  #   * Successful purge   -> 200, REAL DATA SOFT-DELETED — needs valid org + RPC secret.
  #
  # @manual scenarios need the RPC secret wired in (header value {RPC_SECRET_KEY}; header placeholders
  # are NOT auto-resolved by the framework). All purge bodies use disposable, non-existent ids so a
  # real 200 matches zero rows and cannot delete a real loan.

  # =====================================================================
  # EXECUTABLE NOW — AUTH (401). Reachable without the RPC secret.
  # =====================================================================

  @negative @auth @creator @flaky
  Scenario: DELETE bulk loan without authentication token returns 401
    Given I prepare a request
    And I set the request headers:
      | accept       | application/json, text/plain, */* |
      | Content-Type | application/json                  |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Session expired, please login again"

  @negative @auth @creator @flaky
  Scenario: DELETE bulk loan with an invalid authentication token returns 401
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345               |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Session expired, please login again"

  # =====================================================================
  # EXECUTABLE NOW — ORG RESOLUTION (400 "invalid company id"). [VERIFIED on staging]
  # For the automation user, @verify_organisation rejects this internal route before the RPC gate,
  # body validation, or purge. This holds for valid/wrong/absent RPC keys and for valid/bad bodies
  # alike — proving org resolution precedes all of them. None of these can purge data.
  # =====================================================================

  @negative @org @creator
  Scenario: DELETE bulk loan with a valid body is rejected at org resolution (400 invalid company id)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "invalid company id"

  @negative @org @creator
  Scenario: DELETE bulk loan with a wrong RPC secret is still rejected at org resolution (400)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | wrong-rpc-secret-key             |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid company id"

  @negative @org @approver
  Scenario: DELETE bulk loan as approver is rejected at org resolution (400 invalid company id)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid company id"

  @negative @org @creator
  Scenario Outline: DELETE bulk loan is rejected at org resolution regardless of body "<description>"
    # Org resolution precedes body validation: each body below would otherwise be a 400 body error,
    # but for the automation user they all return 400 "invalid company id" first.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      <body>
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message" with value "invalid company id"

    Examples:
      | description           | body                          |
      | empty object          | {}                            |
      | empty loan_ids list   | { "loan_ids": [] }            |
      | loan_ids as string    | { "loan_ids": "not-a-list" }  |
      | missing loan_ids key  | { "other": 1 }                |

  # @manual — the documented RPC gate (403). Needs an account whose org is authorised for this
  # internal route so @verify_organisation passes first. # TODO: verify on staging.
  @manual @rpc-required @negative @rpc @creator
  Scenario: DELETE bulk loan with missing RPC secret returns 403 (requires org authorised for route)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_DO_NOT_EXIST_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 403
    And the bulk loan purge forbidden response should be valid

  # =====================================================================
  # @manual @rpc-required — BODY VALIDATION MATRIX (400).
  # Requires a valid Rpc_Secret_Key (replace {RPC_SECRET_KEY} with the real secret, or wire a
  # resolver for it). Header placeholders are NOT auto-resolved by the framework.
  # TODO: verify on staging — all scenarios below need the RPC secret to reach body validation.
  # =====================================================================

  @manual @rpc-required @negative @creator
  Scenario: DELETE bulk loan with missing loan_ids key returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      {}
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message"

  @manual @rpc-required @negative @creator
  Scenario: DELETE bulk loan with an empty request body returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message" with value "Empty request body"

  @manual @rpc-required @negative @creator
  Scenario: DELETE bulk loan with loan_ids present but null returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": null }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message"

  @manual @rpc-required @negative @creator
  Scenario: DELETE bulk loan with an empty loan_ids list returns 400 (handler-level)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": [] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message" with value "No loan id provided"

  @manual @rpc-required @negative @creator
  Scenario Outline: DELETE bulk loan with wrong-typed loan_ids "<description>" returns 400
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      <body>
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message"

    Examples:
      | description              | body                              |
      | loan_ids as string       | { "loan_ids": "uloan124" }        |
      | loan_ids as integer      | { "loan_ids": 123 }               |
      | loan_ids as object       | { "loan_ids": {} }                |
      | loan_ids as boolean      | { "loan_ids": true }              |
      | element is an integer    | { "loan_ids": [123] }             |
      | element is null          | { "loan_ids": [null] }            |
      | element is a boolean     | { "loan_ids": [true] }            |
      | element is an object     | { "loan_ids": [{}] }              |
      | element is a nested list | { "loan_ids": [["x"]] }           |

  @manual @rpc-required @negative @boundary @creator
  Scenario: DELETE bulk loan with 501 loan_ids exceeds the max limit and returns 400
    # TODO: verify on staging — the client must generate a 501-element loan_ids array (use disposable
    #       non-existent ids). Inline representation omitted; expected message below.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body from file "test-data/bulk_loan_purge_501_ids.json"
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 400
    And the response body should contain field "message" with value "loan_ids length exceeds max allowed limit of 500"

  # =====================================================================
  # @manual @rpc-required @destructive — SUCCESS / HAPPY PATH (200).
  # ⚠️ Soft-deletes data. All ids below are disposable & non-existent: a 200 matches 0 rows and
  # deletes nothing real. Replace with your own throwaway ids only if they are safe to purge.
  # TODO: verify on staging — needs the RPC secret; confirms the 200 envelope.
  # =====================================================================

  @manual @rpc-required @destructive @positive @creator
  Scenario: DELETE bulk loan with a single disposable id returns 200 (minimal required field)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_{RANDOM_STRING:12}"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/bulk_loan_purge_success_schema.json"
    And the bulk loan purge success response should be valid

  @manual @rpc-required @destructive @positive @creator
  Scenario: DELETE bulk loan with multiple disposable ids returns 200
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_{RANDOM_STRING:10}", "ZZZ_DISPOSABLE_{RANDOM_STRING:10}", "ZZZ_DISPOSABLE_{RANDOM_STRING:10}"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 200
    And the bulk loan purge success response should be valid

  @manual @rpc-required @destructive @positive @creator
  Scenario: DELETE bulk loan for a valid-format but non-existent id returns 200 (no 404 for unknown id)
    # TODO: verify on staging — doc specifies no 404; purge of an unknown id is a no-op 200.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": ["{UUID}"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 200
    And the bulk loan purge success response should be valid

  @manual @rpc-required @destructive @boundary @creator
  Scenario: DELETE bulk loan with exactly 500 disposable ids is allowed (boundary) and returns 200
    # TODO: verify on staging — client must generate a 500-element disposable id array.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body from file "test-data/bulk_loan_purge_500_ids.json"
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 200
    And the bulk loan purge success response should be valid

  @manual @rpc-required @destructive @edge @creator
  Scenario: DELETE bulk loan with duplicate disposable ids returns 200
    # TODO: verify on staging — dedup behaviour unspecified; expecting tolerant 200.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_DUP_1", "ZZZ_DISPOSABLE_DUP_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 200
    And the bulk loan purge success response should be valid

  @manual @rpc-required @destructive @edge @creator
  Scenario: DELETE bulk loan twice with the same disposable id is idempotent (200 both times)
    # TODO: verify on staging — soft-delete is idempotent; the doc specifies no 409 for re-purge.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_IDEMPOTENT_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 200
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": ["ZZZ_DISPOSABLE_IDEMPOTENT_1"] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 200
    And the bulk loan purge success response should be valid

  @manual @rpc-required @destructive @edge @creator
  Scenario: DELETE bulk loan with an empty-string id element returns 200 (non-empty list passes handler check)
    # TODO: verify on staging — [""] is a truthy list so it passes the "No loan id provided" check;
    #       the empty-string id matches no rows.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
      | x-company-id        | {COMPANY_ID}                     |
      | Content-Type        | application/json                  |
      | Rpc_Secret_Key      | {RPC_SECRET_KEY}                 |
    And I set the request body:
      """
      { "loan_ids": [""] }
      """
    When I send a "DELETE" request to "/recovery/bulk/loan"
    Then the response status code should be 200

  # =====================================================================
  # NOT APPLICABLE (documented; not reachable on this endpoint)
  # =====================================================================
  # N/A — "All optional fields populated" / "field type matrix beyond loan_ids": the body has a
  #       single field (loan_ids: list[str]); there are no optional, enum, boolean, date, email,
  #       mobile, or UUID fields to vary. The type matrix above fully covers loan_ids.
  # N/A — "Valid token but wrong role -> 403 (role-based)": no permission submodule on this route;
  #       the 403 here is the RPC gate, not RBAC. The @approver scenario above confirms role is
  #       irrelevant to access.
  # N/A — "Missing company_id -> 403" and "Wrong company_id for the resource -> 403/404": company_id
  #       is derived server-side from the auth token via @verify_organisation; callers cannot pass it.
  # N/A — "Create -> read back" / "Create -> update -> read back" / "Create -> delete -> read back":
  #       this endpoint only purges; there is no create/read/update verb and no read-back of purge
  #       state via this API, so these multi-step flows cannot be expressed against this route.
  # N/A — "Soft-deleted resource access -> 404/400": re-purging an already-purged id is a no-op 200
  #       (covered by the idempotency scenario), not a 404; there is no GET on this route to read it.
  # TODO: verify on staging — "Wrong HTTP method (e.g. GET /bulk/loan) -> 404 requested route not
  #       found": method/route mapping is unconfirmed (could be 404 or 405); not asserted here.
