@api @user @first-login @change-password
Feature: First-login password set by chief admin — create user + PATCH /user/change-password + login

  A chief admin creates a fresh global user with a random email, then sets that user's password via
  PATCH /user/change-password (RSA-encrypted body, same scheme as login) carrying
  {user_id, new_password, source:"first_login"}, authenticated with the CHIEF ADMIN's token. The
  email is generated during creation and the user_id comes from the create response, so the scenario
  carries no user-specific identifiers. The created user then logs in for the first time with that
  new password.

  Background:
    Given I authenticate as "chief-admin" slot 0 and remember as "chiefadmin0"

  @positive @smoke @first-login
  Scenario: Chief admin creates a user, sets its password, then that user logs in for the first time
    When I create a global user with a random email
    And I set the created user's password to "User@123" using the chief admin token
    And I log in as the created user with password "User@123"
    Then the response status code should be 200
    And the public login success response should be valid
