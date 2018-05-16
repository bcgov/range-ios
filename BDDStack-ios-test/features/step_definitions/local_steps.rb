Given("I land on Login page") do
  find_element(id: "ca.used:id/login_skip_button")
end

When("I click on Skip button") do
  find_element(id: "ca.used:id/login_skip_button").click
end

Then("I should asked to give location permission") do
	find_element(id: "com.android.packageinstaller:id/permission_message")
end

When("I accept location request") do
  find_element(id: "com.android.packageinstaller:id/permission_allow_button").click
end


Then("I should should be logged in") do
	find_element(xpath: "//*[@class='android.support.v7.app.ActionBar$Tab' and @index='3']")
end