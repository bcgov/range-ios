@Local_Test
Feature: Test on login

  Scenario: Login without credentails
    Given I land on Login page
    When I click on Skip button
    Then I should asked to give location permission
    When I accept location request
    Then I should should be logged in
