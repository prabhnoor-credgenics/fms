@api @fos @clock
Feature: Clock In / Clock Out

  Background:
    Given I authenticate as "creator" slot 0 and remember as "creator0"

  @positive
  Scenario: TC-CLOCK-001 - Clock out user successfully
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      {
        "location":{
          "latitude":28.4476909,
          "longitude":77.5171228,
          "accuracy":15.72
        },
        "battery_level":35,
        "device_id":"lito",
        "app_version":"3.4.7",
        "agent_mobile":"",
        "agent_email":"sanvitestuser@gmail.com",
        "user_employee_id":"san7889",
        "agent_name":"Sanvi 2",
        "company_id":"{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be one of "200, 201"
    And the response message should be "Clock-out Successful"

  @positive
  Scenario: TC-CLOCK-002 - Verify clock status after clocking out

    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "data[0].status" as "string" with value "clocked_out"
    And the response body should contain field "data[0].clock_in_time"
    And the response body should contain field "data[0].clock_out_time"
    And the response body should contain field "data[0].clock_in_location.accuracy" as "double" with value "15.72"
    And the response body should contain field "data[0].clock_in_location.latitude" as "double" with value "28.447691"
    And the response body should contain field "data[0].clock_in_location.longitude" as "double" with value "77.51712"
    And the response body should contain field "data[0].clock_out_location.accuracy" as "double" with value "15.72"
    And the response body should contain field "data[0].clock_out_location.latitude" as "double" with value "28.447691"
    And the response body should contain field "data[0].clock_out_location.longitude" as "double" with value "77.51712"
    And the response body should contain field "data[0].clock_time"


  @positive
  Scenario: TC-CLOCK-003 - Clock in user successfully
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
      """
      {
        "location":{
          "latitude":28.4476909,
          "longitude":77.5171228,
          "accuracy":15.72
        },
        "battery_level":35,
        "device_id":"lito",
        "app_version":"3.4.7",
        "agent_mobile":"",
        "agent_email":"sanvitestuser@gmail.com",
        "user_employee_id":"san7889",
        "agent_name":"Sanvi 2",
        "company_id":"{COMPANY_ID}"
      }
      """
    When I send a "POST" request to "/fos/clock/set"
    And the response status code should be one of "201,200"
    And the response message should be "Clock-in Successful"


  @positive
  Scenario: TC-CLOCK-004 - Verify clock status after clocking in

    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be 200
    And the response message should be "success"
    And the response body should contain field "data[0].status" as "string" with value "clocked_in"
    And the response body should contain field "data[0].clock_in_time"
    And the response body should contain field "data[0].clock_out_time" as "null" with value "null"
    And the response body should contain field "data[0].clock_out_location" as "null" with value "null"
    And the response body should contain field "data[0].clock_in_location.accuracy" as "double" with value "15.72"
    And the response body should contain field "data[0].clock_in_location.latitude" as "double" with value "28.447691"
    And the response body should contain field "data[0].clock_in_location.longitude" as "double" with value "77.51712"
    And the response body should contain field "data[0].clock_time"
    And the response body should contain field "data[0].clock_in_time_epoch"

  @negative @auth
  Scenario: TC-CLOCK-005 — Clock In without authentication token
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request body:
    """
    {
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"

  Scenario: TC-AUTH-006 — Malformed UUID token returns 401
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | not-a-uuid |
    And I set the request body:
    """
    {
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"


  @negative @creator
  Scenario: TC-CLOCK-007 - Expired authentication token is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | 834c685b-eaef-46bf-be4e-1210f1dcb297 |
    And I set the request body:
    """
    {
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 401
    And the response message should be "Session expired, please login again"


  @negative
  Scenario: TC-CLOCK-008 — Clock In without company ID in params
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "location":{
        "latitude":28.4476909,
        "longitude":77.5171228,
        "accuracy":15.72
      },
      "company_id":""
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "invalid company id"

  @negative
  Scenario: TC-CLOCK-009 — Clock In without company ID in request body
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "company_id":" "
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key company_id"

  @negative @creator
  Scenario: TC-COMP-010 — Well-formed but non-existent company_id returns 422
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | 00000000-0000-0000-0000-000000000000 |
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be one of "422"
    And the response message should be "one or more companies not found"

  @negative
  Scenario: TC-CLOCK-011 — Clock In without latitude in request body
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "location":{
        "longitude":77.5171228,
        "accuracy":15.72
      },
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key location|latitude"


  @negative
  Scenario: TC-CLOCK-012 — Clock In without latitude in request body
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "location":{
        "latitude":77.5171228,
        "accuracy":15.72
      },
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key location|longitude"

  @negative @validation
  Scenario: TC-CLOCK-013 — Clock In with non-numeric string for latitude
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "location":{
        "latitude":"abc",
        "longitude":77.5171228,
        "accuracy":15.72
      },
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key location|latitude"

  @negative @validation
  Scenario: TC-CLOCK-014 — Clock In with non-numeric string for longitude
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "location":{
        "latitude":28.4476909,
        "longitude":"abc",
        "accuracy":15.72
      },
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key location|longitude"

  @negative @validation
  Scenario: TC-CLOCK-015 — Clock In with non-numeric string for battery level
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "battery_level":"abc",
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key battery_level"


  @negative
  Scenario: TC-CLOCK-016 — Clock In without request body returns 400
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400

  @negative
  Scenario: TC-CLOCK-017 — Clock In with wrong HTTP method returns 405
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    """
    When I send a "GET" request to "/fos/clock/set"
    Then the response status code should be 405

  @negative @validation
  Scenario: TC-CLOCK-018 — Clock In with device_id as object instead of string
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "device_id":{"value":"lito"},
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key device_id"

  @negative @validation
  Scenario: TC-CLOCK-019 — Clock In with app_version as integer instead of string
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "app_version":["347"],
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key app_version"

  @negative @validation
  Scenario: TC-CLOCK-020 — Clock In with agent_mobile as object instead of string
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "agent_mobile":{"number":"9876543210"},
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key agent_mobile"

  @negative @validation
  Scenario: TC-CLOCK-021 — Clock In with agent_email as object instead of string
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "agent_email":{"email":"sanvitestuser@gmail.com"},
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key agent_email"

  @negative @validation
  Scenario: TC-CLOCK-022 — Clock In with user_employee_id as integer instead of string
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "user_employee_id":["7889"],
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key user_employee_id"

  @negative @validation
  Scenario: TC-CLOCK-023 — Clock In with agent_name as object instead of string
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
    """
    {
      "agent_name":{"name":"Sanvi 2"},
      "company_id":"{COMPANY_ID}"
    }
    """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 400
    And the response message should be "Check value of key agent_name"

  @negative
  Scenario: TC-CLOCK-024 - Verify 400 in response in Clock status api without company ID in params
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be 400
    And the response message should be "invalid company id"

  @negative
  Scenario: TC-COMP-025 — Well-formed but non-existent company_id returns 422 in clock status api
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id   | 00000000-0000-0000-0000-000000000000 |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be one of "422"
    And the response message should be "one or more companies not found"

  @negative
  Scenario: TC-COMP-026 —
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "POST" request to "/fos/clock/status"
    Then the response status code should be one of "405"
    And the response message should be "Method not allowed"

  @negative @auth
  Scenario: TC-CLOCK-STATUS-027 — Clock status without authentication token
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"

  @negative @auth
  Scenario: TC-CLOCK-STATUS-028 — Clock status with malformed authentication token
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | not-a-uuid |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"

  @negative @auth
  Scenario: TC-CLOCK-STATUS-029 — Expired authentication token is rejected
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | 834c685b-eaef-46bf-be4e-1210f1dcb297 |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be 401
    And the response message should be "Session expired, please login again"

  @negative @auth
  Scenario: TC-CLOCK-STATUS-030 — Invalid UUID authentication token
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | not-a-uuid |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be 400
    And the response message should be "invalid authentication token"

  @negative @auth
  Scenario: TC-CLOCK-SET-031 — Clock In with valid company ID where user does not belong to the company
    Given I prepare a request
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    And I set the request body:
  """
  {
    "company_id":"f7c0c2cf-6b0a-4207-baad-96b80452d966"
  }
  """
    When I send a "POST" request to "/fos/clock/set"
    Then the response status code should be 403

  @negative
  Scenario: TC-CLOCK-STATUS-032 — Clock status with valid company ID where user does not belong to the company
    Given I prepare a request
    And I set the query parameters:
      | company_id | f7c0c2cf-6b0a-4207-baad-96b80452d966 |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/fos/clock/status"
    Then the response status code should be 403