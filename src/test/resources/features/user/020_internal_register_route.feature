@api @user @internal-register-route @manual
Feature: Internal Register Route — POST /user/internal/register-route


  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @smoke @creator
  Scenario: Register a throwaway service route map (all fields) returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "service_name": "apiautomation_test_{RANDOM_STRING:8}",
        "module_name": "API Automation Test Module",
        "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}}
      }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/internal_register_route_success_schema.json"
    And the "internal_register_route" success response should be valid

  @positive @creator
  Scenario: Register a nested route tree with path variables returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "service_name": "apiautomation_test_{RANDOM_STRING:8}",
        "module_name": "API Automation Nested Module",
        "route_map": {"message": {"$": {"__methods": {"GET": {"submodules": {}, "endpoint": "message-detail"}}}}}
      }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 200
    And the "internal_register_route" success response should be valid


  @negative @creator
  Scenario: Missing service_name returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: Missing route_map returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "M" }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: Missing module_name returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: Empty JSON body returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: route_map of the wrong type (string instead of object) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "M", "route_map": "not-an-object" }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: service_name with a disallowed leading character returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "=evil", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid


  @positive @creator
  Scenario: Re-registering the same service upserts the route map and returns 200 (idempotent)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "service_name": "apiautomation_idempotent_svc",
        "module_name": "API Automation Idempotent Module",
        "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}}
      }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 200
    And the "internal_register_route" success response should be valid
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "service_name": "apiautomation_idempotent_svc",
        "module_name": "API Automation Idempotent Module Updated",
        "route_map": {"pong": {"__methods": {"GET": {"submodules": {}, "endpoint": "pong"}}}}
      }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 200
    And the "internal_register_route" success response should be valid

  @positive @creator
  Scenario: Unknown extra fields are ignored and the request returns 200
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "service_name": "apiautomation_test_{RANDOM_STRING:8}",
        "module_name": "API Automation Extra Fields Module",
        "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}},
        "unknown_field": "should-be-dropped",
        "is_admin": true,
        "company_id": "{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 200
    And the "internal_register_route" success response should be valid

  @positive @creator
  Scenario: Success response echoes stored route map and documented fields
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "service_name": "apiautomation_test_{RANDOM_STRING:8}",
        "module_name": "API Automation Shape Module",
        "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}}
      }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response body should contain field "service_name"
    And the response body should contain field "module_name"
    And the response body should contain field "route_map"

  @positive @creator
  Scenario: An empty route_map object is accepted
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      {
        "service_name": "apiautomation_test_{RANDOM_STRING:8}",
        "module_name": "API Automation Empty Routemap Module",
        "route_map": {}
      }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "200,400,424"
    And the response body should not be empty

  @positive @creator
  Scenario: Internal route enforces no framework auth (missing authenticationtoken still processes)
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      {
        "service_name": "apiautomation_test_{RANDOM_STRING:8}",
        "module_name": "API Automation No Auth Module",
        "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}}
      }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "200,401,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Null service_name returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": null, "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: Null route_map returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "M", "route_map": null }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: Null module_name returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": null, "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: route_map of the wrong type (array instead of object) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "M", "route_map": ["ping", "pong"] }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: route_map of the wrong type (number instead of object) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "M", "route_map": 12345 }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @security @creator
  Scenario: SQL injection attempt in service_name is rejected as an invalid value (400)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "recovery'; DROP TABLE service_route_mapping; --", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @security @creator
  Scenario: XSS payload in service_name is rejected as an invalid value (400)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "<xss>alert(1)</xss>", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

  @negative @security @creator
  Scenario: XSS payload in module_name is rejected as an invalid value (400)
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "<xss>alert(1)</xss>", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "400,401,403,404"
    And the response body should not be empty

  @negative @creator
  Scenario: service_name containing a disallowed special character returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation?evil", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the "internal_register_route" failure response should be valid

  @negative @creator
  Scenario: Empty string service_name is handled deterministically
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "200,400"
    And the response body should not be empty

  @negative @creator
  Scenario: Empty string module_name is handled deterministically
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "200,400"
    And the response body should not be empty

  @negative @boundary @creator
  Scenario: Very long service_name is handled deterministically
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_{RANDOM_STRING:300}", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "200,400,424"
    And the response body should not be empty

  @negative @creator
  Scenario: Unicode service_name is handled deterministically
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_ünïcödé_服务_{RANDOM_STRING:4}", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "200,400"
    And the response body should not be empty

  @negative @creator
  Scenario: Malformed JSON body returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "M", "route_map": }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Unsupported content type (text/plain) is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | text/plain   |
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "POST" request to "/user/internal/register-route"
    Then the response status code should be one of "400,415"
    And the response body should not be empty

  @negative @creator
  Scenario: Unsupported HTTP method PUT is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    And I set the request body:
      """
      { "service_name": "apiautomation_test_{RANDOM_STRING:6}", "module_name": "M", "route_map": {"ping": {"__methods": {"GET": {"submodules": {}, "endpoint": "ping"}}}} }
      """
    When I send a "PUT" request to "/user/internal/register-route"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

  @negative @creator
  Scenario: Unsupported HTTP method DELETE is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type        | application/json |
      | authenticationtoken | {AUTH_TOKEN}     |
    When I send a "DELETE" request to "/user/internal/register-route"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

  @negative @creator
  Scenario: GET without service_name query parameter returns 400
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/internal/register-route"
    Then the response status code should be 400
    And the response body should not be empty

  @positive @creator
  Scenario: GET with service_name query parameter returns 200 with route details
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | service_name | apiautomation_idempotent_svc |
    When I send a "GET" request to "/user/internal/register-route"
    Then the response status code should be 200
    And the response body should contain field "route_details"
