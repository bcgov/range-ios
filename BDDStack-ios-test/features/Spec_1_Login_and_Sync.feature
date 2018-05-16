@iOS_Test_1
Feature: Test login with IDIR and syncing
  First time log in to the app will require:
  1. Login with IDIR account
  2. Syncing the data from server

  @restart
  Scenario: Login with IDIR account and Sync
    Given I open the app for the first time
    When I click on login button
    Then I should be redirected to web IDIR Login page

  Scenario: Login with IDIR account
    Given I am at the Login website
    When I enter my IDIR account
    And I click on IDIR login button
    Then I should be directed to native Home page

  Scenario: Sync data
    Given Syncing popup window showing
    When I close the popup window
    Then I am directed to the Home page with Synced status
  
  Scenario: First time in Home page with empty data
    Given I land on Home page
    When I see create button and user inital
    Then I should see empty list of RUPs