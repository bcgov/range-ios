require 'active_support'
require 'active_support/core_ext'

Given("I open the app for the first time") do
  find_element(id: "My Range Application")
end

When("I click on login button") do
  find_element(id: "loginButton").click
  sleep 5
end

Then("I should be redirected to web IDIR Login page") do
  webView = @driver.available_contexts.second
  @driver.set_context(webView)
end

Given("I am at the Login website") do
  sleep 5
end

When("I enter my IDIR account") do
  find_element(id: "username").send_key("myra2")
  find_element(id: "password").send_key("myra2")
end

When("I click on IDIR login button") do
  find_element(id: "kc-login").click
end

Then("I should be directed to native Home page") do
  sleep 15
  nativeView = @driver.available_contexts.first
  @driver.set_context(nativeView)
end

Given("Syncing popup window showing") do
  # check
end

When("I close the popup window") do
  find_element(id: "Close").click
end

Then("I am directed to the Home page with Synced status") do
  find_element(id: "SyncTimeStamp") == "0 days ago"
end

Given("I land on Home page") do
  # check
end

When("I see create button and user inital") do
  find_element(id: "CreateRupButton")
end

Then("I should see empty list of RUPs") do
  find_element(xpath: "//XCUIElementTypeTable[@name=\"Empty list\"]")
end