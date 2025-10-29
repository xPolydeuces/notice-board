Given("a user exists with email {string} and password {string}") do |email, password|
  FactoryBot.create(:user, email: email, password: password, password_confirmation: password)
end

When("I log in as {string} with password {string}") do |email, password|
  visit new_user_session_path
  fill_in "user_email", with: email
  fill_in "user_password", with: password
  click_button "Log in"
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end
