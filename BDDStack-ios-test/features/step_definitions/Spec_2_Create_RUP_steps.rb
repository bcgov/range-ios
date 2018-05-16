require 'active_support'
require 'active_support/core_ext'

Given("I am on Home page") do
  # check
end

When("I click on create button") do
  find_element(id: "CreateRupButton").click
  sleep 1
end

Then("I am at the Agreement Selection page") do
  # expect(find_elements(id: "Select")).not_to be_empty
end

Then("I pick an agreement") do
  find_elements(id: "Select").first.click
  sleep 1
end

Then("I should be in the Create page") do
  # find_element(id: "SaveDraftButton")
  # find_element(id: "CreatePageCancelButton")
  # find_element(xpath: "//XCUIElementTypeStaticText[@name=\"Create New RUP\"]")
end

Given("I am on Create page") do
  # sleep 1
end

When("I have the Agreement selected") do
  # find_element(id: "RangeNameLabel")
  # sleep 1
end

Then("I should see all the existing fields") do
  # check
end

When("I enter Range Name and Alter Business Name") do
#   find_element(id: "RangeNameField").send_keys 'the Range'
#   hide_keyboard
#   sleep 1
# # hide_keyboard not stable atm, it'll take a long time!
# # https://developers.perfectomobile.com/display/TT/iOS+Limitation%3AAppium+hideKeyboard+Method
#   find_element(id: "AlternativeBusinessNameField").send_keys 'the Range 2'
#   hide_keyboard
#   sleep 1
end

Then("I should see the updates") do
  # find_element(id: "RangeNameField")
end

When("I click on Start-date of Plan") do
  find_element(id: 'PlanStartDateButton').click
  sleep 1
end

When("I pick a date before Agreement Start-date") do
  find_elements(:class, 'XCUIElementTypePickerWheel').first.send_keys 'January'
  find_elements(:class, 'XCUIElementTypePickerWheel').second.send_keys '1'
  find_elements(:class, 'XCUIElementTypePickerWheel').third.send_keys '1990'
  sleep 1
end

Then("I should see a date as the Agreement Start-date") do
  find_elements(:class, 'XCUIElementTypePickerWheel').third.text > '1990'
  find_element(id: 'PickerSelectButton').click
end

When("I click on End-date of Plan") do
  find_element(id: 'PlanEndDateButton').click
  sleep 1
end

When("I pick a date after Agreement End-date") do
  find_elements(:class, 'XCUIElementTypePickerWheel').first.send_keys 'January'
  find_elements(:class, 'XCUIElementTypePickerWheel').second.send_keys '1'
  find_elements(:class, 'XCUIElementTypePickerWheel').third.send_keys '2100'
end

Then("I should see a date as the Agreement End-date") do
  find_elements(:class, 'XCUIElementTypePickerWheel').third.text < '2100'
  find_element(id: 'PickerSelectButton').click
end

When("I scroll") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should see a list of usages") do
  pending # Write code here that turns the phrase above into concrete actions
end

Given("I go to <Pasture> section") do
  find_element(id: 'PastureSectionButton').click
end

When("I click on add new pasture") do
  find_element(id: 'AddPastureButton').click
end

When("I enter name for pasture and confirm") do
  find_element(id: 'PopupInput').send_keys 'p1'
  find_element(id: 'PopUpAddButton').click
end

Then("I should see a new pasture") do
  sleep 1
end


# pasture:
# PastureOptionsButton
# Copy
# Delete


# nav:
# ScheduleSectionButton

  # find_element(id: 'AddYearlyScheduleButton') 
