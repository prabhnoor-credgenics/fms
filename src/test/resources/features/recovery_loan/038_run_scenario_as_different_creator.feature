@api @recovery @multi-user
Feature: Running a scenario as a different creator — three ways


  @manual @way1-switch
  Scenario: Way 1 — switch the active user between remembered creators
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I authenticate as "creator" slot 2 and remember as "creator2"

    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200

    And I switch active user to "creator0"
    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200


  @manual @way2-keyed-token
  Scenario: Way 2 — target a specific remembered creator per-request via keyed placeholders
    Given I authenticate as "creator" slot 0 and remember as "creator0"
    And I authenticate as "creator" slot 1 and remember as "creator1"

    And I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID:creator0} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN:creator0} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200


  @manual @way3-slot-tag @slot-2
  Scenario: Way 3 — @slot-2 tag runs the entire scenario as creator slot 2
    Given I prepare a request
    And I set the query parameters:
      | company_id | {COMPANY_ID} |
    And I set the request headers:
      | authenticationtoken | {AUTH_TOKEN} |
    When I send a "GET" request to "/recovery/all-loans"
    Then the response status code should be 200
