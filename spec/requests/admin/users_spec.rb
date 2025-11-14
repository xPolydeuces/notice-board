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
          expect {
            post admin_users_path, params: valid_params
          }.to change(User, :count).by(1)
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
          expect {
            post admin_users_path, params: invalid_params
          }.not_to change(User, :count)
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
        expect {
          delete admin_user_path(user_to_delete)
        }.to change(User, :count).by(-1)
      end

      it "redirects to users index" do
        delete admin_user_path(user_to_delete)
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when user is not admin" do
      before { sign_in general_user }

      it "does not destroy the user" do
        expect {
          delete admin_user_path(user_to_delete)
        }.not_to change(User, :count)
      end
    end

    context "when trying to delete an admin as admin (not superadmin)" do
      let!(:admin_to_delete) { create(:user, :admin) }

      before { sign_in admin }

      it "does not destroy the admin user" do
        expect {
          delete admin_user_path(admin_to_delete)
        }.not_to change(User, :count)
      end
    end

    context "when trying to delete an admin as superadmin" do
      let!(:admin_to_delete) { create(:user, :admin) }

      before { sign_in superadmin }

      it "destroys the admin user" do
        expect {
          delete admin_user_path(admin_to_delete)
        }.to change(User, :count).by(-1)
      end
    end
  end
end