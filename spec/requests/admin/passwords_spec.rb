# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Passwords", type: :request do
  let(:user) { create(:user, :general) }
  let(:admin) { create(:user, :admin) }

  describe "GET /admin/password/edit" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns success" do
        get edit_admin_password_path
        expect(response).to have_http_status(:success)
      end

      it "displays password change form" do
        get edit_admin_password_path
        expect(response.body).to include('current_password')
        expect(response.body).to include('password')
        expect(response.body).to include('password_confirmation')
      end
    end

    context "when user has force_password_change flag" do
      let(:forced_user) { create(:user, :general, force_password_change: true) }

      before { sign_in forced_user }

      it "displays force change notice" do
        get edit_admin_password_path
        expect(response.body).to include(I18n.t('admin.passwords.force_change_notice', default: 'Password change required'))
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        get edit_admin_password_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /admin/password" do
    context "when user is signed in" do
      before { sign_in user }

      context "with valid parameters" do
        let(:valid_params) do
          {
            user: {
              current_password: "password123",
              password: "newpassword123",
              password_confirmation: "newpassword123"
            }
          }
        end

        it "updates the password" do
          patch admin_password_path, params: valid_params
          user.reload
          expect(user.valid_password?("newpassword123")).to be true
        end

        it "redirects to admin root" do
          patch admin_password_path, params: valid_params
          expect(response).to redirect_to(admin_root_path)
        end

        it "displays success message" do
          patch admin_password_path, params: valid_params
          follow_redirect!
          expect(response.body).to include(I18n.t('admin.passwords.updated', default: 'Password updated successfully'))
        end

        it "keeps user signed in" do
          patch admin_password_path, params: valid_params
          expect(controller.current_user).to eq(user)
        end
      end

      context "with force_password_change flag set" do
        let(:forced_user) { create(:user, :general, force_password_change: true) }

        before { sign_in forced_user }

        let(:valid_params) do
          {
            user: {
              current_password: "password123",
              password: "newpassword123",
              password_confirmation: "newpassword123"
            }
          }
        end

        it "clears the force_password_change flag" do
          patch admin_password_path, params: valid_params
          forced_user.reload
          expect(forced_user.force_password_change).to be false
        end
      end

      context "with invalid current password" do
        let(:invalid_params) do
          {
            user: {
              current_password: "wrongpassword",
              password: "newpassword123",
              password_confirmation: "newpassword123"
            }
          }
        end

        it "does not update the password" do
          old_encrypted_password = user.encrypted_password
          patch admin_password_path, params: invalid_params
          user.reload
          expect(user.encrypted_password).to eq(old_encrypted_password)
        end

        it "renders edit template" do
          patch admin_password_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "with mismatched password confirmation" do
        let(:invalid_params) do
          {
            user: {
              current_password: "password123",
              password: "newpassword123",
              password_confirmation: "differentpassword"
            }
          }
        end

        it "does not update the password" do
          old_encrypted_password = user.encrypted_password
          patch admin_password_path, params: invalid_params
          user.reload
          expect(user.encrypted_password).to eq(old_encrypted_password)
        end

        it "renders edit template" do
          patch admin_password_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "with password too short" do
        let(:invalid_params) do
          {
            user: {
              current_password: "password123",
              password: "short",
              password_confirmation: "short"
            }
          }
        end

        it "does not update the password" do
          old_encrypted_password = user.encrypted_password
          patch admin_password_path, params: invalid_params
          user.reload
          expect(user.encrypted_password).to eq(old_encrypted_password)
        end
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        patch admin_password_path, params: { user: { password: "test" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end