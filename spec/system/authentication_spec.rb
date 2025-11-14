# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :system do
  let(:user) { create(:user, username: "testuser", password: "password123") }

  before do
    driven_by(:rack_test)
  end

  describe "Sign in" do
    before { user } # Ensure user is created

    it "allows user to sign in with valid credentials" do
      visit new_user_session_path

      fill_in "user_username", with: "testuser"
      fill_in "user_password", with: "password123"

      click_button I18n.t("devise.sessions.new.sign_in", default: "Zaloguj się")

      expect(page).to have_content("Signed in successfully").or have_current_path(admin_root_path)
    end

    it "rejects sign in with invalid credentials" do
      visit new_user_session_path

      fill_in "user_username", with: "testuser"
      fill_in "user_password", with: "wrongpassword"

      click_button I18n.t("devise.sessions.new.sign_in", default: "Zaloguj się")

      expect(page).to have_content("Invalid").or have_content("incorrect")
    end

    it "rejects sign in with non-existent user" do
      visit new_user_session_path

      fill_in "user_username", with: "nonexistent"
      fill_in "user_password", with: "password123"

      click_button I18n.t("devise.sessions.new.sign_in", default: "Zaloguj się")

      expect(page).to have_content("Invalid").or have_content("incorrect")
    end
  end

  describe "Sign out" do
    before { sign_in user }

    it "allows user to sign out" do
      visit admin_root_path

      click_button "Wyloguj się"  # Polish for "Sign out"

      expect(page).to have_content("Signed out successfully").or have_current_path(new_user_session_path)
    end
  end

  describe "Protected routes" do
    it "redirects to sign in when accessing protected routes" do
      visit admin_news_posts_path

      expect(page).to have_current_path(new_user_session_path)
    end

    it "allows access to protected routes when signed in" do
      sign_in user
      visit admin_news_posts_path

      expect(page).to have_current_path(admin_news_posts_path)
    end
  end

  describe "Session timeout" do
    before { sign_in user }

    it "requires re-authentication after timeout" do
      # Simulate session timeout by advancing time
      travel 31.minutes do
        visit admin_news_posts_path
        expect(page).to have_current_path(new_user_session_path).or have_content("session expired")
      end
    end
  end
end