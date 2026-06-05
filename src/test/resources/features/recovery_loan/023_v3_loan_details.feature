@api @v3-loan-details @recovery 
Feature: V3 Loan Details API


  @positive @smoke @creator
  Scenario: GET loan details with minimal required input (path loan_id only)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/v3_loan_details_success_schema.json"
    And the v3 loan success envelope should be valid
    And the response body should contain field "data.variable_data"

  @positive @creator
  Scenario: GET loan details returns variable_data keyed by the requested loan id
    # TODO: verify on staging — asserts the loan key is present; depends on Loan047122 existing for the org.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_levels | applicant |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan response should contain data for loan "Loan047122"

  @positive @creator
  Scenario: GET loan details with all optional parameters populated
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | source               | settlement                                                          |
      | allocation_month     | 2026-06-01                                                          |
      | attribute_levels     | applicant,guarantors,document_details,loan_variables,ds_variables   |
      | attribute_variables  | loan_amount,applicant_name                                          |
      | audit_info           | true                                                                |
      | nested_audit_info    | true                                                                |
      | id_info              | true                                                                |
      | data_type_conversion | true                                                                |
      | apply_transform      | true                                                                |
      | trigger              | ops_review                                                          |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/recovery/success/v3_loan_details_success_schema.json"
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with all boolean flags false (explicit defaults)
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | audit_info           | false |
      | nested_audit_info    | false |
      | id_info              | false |
      | data_type_conversion | false |
      | apply_transform      | false |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with calculation-function level forces data_type_conversion
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_levels | allocation_variables,allocation_statuses,allocation_details |
      | allocation_month | 2026-06-01                                                  |
      | audit_info       | true                                                        |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with nested_audit_info triggers post-processing
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | source              | calling                                              |
      | attribute_variables | applicant_name,applicant_contact_number,loan_amount  |
      | nested_audit_info   | true                                                 |
      | id_info             | true                                                 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with comma-separated attribute_variables
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_variables | applicant_name,loan_amount,applicant_contact_number |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @creator
  Scenario: GET loan details with a free-form trigger label
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | trigger | manual_refresh |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  # --- Boundary-valid allocation_month (day must be 01; month 1..12; year 20xx) ---

  @positive @boundary @creator
  Scenario Outline: GET loan details accepts boundary-valid allocation_month "<allocation_month>"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | allocation_month | <allocation_month> |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

    Examples:
      | allocation_month |
      | 2026-1-01        |
      | 2026-12-01       |
      | 2000-1-01        |

  # --- source enum: one row per documented ApiRequestSource value (case-insensitive) ---

  @positive @creator
  Scenario Outline: GET loan details accepts source "<source>"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | source | <source> |
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
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | source | <source> |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200

    Examples:
      | source     |
      | NOTICE     |
      | Frontend   |
      | SETTLEMENT |

  # --- attribute_levels enum: one row per documented LendingAttributeLevels value ---

  @positive @creator
  Scenario Outline: GET loan details accepts attribute_levels "<attribute_level>"
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
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
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_levels | applicant,co_applicants,payments,tags |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  # --- boolean flags: each flag, both true and false ---

  @positive @creator
  Scenario Outline: GET loan details accepts boolean flag <flag>=<value>
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | <flag> | <value> |
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

  # =====================================================================
  # EDGE: empty / blank CSV params coerce to null (still 200)
  # =====================================================================

  @positive @edge @creator
  Scenario: GET loan details with empty attribute_levels string coerces to null
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_levels |  |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  @positive @edge @creator
  Scenario: GET loan details with empty attribute_variables string coerces to null
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_variables |  |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200

  @positive @edge @creator
  Scenario: GET loan details with duplicate attribute_levels entries
    # TODO: verify on staging — doc is silent on dedup behaviour; expecting tolerant 200.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_levels | applicant,applicant,applicant |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200

  # =====================================================================
  # AUTH & PERMISSION
  # =====================================================================

  @negative @auth @creator
  Scenario: GET loan details without authentication token returns 401
    Given I prepare a request
    And I set the request headers:
      | accept | application/json, text/plain, */* |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Session expired, please login again"

  @negative @auth @creator
  Scenario: GET loan details with an invalid authentication token returns 401
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | invalid_token_12345              |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 401
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Session expired, please login again"

  @negative @auth @creator
  Scenario: GET loan details with a malformed UUID-style token returns 401
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {UUID}                           |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 401

  # NOTE: the {UUID} above is sent literally (query/header placeholders are not resolved by the
  # framework); it still serves as a syntactically-different invalid token.

  @positive @approver
  Scenario: GET loan details succeeds for a non-creator role (no permission submodule on this route)
    # This route declares NO permission submodules, so role does not gate access.
    # "valid token but wrong role -> 403" is NOT reachable here; an authenticated approver gets 200.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200

  # N/A — "Missing company_id -> 403": company_id is derived server-side from the auth token via
  #       @verify_organisation; callers cannot pass it, so this condition is not reachable here.
  # N/A — "Wrong company_id for the resource -> 403/404": same reason; see the non-existent-loan
  #       scenario below for the closest reachable behaviour.

  # =====================================================================
  # PATH loan_id VALIDATION (the only "required field" on this endpoint)
  # =====================================================================

  @negative @creator
  Scenario: GET loan details with loan_id "undefined" is rejected by validity check
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | undefined |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/invalid_schema.json"
    And the response body should contain field "message" with value "Invalid loan id provided"

  @negative @creator
  Scenario: GET loan details with loan_id "null" is rejected by validity check
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | null |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response body should contain field "message" with value "Invalid loan id provided"

  @negative @creator
  Scenario Outline: GET loan details with forbidden character in loan_id "<loan_id>" returns INVALID_IDS
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | <loan_id> |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/v3_loan_details_error_schema.json"
    And the v3 loan error code should be "REC_0007"

    Examples:
      | loan_id   |
      | loan~123  |
      | loan;123  |
      | loan'123  |

  @negative @creator
  Scenario Outline: GET loan details with forbidden character in loan_id "<loan_id>" (encoding-sensitive)
    # TODO: verify on staging — these characters may be URL-encoded by the client before reaching
    #       the server's [{}%';~] check; confirm the 400/REC_0007 still triggers.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | <loan_id> |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the v3 loan error code should be "REC_0007"

    Examples:
      | loan_id  |
      | loan%123 |
      | loan}123 |

  # =====================================================================
  # QUERY PARAM VALIDATION (serializer -> 400 REC_0003)
  # =====================================================================

  @negative @creator
  Scenario: GET loan details with an invalid source value returns validation error
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | source | not_a_real_source |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/v3_loan_details_error_schema.json"
    And the v3 loan error code should be "REC_0003"

  @negative @creator
  Scenario Outline: GET loan details with invalid attribute_levels "<attribute_levels>" returns validation error
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_levels | <attribute_levels> |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/v3_loan_details_error_schema.json"
    And the v3 loan error code should be "REC_0003"

    Examples:
      | attribute_levels    |
      | foobar              |
      | applicant,foobar    |
      | APPLICANT_NOT_REAL  |

  @negative @creator
  Scenario Outline: GET loan details with badly-formatted allocation_month "<allocation_month>" returns validation error
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | allocation_month | <allocation_month> |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the response should match json schema "schemas/recovery/error/v3_loan_details_error_schema.json"
    And the v3 loan error code should be "REC_0003"

    Examples:
      | allocation_month | # reason                          |
      | 01-12-2026       | # DD-MM-YYYY instead of YYYY-M-01  |
      | 2026-12-15       | # day must be 01                  |
      | 2026-13-01       | # month out of range              |
      | 1999-12-01       | # year not 20xx                   |
      | notadate         | # non-date string                 |
      | 2026/12/01       | # wrong separators                |

  # =====================================================================
  # FIELD TYPE / FORMAT VALIDATION
  # =====================================================================

  @negative @creator
  Scenario Outline: GET loan details with non-boolean flag value <flag>=<value> returns validation error
    # TODO: verify on staging — pydantic bool coercion is permissive (true/false/1/0/yes/no/on/off);
    #       these clearly-invalid tokens are expected to fail validation with REC_0003.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | <flag> | <value> |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 400
    And the v3 loan error code should be "REC_0003"

    Examples:
      | flag                 | value |
      | audit_info           | maybe |
      | data_type_conversion | abcd  |
      | id_info              | 7     |

  # N/A — "String field receives integer / numeric receives string / UUID / email / mobile -> 400":
  #       this endpoint has no UUID, email, mobile, numeric, or strict-typed body fields. Its only
  #       typed inputs are the enum (source / attribute_levels), the date-regex (allocation_month),
  #       and the booleans — all covered above. No further type/format cases are reachable.

  # =====================================================================
  # BOUNDARY / EDGE — loan_id length & fuzz (path param resolves placeholders)
  # =====================================================================

  @negative @boundary @creator
  Scenario: GET loan details with a very long random loan_id
    # TODO: verify on staging — no documented max length for loan_id; behaviour (200 empty vs error)
    #       is unconfirmed. Asserting 200 as the most likely "valid format, not found" outcome.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {RANDOM_STRING:200} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200

  @negative @boundary @creator
  Scenario: GET loan details with a single-character loan_id
    # TODO: verify on staging — boundary-minimum id; expected valid-format 200 (empty variable_data).
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | x |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200

  # =====================================================================
  # BUSINESS LOGIC / DOMAIN RULES
  # =====================================================================

  @negative @creator
  Scenario: GET loan details for a valid-format but non-existent loan id
    # TODO: verify on staging — doc does not specify 404 for unknown loan; the service returns a
    #       success envelope with empty/absent variable_data. Asserting 200 accordingly.
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | {UUID} |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  # N/A — "version not v3 -> 404 (REC_0000)": the route hard-codes defaults={"version":"v3"};
  #       there is no path/param to send a different version, so this branch is not reachable here.
  # N/A — "company is not of type LOAN -> 400 (REC_0008)": requires authenticating as a credit-line
  #       company; the configured automation org is a LOAN company. TODO: verify on staging with a
  #       credit-line token if/when available.
  # N/A — "Idempotency: duplicate create -> 409" and "state-transition (e.g. closed loan) -> 409":
  #       this endpoint is a read-only GET with no create/update/state machine. Not applicable.
  # TODO: verify on staging — "soft-deleted / inactive loan access": behaviour unconfirmed; would
  #       need a known soft-deleted loan id on staging.

  # =====================================================================
  # MULTI-STEP / DEPENDENT (read-only variants; no create/delete on this endpoint)
  # =====================================================================

  @positive @multistep @creator
  Scenario: GET full attribute set then GET a narrowed variable both succeed
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_levels | applicant,co_applicants,references |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid
    And I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    And I set the query parameters:
      | attribute_variables | applicant_name |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the v3 loan success envelope should be valid

  # =====================================================================
  # PERFORMANCE
  # =====================================================================

  @positive @performance @creator
  Scenario: GET loan details responds within the time threshold
    Given I prepare a request
    And I set the request headers:
      | accept              | application/json, text/plain, */* |
      | authenticationtoken | {AUTH_TOKEN}                      |
    And I set the path parameters:
      | loan_id | Loan047122 |
    When I send a "GET" request to "/recovery/v3/loans/{loan_id}"
    Then the response status code should be 200
    And the response time should be less than 5000 milliseconds
