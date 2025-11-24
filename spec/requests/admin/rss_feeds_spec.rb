# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::RssFeeds", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:general_user) { create(:user, :general) }

  describe "GET /admin/rss_feeds" do
    context "when user is admin" do
      before { sign_in admin }

      it "returns success" do
        get admin_rss_feeds_path
        expect(response).to have_http_status(:success)
      end

      it "displays all RSS feeds" do
        feeds = create_list(:rss_feed, 3)
        get admin_rss_feeds_path

        feeds.each do |feed|
          expect(response.body).to include(feed.name)
        end
      end
    end

    context "when user is not admin" do
      before { sign_in general_user }

      it "redirects or denies access" do
        get admin_rss_feeds_path
        expect(response).to have_http_status(:redirect).or have_http_status(:forbidden)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        get admin_rss_feeds_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/rss_feeds/new" do
    context "when user is admin" do
      before { sign_in admin }

      it "returns success" do
        get new_admin_rss_feed_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /admin/rss_feeds" do
    context "when admin creates RSS feed with valid parameters" do
      let(:valid_params) do
        {
          rss_feed: {
            name: "Tech News",
            url: "https://example.com/feed.rss",
            active: true
          }
        }
      end

      before { sign_in admin }

      it "creates a new RSS feed" do
        expect do
          post admin_rss_feeds_path, params: valid_params
        end.to change(RssFeed, :count).by(1)
      end

      it "redirects to RSS feeds index" do
        post admin_rss_feeds_path, params: valid_params
        expect(response).to redirect_to(admin_rss_feeds_path)
      end
    end

    context "when admin creates RSS feed with invalid parameters" do
      let(:invalid_params) do
        {
          rss_feed: {
            name: "",
            url: "invalid-url"
          }
        }
      end

      before { sign_in admin }

      it "does not create an RSS feed" do
        expect do
          post admin_rss_feeds_path, params: invalid_params
        end.not_to change(RssFeed, :count)
      end

      it "renders new template" do
        post admin_rss_feeds_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content).or have_http_status(:success)
      end
    end
  end

  describe "GET /admin/rss_feeds/:id/edit" do
    let(:rss_feed) { create(:rss_feed) }

    context "when user is admin" do
      before { sign_in admin }

      it "returns success" do
        get edit_admin_rss_feed_path(rss_feed)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /admin/rss_feeds/:id" do
    let(:rss_feed) { create(:rss_feed, name: "Old Name") }

    context "when admin updates RSS feed with valid parameters" do
      let(:valid_params) do
        {
          rss_feed: {
            name: "New Name"
          }
        }
      end

      before { sign_in admin }

      it "updates the RSS feed" do
        patch admin_rss_feed_path(rss_feed), params: valid_params
        expect(rss_feed.reload.name).to eq("New Name")
      end

      it "redirects to RSS feeds index" do
        patch admin_rss_feed_path(rss_feed), params: valid_params
        expect(response).to redirect_to(admin_rss_feeds_path)
      end
    end

    context "when admin updates RSS feed with invalid parameters" do
      let(:invalid_params) do
        {
          rss_feed: {
            name: "",
            url: "invalid"
          }
        }
      end

      before { sign_in admin }

      it "does not update the RSS feed" do
        patch admin_rss_feed_path(rss_feed), params: invalid_params
        expect(rss_feed.reload.name).to eq("Old Name")
      end
    end
  end

  describe "DELETE /admin/rss_feeds/:id" do
    let!(:rss_feed) { create(:rss_feed) }

    context "when user is admin" do
      before { sign_in admin }

      it "destroys the RSS feed" do
        expect do
          delete admin_rss_feed_path(rss_feed)
        end.to change(RssFeed, :count).by(-1)
      end

      it "redirects to RSS feeds index" do
        delete admin_rss_feed_path(rss_feed)
        expect(response).to redirect_to(admin_rss_feeds_path)
      end
    end

    context "when user is not admin" do
      before { sign_in general_user }

      it "does not destroy the RSS feed" do
        expect do
          delete admin_rss_feed_path(rss_feed)
        end.not_to change(RssFeed, :count)
      end
    end
  end
end
