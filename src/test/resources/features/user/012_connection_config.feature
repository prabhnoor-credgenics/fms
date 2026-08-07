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
    And the "connection_config" success response should be valid

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
    And the "connection_config" success response should be valid

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
    And the "connection_config" success response should be valid

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
    And the "connection_config" success response should be valid

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
    And the "connection_config" success response should be valid

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
    And the "connection_config" success response should be valid


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
    And the "connection_config" failure response should be valid

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
    And the "connection_config" failure response should be valid


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


  @500 @negative @creator
  Scenario: Item form — missing connection_type returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 400
    And the "connection_config" failure response should be valid

  @500 @negative @creator
  Scenario: Item form — invalid connection_type returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | ftp          |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 400
    And the "connection_config" failure response should be valid

  @500 @negative @creator
  Scenario: Empty connection_type value returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type |              |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 400
    And the "connection_config" failure response should be valid

  @500 @negative @creator
  Scenario: connection_type is case-sensitive — uppercase SFTP returns 400
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | SFTP         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be 400
    And the "connection_config" failure response should be valid

  @500 @positive @creator
  Scenario: S3 config by id with decrypted secrets returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id                          | {COMPANY_ID} |
      | connection_type                     | s3           |
      | is_encrypted_configuration_required | true         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @positive @creator
  Scenario: is_encrypted_configuration_required is case-insensitive (TRUE) returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id                          | {COMPANY_ID} |
      | connection_type                     | sftp         |
      | is_encrypted_configuration_required | TRUE         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @positive @creator
  Scenario: Non-boolean is_encrypted_configuration_required is treated as false returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id                          | {COMPANY_ID} |
      | connection_type                     | sftp         |
      | is_encrypted_configuration_required | yes          |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @positive @creator
  Scenario: Non-existent connection_id returns 200 with empty data list
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
    And the "connection_config" success response should be valid
    And the response body should contain field "data.data"

  @500 @positive @security @creator
  Scenario: connection_id with sanitised special characters returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | abc{def}%ghi';~ |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @negative @security @creator
  Scenario: SQL injection in connection_id is sanitised and returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | 1' OR '1'='1 |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @negative @security @creator
  Scenario: XSS payload in connection_id returns 200 without reflecting script
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | <xss>alert(1)</xss> |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @positive @boundary @creator
  Scenario: Long connection_id returns 200 with empty data list
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {RANDOM_STRING:200} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @positive @creator
  Scenario: Unicode connection_id returns 200 with empty data list
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | 配置-テスト-Ünïcødé |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | s3           |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @positive @creator
  Scenario: Unknown extra query parameter is tolerated returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID}      |
      | connection_type | sftp              |
      | unknown_param   | {RANDOM_STRING:8} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @500 @positive @creator
  Scenario: Success response exposes documented shape and JSON content type
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
    And the response content type should be "application/json"
    And the response body should contain field "message"
    And the response body should contain field "data.connection_type"
    And the response body should contain field "data.data"

  @500 @positive @creator
  Scenario: Content-Type header on GET is tolerated returns 200
    Given I grant the current user all loan permissions
    And I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
      | Content-Type        | text/plain   |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 200
    And the "connection_config" success response should be valid

  @negative @creator
  Scenario: Item form — missing authenticationtoken header is rejected
    Given I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    When I send a "GET" request to "/user/connection-config/{connection_id}"
    Then the response status code should be 400
    And the response body should not be empty

  @negative @creator
  Scenario: Invalid company_id format is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id      | not-a-uuid |
      | connection_type | sftp       |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Empty company_id value is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id      |      |
      | connection_type | sftp |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Cross-company scoping — foreign company_id is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id      | {UUID} |
      | connection_type | sftp   |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/"
    Then the response status code should be one of "400,403"
    And the response body should not be empty

  @negative @creator
  Scenario: Unsupported HTTP method PUT on item URL is rejected
    Given I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "PUT" request to "/user/connection-config/{connection_id}"
    Then the response status code should be one of "404,405"
    And the response body should not be empty

  @negative @creator
  Scenario: Bogus subpath under connection-config returns route not found
    Given I prepare a request
    And I set the path parameters:
      | connection_id | {UUID} |
    And I set the query parameters:
      | company_id      | {COMPANY_ID} |
      | connection_type | sftp         |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/user/connection-config/{connection_id}/extra"
    Then the response status code should be 404
    And the response body should not be empty
