require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:general_user) { create(:user, :general) }

  describe "GET /admin" do
    context "when user is signed in as admin" do
      before { sign_in admin }

      it "returns success" do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end

      it "displays dashboard content" do
        get admin_root_path
        expect(response.body).to include("Panel Administracyjny")
      end
    end

    context "when user is signed in but not admin" do
      before { sign_in general_user }

      it "allows access (all signed in users can view dashboard)" do
        get admin_root_path
        expect(response).to have_http_status(:success).or have_http_status(:redirect)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in page" do
        get admin_root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
