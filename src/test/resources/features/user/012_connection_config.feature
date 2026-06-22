@api @user @connection-config
Feature: Connection Configuration — GET /user/connection-config/<connection_id>



  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"


  @500 @positive @smoke @creator
  Scenario: SFTP config by id returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the response should match json schema "schemas/user/success/connection_config_success_schema.json"
    And the connection config success response should be valid

  @500 @positive @creator
  Scenario: S3 config by id returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | s3           |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the connection config success response should be valid

  @500 @positive @creator
  Scenario: SFTP config by id with decrypted secrets returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id                          | {COMPANY_ID} |
      | connection_type                     | sftp         |
      | is_encrypted_configuration_required | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the connection config success response should be valid

  @500 @positive @creator
  Scenario: SFTP config by id without secrets returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id                          | {COMPANY_ID} |
      | connection_type                     | sftp         |
      | is_encrypted_configuration_required | false        |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the connection config success response should be valid

  @500 @positive @creator
  Scenario: Collection form (no connection_id) — all SFTP configs returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 200
    And the connection config success response should be valid

  @500 @positive @creator
  Scenario: Collection form (no connection_id) — all S3 configs returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | s3           |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 200
    And the connection config success response should be valid


  @500 @negative @creator
  Scenario: Missing connection_type returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 400
    And the connection config failure response should be valid

  @500 @negative @creator
  Scenario: Invalid connection_type returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | ftp          |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 400
    And the connection config failure response should be valid


  @negative @creator
  Scenario: Missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid authenticationtoken is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | invalid-token-xyz |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Missing company_id query param is rejected
    Given I prepare a request
    And I set the query parameters:
      | connection_type | sftp |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 403
    And the response body should not be empty
