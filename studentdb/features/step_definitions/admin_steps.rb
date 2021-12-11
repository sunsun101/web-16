Given("I am an Admin") do
  @admin = FactoryBot.create :admin
end

Given("There are users") do
  @user1 = FactoryBot.create :user1
  @user2 = FactoryBot.create :user2
end

Given("I am logged in") do
  visit "/users/sign_in"
  fill_in "Email", with: @admin.email
  fill_in "Password", with: @admin.password
  click_button "Log in"
end

When("I visit admin dashboard") do
  visit admin_dashboard_url
end

Then("I should see a list of users") do
  expect(page).to have_css("table")
end

When("I click delete button for a user") do
  find_link("Delete", href: users_destroy_path(user: { id: @user1.id })).click
end

Then("the user should be deleted") do
  expect(page).to have_no_content @user1.email
end

When("I click edit button for a user") do
  page.find("#myModal_" + @user1.id.to_s + "", visible: :all).click
end

Then("I should see a user edit form") do
  expect(page).to have_selector("form#edit_user_" + @user1.id.to_s + "")
end

When("I submit the user edit form") do
  fill_in "Email: ", with: @user1.email
  fill_in "Make admin: ", with: @user1.is_admin
  click_button "Save changes"
end

Then("I should see the changes in user") do
  expect(page).to have_content @user1.email
end
