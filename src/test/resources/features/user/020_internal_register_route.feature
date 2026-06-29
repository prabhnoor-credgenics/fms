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
    And the internal register route success response should be valid

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
    And the internal register route success response should be valid


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
    And the internal register route failure response should be valid

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
    And the internal register route failure response should be valid

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
    And the internal register route failure response should be valid

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
    And the internal register route failure response should be valid

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
    And the internal register route failure response should be valid

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
    And the internal register route failure response should be valid
