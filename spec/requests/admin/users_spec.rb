# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:superadmin) { create(:user, :superadmin) }
  let(:general_user) { create(:user, :general) }

  describe "GET /admin/users" do
    context "when user is admin" do
      before { sign_in admin }

      it "returns success" do
        get admin_users_path
        expect(response).to have_http_status(:success)
      end

      it "displays all users" do
        users = create_list(:user, 3)
        get admin_users_path

        users.each do |user|
          expect(response.body).to include(user.username)
        end
      end
    end

    context "when user is not admin" do
      before { sign_in general_user }

      it "redirects or denies access" do
        get admin_users_path
        expect(response).to have_http_status(:redirect).or have_http_status(:forbidden)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        get admin_users_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/users/new" do
    context "when user is admin" do
      before { sign_in admin }

      it "returns success" do
        get new_admin_user_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /admin/users" do
    context "when user is admin" do
      before { sign_in admin }

      context "with valid parameters" do
        let(:valid_params) do
          {
            user: {
              username: "newuser",
              password: "password123",
              password_confirmation: "password123",
              role: "general"
            }
          }
        end

        it "creates a new user" do
          expect do
            post admin_users_path, params: valid_params
          end.to change(User, :count).by(1)
        end

        it "redirects to users index" do
          post admin_users_path, params: valid_params
          expect(response).to redirect_to(admin_users_path)
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) do
          {
            user: {
              username: "",
              password: "123"
            }
          }
        end

        it "does not create a user" do
          expect do
            post admin_users_path, params: invalid_params
          end.not_to change(User, :count)
        end

        it "renders new template" do
          post admin_users_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content).or have_http_status(:success)
        end
      end
    end
  end

  describe "GET /admin/users/:id/edit" do
    let(:user) { create(:user) }

    context "when user is admin" do
      before { sign_in admin }

      it "returns success" do
        get edit_admin_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /admin/users/:id" do
    let(:user) { create(:user, username: "oldname") }

    context "when user is admin" do
      before { sign_in admin }

      context "with valid parameters" do
        let(:valid_params) do
          {
            user: {
              username: "newname"
            }
          }
        end

        it "updates the user" do
          patch admin_user_path(user), params: valid_params
          expect(user.reload.username).to eq("newname")
        end

        it "redirects to users index" do
          patch admin_user_path(user), params: valid_params
          expect(response).to redirect_to(admin_users_path)
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) do
          {
            user: {
              username: ""
            }
          }
        end

        it "does not update the user" do
          patch admin_user_path(user), params: invalid_params
          expect(user.reload.username).to eq("oldname")
        end
      end
    end
  end

  describe "DELETE /admin/users/:id" do
    let!(:user_to_delete) { create(:user) }

    context "when user is admin" do
      before { sign_in admin }

      it "destroys the user" do
        expect do
          delete admin_user_path(user_to_delete)
        end.to change(User, :count).by(-1)
      end

      it "redirects to users index" do
        delete admin_user_path(user_to_delete)
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when user is not admin" do
      before { sign_in general_user }

      it "does not destroy the user" do
        expect do
          delete admin_user_path(user_to_delete)
        end.not_to change(User, :count)
      end
    end

    context "when trying to delete an admin as admin (not superadmin)" do
      let!(:admin_to_delete) { create(:user, :admin) }

      before { sign_in admin }

      it "does not destroy the admin user" do
        expect do
          delete admin_user_path(admin_to_delete)
        end.not_to change(User, :count)
      end
    end

    context "when trying to delete an admin as superadmin" do
      let!(:admin_to_delete) { create(:user, :admin) }

      before { sign_in superadmin }

      it "destroys the admin user" do
        expect do
          delete admin_user_path(admin_to_delete)
        end.to change(User, :count).by(-1)
      end
    end
  end

  describe "POST /admin/users/:id/reset_password" do
    let(:user_to_reset) { create(:user, :general) }

    context "when user is admin" do
      before { sign_in admin }

      it "generates a temporary password" do
        expect do
          post reset_password_admin_user_path(user_to_reset)
        end.to(change { user_to_reset.reload.encrypted_password })
      end

      it "sets force_password_change flag" do
        post reset_password_admin_user_path(user_to_reset)
        expect(user_to_reset.reload.force_password_change).to be true
      end

      it "redirects to users index" do
        post reset_password_admin_user_path(user_to_reset)
        expect(response).to redirect_to(admin_users_path)
      end

      it "displays temporary password in flash" do
        post reset_password_admin_user_path(user_to_reset)
        expect(flash[:temp_password]).to be_present
        expect(flash[:temp_password].length).to eq(12)
      end

      it "displays success message" do
        post reset_password_admin_user_path(user_to_reset)
        follow_redirect!
        expect(flash[:notice]).to be_present
      end

      context "when trying to reset own password" do
        it "does not reset password" do
          old_password = admin.encrypted_password
          post reset_password_admin_user_path(admin)
          expect(admin.reload.encrypted_password).to eq(old_password)
        end

        it "redirects with error message" do
          post reset_password_admin_user_path(admin)
          expect(response).to redirect_to(admin_users_path)
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "when user is not admin" do
      before { sign_in general_user }

      it "does not reset password" do
        old_password = user_to_reset.encrypted_password
        post reset_password_admin_user_path(user_to_reset)
        expect(user_to_reset.reload.encrypted_password).to eq(old_password)
      end

      it "redirects or denies access" do
        post reset_password_admin_user_path(user_to_reset)
        expect(response).to have_http_status(:redirect).or have_http_status(:forbidden)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        post reset_password_admin_user_path(user_to_reset)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
