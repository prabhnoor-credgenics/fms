@demo @sample @fms
Feature: Sample Template file to test FMS Login
  # Secure FMS login (mirrors the creator pattern:
  #   Given I authenticate as "creator" slot 0 and remember as "creator0").
  # Resolves user_id via POST /fixmyscore-user-service/auth/register using
  # env-scoped secrets from src/main/resources/secrets/crypto.properties
  # (stag_fms_api_key, stag_fms_mobile, stag_fms_imei, ...). No secrets in this file.
  Background:
    Given I authorize as FMS user and remember as "fms0"

  @positive
  Scenario: TC-001 - Meta request
    Given I prepare a request
    And I set the query parameters:
    | version | 6.5.0 |
    When I send a "GET" request to "/fixmyscore-user-service/public/app/meta/android"
    Then the response status code should be 200
    And the response should match json schema "schemas/FMS/success/meta.json"
    And the response body should contain field "message" as "string" with value "ANDROID meta information sent successfully"

  @positive
  Scenario: TC-002 - Check user exists
    Given I prepare a request
    And I set the request headers:
    | user_id     | {FMS_USER_ID}     |
    | token-v2    | {FMS_TOKEN_V2}    |
    | app_version | {FMS_APP_VERSION} |
    | imei        | {FMS_IMEI}        |
    | x-api-key   | {FMS_API_KEY}     |
    And I set the request body:
    """
    {
      "user_id" : "{FMS_USER_ID}",
      "service_name" : "all"
    }
    """
    When I send a "POST" request to "/fixmyscore-user-service/auth/v2/registry_map"
    Then the response status code should be 200
    And the response body should contain field "success" as "bool" with value "true"
