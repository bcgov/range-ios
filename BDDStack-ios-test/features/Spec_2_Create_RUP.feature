@iOS_Test
Feature: Test RUP Creat page
  Check the fields in the RUP creation form
  1. Autofilled info
  2. Test Basic Information session
  3. Test Pasture session
  4. Test Schedule session

  @restart
  Scenario: Create a new RUP from agreement I am assigned
    Given I am on Home page
    When I click on create button
    Then I am at the Agreement Selection page
    And I pick an agreement
    Then I should be in the Create page

  Scenario: Check auto-populated fields in Agreement
    Given I am on Create page
    When I have the Agreement selected
    Then I should see all the existing fields
    #tables

  Scenario: Edit Range info in <Basic Information>
    Given I am on Create page
    When I enter Range Name and Alter Business Name
    Then I should see the updates

  Scenario: Check dates within range of Agreement in <Basic Information>
    Given I am on Create page
    When I click on Start-date of Plan
    And I pick a date before Agreement Start-date
    Then I should see a date as the Agreement Start-date
    When I click on End-date of Plan
    And I pick a date after Agreement End-date
    Then I should see a date as the Agreement End-date
  
  Scenario: Check <Range Usage> has data
    Given I am on Create page
    When I scroll
    Then I should see a list of usages

  Scenario: Check create a new <Pasture>
    Given I go to <Pasture> section
    When I click on add new pasture
    And I enter name for pasture and confirm
    #variable
    Then I should see a new pasture

  Scenario: Check enter information to <Pasture>
    Given I have a pasture
    When I type in to the fields
    #tables
    Then I should see data populated

  Scenario: Check <Pasture> management
    Given I have a pasture
    When I copy a pasture
    And I enter name for pasture and confirm
    #variable
    Then I should see two Pastures

