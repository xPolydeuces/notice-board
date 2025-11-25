require "rails_helper"

RSpec.describe "User Management", type: :system do
  let(:admin) { create(:user, :admin) }
  let(:superadmin) { create(:user, :superadmin) }

  before do
    driven_by(:rack_test)
  end

  describe "Users index" do
    before do
      sign_in admin
      create_list(:user, 5)
    end

    it "displays all users" do
      visit admin_users_path

      expect(page).to have_css("tbody tr", minimum: 5)
    end

    it "shows user roles" do
      visit admin_users_path

      expect(page).to have_content("General").or have_content("Admin")
    end
  end

  describe "Creating a new user" do
    before { sign_in admin }

    context "with valid data" do
      it "creates a new user successfully" do
        visit new_admin_user_path

        fill_in "Username", with: "newuser123"
        fill_in "Password", with: "password123"
        fill_in "Password confirmation", with: "password123"
        select "General", from: "Role"

        click_button "Create User"

        expect(page).to have_content("User was successfully created")
        expect(User.find_by(username: "newuser123")).to be_present
      end
    end

    context "with invalid data" do
      it "shows validation errors" do
        visit new_admin_user_path

        fill_in "Username", with: ""
        fill_in "Password", with: "123" # Too short

        click_button "Create User"

        expect(page).to have_content("error").or have_content("can't be blank")
      end
    end

    context "with duplicate username" do
      let!(:existing_user) { create(:user, username: "duplicate") }

      it "shows uniqueness error" do
        visit new_admin_user_path

        fill_in "Username", with: "DUPLICATE" # Case insensitive
        fill_in "Password", with: "password123"
        fill_in "Password confirmation", with: "password123"

        click_button "Create User"

        expect(page).to have_content("has already been taken")
      end
    end
  end

  describe "Editing a user" do
    let(:user_to_edit) { create(:user, username: "oldname") }

    before { sign_in admin }

    it "updates the user successfully" do
      visit edit_admin_user_path(user_to_edit)

      fill_in "Username", with: "newname"
      select "Admin", from: "Role"

      click_button "Update User"

      expect(page).to have_content("User was successfully updated")
      expect(user_to_edit.reload.username).to eq("newname")
      expect(user_to_edit.reload.role).to eq("admin")
    end
  end

  describe "Deleting a user" do
    let!(:user_to_delete) { create(:user, username: "deleteme") }

    before { sign_in admin }

    it "deletes the user" do
      visit admin_users_path

      expect(page).to have_content("deleteme")

      # Find and click the delete button (rack_test doesn't support accept_confirm)
      within("tr", text: "deleteme") do
        find("button[title='Delete']").click
      end

      expect(page).to have_no_content("deleteme")
      expect(User.exists?(user_to_delete.id)).to be false
    end
  end

  describe "Admin deletion restrictions" do
    let!(:admin_to_delete) { create(:user, :admin, username: "adminuser") }

    context "when logged in as admin" do
      before { sign_in admin }

      it "cannot delete another admin" do
        visit admin_users_path

        within("tr", text: "adminuser") do
          expect(page).to have_no_css("button[title='Delete']")
        end
      end
    end

    context "when logged in as superadmin" do
      before { sign_in superadmin }

      it "can delete an admin" do
        visit admin_users_path

        # Find and click the delete button (rack_test doesn't support accept_confirm)
        within("tr", text: "adminuser") do
          find("button[title='Delete']").click
        end

        expect(User.exists?(admin_to_delete.id)).to be false
      end
    end
  end

  describe "Location user creation" do
    let!(:location) { create(:location) }

    before { sign_in admin }

    it "creates a location user with assigned location" do
      visit new_admin_user_path

      fill_in "Username", with: "locationuser"
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "password123"
      select "Location", from: "Role"
      select location.full_name, from: "Location"

      click_button "Create User"

      expect(page).to have_content("User was successfully created")
      new_user = User.find_by(username: "locationuser")
      expect(new_user.location).to eq(location)
      expect(new_user.role).to eq("location")
    end
  end
end
