require "rails_helper"

RSpec.describe "Admin::Locations", type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:non_admin_user) { create(:user, role: :general) }

  describe "authentication and authorization" do
    describe "GET /admin/locations" do
      context "when user is not authenticated" do
        it "redirects to login page" do
          get admin_locations_path
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "when user is not an admin" do
        before { sign_in non_admin_user }

        it "redirects with unauthorized message" do
          get admin_locations_path
          expect(response).to redirect_to(admin_root_path)
          expect(flash[:alert]).to be_present
        end
      end
    end
  end

  describe "GET /admin/locations" do
    before { sign_in admin_user }

    it "returns success" do
      get admin_locations_path
      expect(response).to have_http_status(:success)
    end

    it "lists all locations ordered by code" do
      location_b = create(:location, code: "B-001", name: "Second")
      location_a = create(:location, code: "A-001", name: "First")
      location_c = create(:location, code: "C-001", name: "Third")

      get admin_locations_path

      expect(response.body).to match(/A-001.*B-001.*C-001/m)
    end
  end

  describe "GET /admin/locations/new" do
    before { sign_in admin_user }

    it "returns success" do
      get new_admin_location_path
      expect(response).to have_http_status(:success)
    end

    it "renders the new form" do
      get new_admin_location_path
      expect(response.body).to include("form")
    end
  end

  describe "POST /admin/locations" do
    before { sign_in admin_user }

    context "with valid parameters" do
      let(:valid_params) do
        {
          location: {
            code: "R-1",
            name: "Woronicza",
            active: true
          }
        }
      end

      it "creates a new location" do
        expect {
          post admin_locations_path, params: valid_params
        }.to change(Location, :count).by(1)
      end

      it "redirects to locations index" do
        post admin_locations_path, params: valid_params
        expect(response).to redirect_to(admin_locations_path)
      end

      it "displays success notice" do
        post admin_locations_path, params: valid_params
        follow_redirect!
        expect(response.body).to include(I18n.t('admin.locations.created'))
      end

      it "creates location with correct attributes" do
        post admin_locations_path, params: valid_params
        location = Location.last
        expect(location.code).to eq("R-1")
        expect(location.name).to eq("Woronicza")
        expect(location.active).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          location: {
            code: "",
            name: "",
            active: true
          }
        }
      end

      it "does not create a new location" do
        expect {
          post admin_locations_path, params: invalid_params
        }.not_to change(Location, :count)
      end

      it "renders the new form again" do
        post admin_locations_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with duplicate code" do
      let!(:existing_location) { create(:location, code: "R-1") }
      let(:duplicate_params) do
        {
          location: {
            code: "R-1",
            name: "Different Name",
            active: true
          }
        }
      end

      it "does not create a new location" do
        expect {
          post admin_locations_path, params: duplicate_params
        }.not_to change(Location, :count)
      end

      it "renders the new form with errors" do
        post admin_locations_path, params: duplicate_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /admin/locations/:id/edit" do
    let(:location) { create(:location) }

    before { sign_in admin_user }

    it "returns success" do
      get edit_admin_location_path(location)
      expect(response).to have_http_status(:success)
    end

    it "renders the edit form" do
      get edit_admin_location_path(location)
      expect(response.body).to include("form")
      expect(response.body).to include(location.code)
    end
  end

  describe "PATCH /admin/locations/:id" do
    let(:location) { create(:location, code: "OLD-1", name: "Old Name") }

    before { sign_in admin_user }

    context "with valid parameters" do
      let(:valid_params) do
        {
          location: {
            code: "NEW-1",
            name: "New Name",
            active: false
          }
        }
      end

      it "updates the location" do
        patch admin_location_path(location), params: valid_params
        location.reload
        expect(location.code).to eq("NEW-1")
        expect(location.name).to eq("New Name")
        expect(location.active).to be false
      end

      it "redirects to locations index" do
        patch admin_location_path(location), params: valid_params
        expect(response).to redirect_to(admin_locations_path)
      end

      it "displays success notice" do
        patch admin_location_path(location), params: valid_params
        follow_redirect!
        expect(response.body).to include(I18n.t('admin.locations.updated'))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          location: {
            code: "",
            name: "",
            active: true
          }
        }
      end

      it "does not update the location" do
        patch admin_location_path(location), params: invalid_params
        location.reload
        expect(location.code).to eq("OLD-1")
        expect(location.name).to eq("Old Name")
      end

      it "renders the edit form again" do
        patch admin_location_path(location), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with duplicate code" do
      let!(:other_location) { create(:location, code: "OTHER-1") }
      let(:duplicate_params) do
        {
          location: {
            code: "OTHER-1",
            name: "Some Name"
          }
        }
      end

      it "does not update the location" do
        patch admin_location_path(location), params: duplicate_params
        location.reload
        expect(location.code).to eq("OLD-1")
      end

      it "renders the edit form with errors" do
        patch admin_location_path(location), params: duplicate_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /admin/locations/:id" do
    let(:location) { create(:location) }

    before { sign_in admin_user }

    context "when location has no associations" do
      it "deletes the location" do
        location # Create the location
        expect {
          delete admin_location_path(location)
        }.to change(Location, :count).by(-1)
      end

      it "redirects to locations index" do
        delete admin_location_path(location)
        expect(response).to redirect_to(admin_locations_path)
      end

      it "displays success notice" do
        delete admin_location_path(location)
        follow_redirect!
        expect(response.body).to include(I18n.t('admin.locations.deleted'))
      end
    end

    context "when location has associated users" do
      let!(:user) { create(:user, location: location) }

      it "does not delete the location" do
        expect {
          delete admin_location_path(location)
        }.not_to change(Location, :count)
      end

      it "redirects to locations index with alert" do
        delete admin_location_path(location)
        expect(response).to redirect_to(admin_locations_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('admin.locations.cannot_delete'))
      end
    end

    context "when location has associated news posts" do
      let!(:news_post) { create(:news_post, location: location) }

      it "does not delete the location" do
        expect {
          delete admin_location_path(location)
        }.not_to change(Location, :count)
      end

      it "redirects to locations index with alert" do
        delete admin_location_path(location)
        expect(response).to redirect_to(admin_locations_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('admin.locations.cannot_delete'))
      end
    end

    context "when location has both users and news posts" do
      let!(:user) { create(:user, location: location) }
      let!(:news_post) { create(:news_post, location: location) }

      it "does not delete the location" do
        expect {
          delete admin_location_path(location)
        }.not_to change(Location, :count)
      end

      it "redirects to locations index with alert" do
        delete admin_location_path(location)
        expect(response).to redirect_to(admin_locations_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('admin.locations.cannot_delete'))
      end
    end
  end

  describe "parameter filtering" do
    before { sign_in admin_user }

    it "only permits whitelisted parameters" do
      params = {
        location: {
          code: "TEST-1",
          name: "Test Location",
          active: true,
          unauthorized_param: "malicious value"
        }
      }

      post admin_locations_path, params: params
      location = Location.last

      expect(location.code).to eq("TEST-1")
      expect(location.name).to eq("Test Location")
      expect(location.active).to be true
      expect(location).not_to respond_to(:unauthorized_param)
    end
  end
end