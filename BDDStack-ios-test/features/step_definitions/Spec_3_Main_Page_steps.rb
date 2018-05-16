When("I see the table") do
  # check
end

Then("I should see cells in the table with different status") do
	# check
end

When("I click on View button for an agreement") do
  # check
end

Then("I should see the details in View (Create) page") do
  # check
end

When("I click on logout button") do
	find_element(id: "Account Button").click
	sleep 1
	find_element(id: "PopUpCell").click
end

Then("I should be in Login page again") do
	find_element(id: "My Range Application")
end