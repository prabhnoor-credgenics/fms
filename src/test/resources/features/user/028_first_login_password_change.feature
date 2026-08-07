@api @user @first-login @change-password
Feature: First-login password set by chief admin — create user + PATCH /user/change-password + login


  Background:
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"

  @positive @smoke @first-login
  Scenario: Chief admin creates a user, sets its password, then that user logs in for the first time
    When I create a global user with a random email
    And I set the created user's password to "User@123" using the chief admin token
    And I log in as the created user with password "User@123"
    Then the response status code should be 200
    And the "public_login" success response should be valid


  @positive @first-login @change-password
  Scenario: Change-password returns the documented success message and status
    When I create a global user with a random email
    And I set the created user's password to "User@123" using the chief admin token
    Then the response status code should be 200
    And the response body should contain field "message" as "auto" with value "Password successfully updated"

  @positive @first-login @boundary
  Scenario: A maximum-length (24-character) policy-valid password is accepted, then that user logs in
    When I create a global user with a random email
    And I set the created user's password to "Abcdefghijklmno_prst123u" using the chief admin token
    And I log in as the created user with password "Abcdefghijklmno_prst123u"
    Then the response status code should be 200
    And the "public_login" success response should be valid

  @positive @first-login
  Scenario: A password using the allowed special character "&" is accepted, then that user logs in
    When I create a global user with a random email
    And I set the created user's password to "Str0ng&Pass9" using the chief admin token
    And I log in as the created user with password "Str0ng&Pass9"
    Then the response status code should be 200
    And the "public_login" success response should be valid

  @positive @first-login
  Scenario: A password using the allowed special character "=" is accepted, then that user logs in
    When I create a global user with a random email
    And I set the created user's password to "Valid=Pass99" using the chief admin token
    And I log in as the created user with password "Valid=Pass99"
    Then the response status code should be 200
    And the "public_login" success response should be valid

  @security @first-login @injection
  Scenario: A policy-valid password containing SQL-injection metacharacters is stored and used as a literal
    When I create a global user with a random email
    And I set the created user's password to "Robert'); Drop@1" using the chief admin token
    Then the response status code should be 200
    And the response body should contain field "message" as "auto" with value "Password successfully updated"
    When I log in as the created user with password "Robert'); Drop@1"
    Then the response status code should be 200
    And the "public_login" success response should be valid

  @negative @first-login
  Scenario: A first login with the wrong password is rejected
    When I create a global user with a random email
    And I set the created user's password to "User@123" using the chief admin token
    And I log in as the created user with password "Wrong@999"
    Then the response status code should be one of "400,401"
    And the "public_login" failure response should be valid

  @negative @first-login
  Scenario: A freshly created user cannot log in before any password has been set
    When I create a global user with a random email
    And I log in as the created user with password "User@123"
    Then the response status code should be one of "400,401,404"
    And the "public_login" failure response should be valid
