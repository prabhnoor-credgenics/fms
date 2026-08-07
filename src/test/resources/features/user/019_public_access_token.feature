@api @user @public-access-token
Feature: Public Access Token — POST /user/public/access-token

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @creator
  Scenario: Valid client credentials mint an API key
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}", "token_expiry_duration": 3600 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/public_access_token_success_schema.json"
    And the "public_access_token" success response should be valid

  @negative @creator
  Scenario: Unknown client_id is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "unknownclient{RANDOM_STRING:6}", "client_secret": "nope-secret-{RANDOM_STRING:6}" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @negative @creator
  Scenario: Missing client_id returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_secret": "some-secret" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @negative @creator
  Scenario: Missing client_secret returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "someclientid1234" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @negative @creator
  Scenario: Empty JSON body returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      {}
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @negative @boundary @creator
  Scenario: token_expiry_duration over 24 hours (86400s) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "someclientid1234", "client_secret": "some-secret", "token_expiry_duration": 100000 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @negative @boundary @creator
  Scenario: token_expiry_duration of zero (non-positive) returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "someclientid1234", "client_secret": "some-secret", "token_expiry_duration": 0 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @negative @creator
  Scenario: token_expiry_duration as a non-integer string returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "someclientid1234", "client_secret": "some-secret", "token_expiry_duration": "abc" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid


  @negative @creator
  Scenario: Valid client_id with a wrong client_secret is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "wrong-secret-{RANDOM_STRING:10}" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @positive @boundary @creator
  Scenario: token_expiry_duration at the minimum (1 second) mints a key
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}", "token_expiry_duration": 1 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/public_access_token_success_schema.json"
    And the "public_access_token" success response should be valid

  @positive @boundary @creator
  Scenario: token_expiry_duration at the maximum (86400 seconds / 24h) mints a key
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}", "token_expiry_duration": 86400 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/public_access_token_success_schema.json"
    And the "public_access_token" success response should be valid

  @negative @boundary @creator
  Scenario: Negative token_expiry_duration returns 400
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "someclientid1234", "client_secret": "some-secret", "token_expiry_duration": -1 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @positive @creator
  Scenario: Omitted token_expiry_duration defaults to 900 seconds and mints a key
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/public_access_token_success_schema.json"
    And the "public_access_token" success response should be valid

  @negative @boundary @creator
  Scenario: token_expiry_duration as a float is coerced or rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}", "token_expiry_duration": 3600.5 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be one of "200,400"

  @positive @creator
  Scenario: Unknown extra fields are ignored and a key is still minted
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}", "token_expiry_duration": 3600, "unexpected_field": "junk-{RANDOM_STRING:6}", "scope": "all" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 200
    And the "public_access_token" success response should be valid

  @negative @creator
  Scenario: GET is not supported on the access-token endpoint
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    When I send a "GET" request to "/user/public/access-token"
    Then the response status code should be one of "404,405"

  @negative @creator
  Scenario: PUT is not supported on the access-token endpoint
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}" }
      """
    When I send a "PUT" request to "/user/public/access-token"
    Then the response status code should be one of "404,405"

  @negative @creator
  Scenario: DELETE is not supported on the access-token endpoint
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    When I send a "DELETE" request to "/user/public/access-token"
    Then the response status code should be one of "404,405"

  @negative @creator
  Scenario: Malformed JSON body is rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}",
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be one of "400,500"

  @negative @creator
  Scenario: Non-JSON Content-Type with a JSON body (force_json parsing)
    Given I prepare a request
    And I set the request headers:
      | Content-Type | text/plain |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}", "token_expiry_duration": 3600 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be one of "200,400"

  @negative @security @creator
  Scenario: SQL injection in client_id is treated as an unknown client
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "' OR '1'='1", "client_secret": "anything-{RANDOM_STRING:6}" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @negative @boundary @creator
  Scenario: Excessively long client_id and client_secret are rejected
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{RANDOM_STRING:300}", "client_secret": "{RANDOM_STRING:300}" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the "public_access_token" failure response should be valid

  @positive @creator
  Scenario: Successful mint returns the expected response shape
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "{CLIENT_ID}", "client_secret": "{CLIENT_SECRET}", "token_expiry_duration": 3600 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 200
    And the response body should contain field "data.api_key"
    And the response body should contain field "data.client_id"
    And the response body should contain field "data.expiry"
    And the response body should contain field "data.company_details"
    And the response body should contain field "message" as "auto" with value "API Key generated successfully"
