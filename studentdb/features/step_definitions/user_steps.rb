# frozen_string_literal: true

Given('I am an unregistered user') do
  @user = FactoryBot.build :user
end

When('I sign up') do
  visit root_path
  click_link 'Sign up'
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  fill_in 'Password confirmation', with: @user.password
  click_button 'Sign up'
end

Then('I should see an email confirmation page') do
  expect(page).to have_content 'A message with a confirmation link has been sent to your email'
end

When('I confirm') do
  token = User.find_by_email(@user.email).confirmation_token
  visit user_confirmation_path(confirmation_token: token)
end

def sign_in(user)
  click_link 'Sign in'
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Log in'
end

Given('I am signed in') do
  visit root_url
  sign_in(@user)
end

When('I sign in') do
  sign_in(@user)
end

Then('I should be confirmed') do
  expect(page).to have_content 'Your email address has been successfully confirmed'
end

Then('I should be signed in') do
  expect(page).to have_content "Welcome #{@user.email}"
end

Given('there are no users registered') do
  User.all.each(&:delete)
end

Then('I should be an admin') do
  expect(page).to have_link 'Admin dashboard'
  click_link 'Admin dashboard'
  expect(page).to have_content 'Admin dashboard'
end
