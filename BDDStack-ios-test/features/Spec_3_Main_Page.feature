@iOS_Test_3
Feature: Test Home page
  Standard procedure of app usage on the Home page: (and general navigation)
  - Verify the app and data status
  - See a list of assigned agreements
  - Logout

  Scenario: Home page with list of RUPs
    Given I land on Home page
    When I see the table
    Then I should see cells in the table with different status
    

  Scenario: View detail of existing RUP
    Given I land on Home page
    When I click on View button for an agreement
    Then I should see the details in View (Create) page


  Scenario: Logout of app
    Given I land on Home page
    When I click on logout button
    Then I should be in Login page again