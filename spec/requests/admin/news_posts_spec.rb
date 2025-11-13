require "rails_helper"

RSpec.describe "Admin::NewsPosts", type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:general_user) { create(:user, role: :general) }
  let(:location) { create(:location, code: "R-1", name: "Test Location") }
  let(:location_user) { create(:user, role: :location, location: location) }
  let(:other_location) { create(:location, code: "R-2", name: "Other Location") }
  let(:other_location_user) { create(:user, role: :location, location: other_location) }

  describe "authentication" do
    describe "GET /admin/news_posts" do
      context "when user is not authenticated" do
        it "redirects to login page" do
          get admin_news_posts_path
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe "GET /admin/news_posts" do
    context "as admin user" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_news_posts_path
        expect(response).to have_http_status(:success)
      end

      it "lists all news posts ordered by created_at desc" do
        post1 = create(:news_post, title: "First Post", created_at: 3.days.ago)
        post2 = create(:news_post, title: "Second Post", created_at: 2.days.ago)
        post3 = create(:news_post, title: "Third Post", created_at: 1.day.ago)

        get admin_news_posts_path

        expect(response.body).to match(/Third Post.*Second Post.*First Post/m)
      end

      it "can filter by location" do
        general_post = create(:news_post, :general, title: "General Post")
        location_post = create(:news_post, location: location, title: "Location Post")

        get admin_news_posts_path, params: { location_id: location.id }

        expect(response.body).to include("Location Post")
        expect(response.body).not_to include("General Post")
      end

      it "can filter by published status" do
        draft = create(:news_post, title: "Draft", published: false)
        published = create(:news_post, :published, title: "Published")

        get admin_news_posts_path, params: { published: "true" }

        expect(response.body).to include("Published")
        expect(response.body).not_to include("Draft")
      end

      it "can filter by archived status" do
        active = create(:news_post, title: "Active", archived: false)
        archived = create(:news_post, :archived, title: "Archived")

        get admin_news_posts_path, params: { archived: "true" }

        expect(response.body).to include("Archived")
        expect(response.body).not_to include("Active")
      end
    end

    context "as location user" do
      before { sign_in location_user }

      it "only shows posts for their location" do
        own_post = create(:news_post, location: location, title: "Own Location Post", user: location_user)
        other_post = create(:news_post, location: other_location, title: "Other Location Post")
        general_post = create(:news_post, :general, title: "General Post")

        get admin_news_posts_path

        expect(response.body).to include("Own Location Post")
        expect(response.body).not_to include("Other Location Post")
        expect(response.body).not_to include("General Post")
      end
    end

    context "as general user" do
      before { sign_in general_user }

      it "shows all posts" do
        get admin_news_posts_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/news_posts/:id" do
    let(:news_post) { create(:news_post, user: admin_user) }

    before { sign_in admin_user }

    it "returns success" do
      get admin_news_post_path(news_post)
      expect(response).to have_http_status(:success)
    end

    it "displays the news post details" do
      get admin_news_post_path(news_post)
      expect(response.body).to include(news_post.title)
      expect(response.body).to include(news_post.content)
    end
  end

  describe "GET /admin/news_posts/new" do
    before { sign_in admin_user }

    it "returns success" do
      get new_admin_news_post_path
      expect(response).to have_http_status(:success)
    end

    it "renders the new form" do
      get new_admin_news_post_path
      expect(response.body).to include("form")
    end
  end

  describe "POST /admin/news_posts" do
    context "as admin user" do
      before { sign_in admin_user }

      context "with valid parameters" do
        let(:valid_params) do
          {
            news_post: {
              title: "Test News Post",
              content: "This is test content",
              post_type: "plain_text",
              location_id: location.id
            }
          }
        end

        it "creates a new news post" do
          expect {
            post admin_news_posts_path, params: valid_params
          }.to change(NewsPost, :count).by(1)
        end

        it "sets the current user as the author" do
          post admin_news_posts_path, params: valid_params
          news_post = NewsPost.last
          expect(news_post.user).to eq(admin_user)
        end

        it "redirects to news posts index" do
          post admin_news_posts_path, params: valid_params
          expect(response).to redirect_to(admin_news_posts_path)
        end

        it "displays success notice" do
          post admin_news_posts_path, params: valid_params
          follow_redirect!
          expect(response.body).to include(I18n.t('admin.news_posts.created'))
        end

        it "creates news post with correct attributes" do
          post admin_news_posts_path, params: valid_params
          news_post = NewsPost.last
          expect(news_post.title).to eq("Test News Post")
          expect(news_post.content).to eq("This is test content")
          expect(news_post.post_type).to eq("plain_text")
          expect(news_post.location_id).to eq(location.id)
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) do
          {
            news_post: {
              title: "",
              content: "",
              post_type: "plain_text"
            }
          }
        end

        it "does not create a new news post" do
          expect {
            post admin_news_posts_path, params: invalid_params
          }.not_to change(NewsPost, :count)
        end

        it "renders the new form again" do
          post admin_news_posts_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "creating a general post" do
        let(:general_params) do
          {
            news_post: {
              title: "General Post",
              content: "Content for everyone",
              post_type: "plain_text",
              location_id: nil
            }
          }
        end

        it "creates a general post without location" do
          post admin_news_posts_path, params: general_params
          news_post = NewsPost.last
          expect(news_post.location_id).to be_nil
          expect(news_post.general?).to be true
        end
      end
    end

    context "as location user" do
      before { sign_in location_user }

      it "automatically sets location to user's location" do
        params = {
          news_post: {
            title: "Location Post",
            content: "Content",
            post_type: "plain_text"
          }
        }

        post admin_news_posts_path, params: params
        news_post = NewsPost.last
        expect(news_post.location_id).to eq(location_user.location_id)
      end

      it "cannot create posts for other locations" do
        params = {
          news_post: {
            title: "Location Post",
            content: "Content",
            post_type: "plain_text",
            location_id: other_location.id
          }
        }

        post admin_news_posts_path, params: params
        news_post = NewsPost.last
        expect(news_post.location_id).to eq(location_user.location_id)
        expect(news_post.location_id).not_to eq(other_location.id)
      end
    end

    context "as general user" do
      before { sign_in general_user }

      it "creates posts without location (general posts)" do
        params = {
          news_post: {
            title: "General Post",
            content: "Content",
            post_type: "plain_text"
          }
        }

        post admin_news_posts_path, params: params
        news_post = NewsPost.last
        expect(news_post.location_id).to be_nil
      end
    end
  end

  describe "GET /admin/news_posts/:id/edit" do
    context "as admin user" do
      before { sign_in admin_user }

      let(:news_post) { create(:news_post, user: admin_user) }

      it "returns success" do
        get edit_admin_news_post_path(news_post)
        expect(response).to have_http_status(:success)
      end

      it "renders the edit form" do
        get edit_admin_news_post_path(news_post)
        expect(response.body).to include("form")
        expect(response.body).to include(news_post.title)
      end
    end

    context "as location user" do
      before { sign_in location_user }

      it "can edit own location's posts" do
        news_post = create(:news_post, location: location, user: location_user)
        get edit_admin_news_post_path(news_post)
        expect(response).to have_http_status(:success)
      end

      it "cannot edit other location's posts" do
        news_post = create(:news_post, location: other_location, user: other_location_user)
        get edit_admin_news_post_path(news_post)
        expect(response).to redirect_to(admin_news_posts_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "as general user" do
      before { sign_in general_user }

      it "can edit general posts" do
        news_post = create(:news_post, :general, user: general_user)
        get edit_admin_news_post_path(news_post)
        expect(response).to have_http_status(:success)
      end

      it "cannot edit location-specific posts" do
        news_post = create(:news_post, location: location, user: location_user)
        get edit_admin_news_post_path(news_post)
        expect(response).to redirect_to(admin_news_posts_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH /admin/news_posts/:id" do
    context "as admin user" do
      before { sign_in admin_user }

      let(:news_post) { create(:news_post, title: "Old Title", content: "Old content", user: admin_user) }

      context "with valid parameters" do
        let(:valid_params) do
          {
            news_post: {
              title: "Updated Title",
              content: "Updated content"
            }
          }
        end

        it "updates the news post" do
          patch admin_news_post_path(news_post), params: valid_params
          news_post.reload
          expect(news_post.title).to eq("Updated Title")
          expect(news_post.content).to eq("Updated content")
        end

        it "redirects to news posts index" do
          patch admin_news_post_path(news_post), params: valid_params
          expect(response).to redirect_to(admin_news_posts_path)
        end

        it "displays success notice" do
          patch admin_news_post_path(news_post), params: valid_params
          follow_redirect!
          expect(response.body).to include(I18n.t('admin.news_posts.updated'))
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) do
          {
            news_post: {
              title: "",
              content: ""
            }
          }
        end

        it "does not update the news post" do
          patch admin_news_post_path(news_post), params: invalid_params
          news_post.reload
          expect(news_post.title).to eq("Old Title")
          expect(news_post.content).to eq("Old content")
        end

        it "renders the edit form again" do
          patch admin_news_post_path(news_post), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "DELETE /admin/news_posts/:id" do
    context "as admin user" do
      before { sign_in admin_user }

      let(:news_post) { create(:news_post, user: admin_user) }

      it "deletes the news post" do
        news_post # Create the news post
        expect {
          delete admin_news_post_path(news_post)
        }.to change(NewsPost, :count).by(-1)
      end

      it "redirects to news posts index" do
        delete admin_news_post_path(news_post)
        expect(response).to redirect_to(admin_news_posts_path)
      end

      it "displays success notice" do
        delete admin_news_post_path(news_post)
        follow_redirect!
        expect(response.body).to include(I18n.t('admin.news_posts.deleted'))
      end
    end
  end

  describe "PATCH /admin/news_posts/:id/publish" do
    before { sign_in admin_user }

    let(:news_post) { create(:news_post, published: false, user: admin_user) }

    it "publishes the news post" do
      patch publish_admin_news_post_path(news_post)
      news_post.reload
      expect(news_post.published).to be true
      expect(news_post.published_at).to be_present
    end

    it "redirects to news posts index" do
      patch publish_admin_news_post_path(news_post)
      expect(response).to redirect_to(admin_news_posts_path)
    end

    it "displays success notice" do
      patch publish_admin_news_post_path(news_post)
      follow_redirect!
      expect(response.body).to include(I18n.t('admin.news_posts.published'))
    end
  end

  describe "PATCH /admin/news_posts/:id/unpublish" do
    before { sign_in admin_user }

    let(:news_post) { create(:news_post, :published, user: admin_user) }

    it "unpublishes the news post" do
      patch unpublish_admin_news_post_path(news_post)
      news_post.reload
      expect(news_post.published).to be false
    end

    it "redirects to news posts index" do
      patch unpublish_admin_news_post_path(news_post)
      expect(response).to redirect_to(admin_news_posts_path)
    end

    it "displays success notice" do
      patch unpublish_admin_news_post_path(news_post)
      follow_redirect!
      expect(response.body).to include(I18n.t('admin.news_posts.unpublished'))
    end
  end

  describe "PATCH /admin/news_posts/:id/archive" do
    before { sign_in admin_user }

    let(:news_post) { create(:news_post, :published, user: admin_user) }

    it "archives the news post and unpublishes it" do
      patch archive_admin_news_post_path(news_post)
      news_post.reload
      expect(news_post.archived).to be true
      expect(news_post.published).to be false
    end

    it "redirects to news posts index" do
      patch archive_admin_news_post_path(news_post)
      expect(response).to redirect_to(admin_news_posts_path)
    end

    it "displays success notice" do
      patch archive_admin_news_post_path(news_post)
      follow_redirect!
      expect(response.body).to include(I18n.t('admin.news_posts.archived'))
    end
  end

  describe "PATCH /admin/news_posts/:id/restore" do
    before { sign_in admin_user }

    let(:news_post) { create(:news_post, :archived, user: admin_user) }

    it "restores the news post from archive" do
      patch restore_admin_news_post_path(news_post)
      news_post.reload
      expect(news_post.archived).to be false
    end

    it "redirects to news posts index" do
      patch restore_admin_news_post_path(news_post)
      expect(response).to redirect_to(admin_news_posts_path)
    end

    it "displays success notice" do
      patch restore_admin_news_post_path(news_post)
      follow_redirect!
      expect(response.body).to include(I18n.t('admin.news_posts.restored'))
    end
  end

  describe "authorization" do
    context "location user accessing other location's post" do
      before { sign_in location_user }

      let(:other_post) { create(:news_post, location: other_location, user: other_location_user) }

      it "cannot edit" do
        get edit_admin_news_post_path(other_post)
        expect(response).to redirect_to(admin_news_posts_path)
      end

      it "cannot update" do
        patch admin_news_post_path(other_post), params: { news_post: { title: "Hacked" } }
        expect(response).to redirect_to(admin_news_posts_path)
        other_post.reload
        expect(other_post.title).not_to eq("Hacked")
      end

      it "cannot delete" do
        other_post # Create it
        expect {
          delete admin_news_post_path(other_post)
        }.not_to change(NewsPost, :count)
        expect(response).to redirect_to(admin_news_posts_path)
      end

      it "cannot publish" do
        patch publish_admin_news_post_path(other_post)
        expect(response).to redirect_to(admin_news_posts_path)
      end

      it "cannot archive" do
        patch archive_admin_news_post_path(other_post)
        expect(response).to redirect_to(admin_news_posts_path)
      end
    end

    context "general user accessing location-specific post" do
      before { sign_in general_user }

      let(:location_post) { create(:news_post, location: location, user: location_user) }

      it "cannot edit" do
        get edit_admin_news_post_path(location_post)
        expect(response).to redirect_to(admin_news_posts_path)
      end

      it "cannot update" do
        patch admin_news_post_path(location_post), params: { news_post: { title: "Hacked" } }
        expect(response).to redirect_to(admin_news_posts_path)
        location_post.reload
        expect(location_post.title).not_to eq("Hacked")
      end

      it "cannot delete" do
        location_post # Create it
        expect {
          delete admin_news_post_path(location_post)
        }.not_to change(NewsPost, :count)
        expect(response).to redirect_to(admin_news_posts_path)
      end
    end
  end

  describe "parameter filtering" do
    before { sign_in admin_user }

    it "only permits whitelisted parameters" do
      params = {
        news_post: {
          title: "Test Post",
          content: "Test content",
          post_type: "plain_text",
          location_id: location.id,
          unauthorized_param: "malicious value"
        }
      }

      post admin_news_posts_path, params: params
      news_post = NewsPost.last

      expect(news_post.title).to eq("Test Post")
      expect(news_post.content).to eq("Test content")
      expect(news_post.post_type).to eq("plain_text")
      expect(news_post).not_to respond_to(:unauthorized_param)
    end
  end
end