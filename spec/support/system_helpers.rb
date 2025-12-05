# Helper methods for system/feature specs.
# Provides common functionality for testing user interactions in browser-based tests.
module SystemHelpers
  # Signs in a user through the UI for system specs
  def sign_in(user)
    visit new_user_session_path
    fill_in "user_username", with: user.username
    fill_in "user_password", with: user.password
    click_button I18n.t("devise.sessions.new.sign_in", default: "Zaloguj się")
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
