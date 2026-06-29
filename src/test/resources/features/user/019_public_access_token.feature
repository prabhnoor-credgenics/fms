@api @user @public-access-token
Feature: Public Access Token — POST /user/public/access-token

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @positive @manual @creator
  Scenario: Valid client credentials mint an API key (needs real client_id/client_secret)
    # TODO: verify on staging with real client_access_id_details credentials — expects 200 with data.api_key.
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "<real_client_id>", "client_secret": "<real_client_secret>", "token_expiry_duration": 3600 }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/public_access_token_success_schema.json"
    And the public access token success response should be valid

  @negative @creator
  Scenario: Unknown client_id is rejected
    # TODO: verify on staging — retrieve_client_id_details may surface as 400 or 404 for an unknown client.
    Given I prepare a request
    And I set the request headers:
      | Content-Type | application/json |
    And I set the request body:
      """
      { "client_id": "unknownclient{RANDOM_STRING:6}", "client_secret": "nope-secret-{RANDOM_STRING:6}" }
      """
    When I send a "POST" request to "/user/public/access-token"
    Then the response status code should be 400
    And the public access token failure response should be valid

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
    And the public access token failure response should be valid

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
    And the public access token failure response should be valid

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
    And the public access token failure response should be valid

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
    And the public access token failure response should be valid

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
    And the public access token failure response should be valid

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
    And the public access token failure response should be valid
