require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }
  let(:location) { create(:location) }

  describe "GET /index" do
    context "without location parameter" do
      let!(:posts) { create_list(:news_post, 3, :published, :general, user: user) }
      let(:feed) { create(:rss_feed) }
      let!(:rss_items) { create_list(:rss_feed_item, 2, rss_feed: feed) }

      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "displays general announcements" do
        get root_path
        expect(response.body).to include("Ogłoszenia Ogólne")
        posts.each do |post|
          expect(response.body).to include(post.title)
        end
      end

      it "displays RSS feed item titles" do
        get root_path
        rss_items.each do |item|
          expect(response.body).to include(item.title)
        end
      end

      it "displays location section with prompt message" do
        get root_path
        expect(response.body).to include("Ogłoszenia Oddziałowe")
        expect(response.body).to include("Wybierz oddział")
      end
    end

    context "with location parameter" do
      let!(:general_posts) { create_list(:news_post, 2, :published, :general, user: user) }
      let!(:location_posts) { create_list(:news_post, 3, :published, user: user, location: location) }
      let(:feed) { create(:rss_feed) }
      let!(:rss_items) { create_list(:rss_feed_item, 2, rss_feed: feed) }

      it "returns http success" do
        get root_path, params: { location_id: location.id }
        expect(response).to have_http_status(:success)
      end

      it "displays location-specific announcements" do
        get root_path, params: { location_id: location.id }

        expect(response.body).to include("Ogłoszenia - #{location.name}")
        location_posts.each do |post|
          expect(response.body).to include(post.title)
        end
      end

      it "displays general announcements" do
        get root_path, params: { location_id: location.id }

        general_posts.each do |post|
          expect(response.body).to include(post.title)
        end
      end
    end

    context "with invalid location parameter" do
      it "returns success and shows default location message" do
        get root_path, params: { location_id: 99_999 }

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Wybierz oddział")
      end
    end

    context "post filtering" do
      let!(:published_posts) do
        [
          create(:news_post, :published, :general, user: user, published_at: 1.day.ago),
          create(:news_post, :published, :general, user: user, published_at: 2.days.ago)
        ]
      end
      let!(:unpublished_post) { create(:news_post, :unpublished, :general, user: user) }
      let!(:archived_post) { create(:news_post, :archived, :general, user: user) }

      it "only displays published and active posts" do
        get root_path

        published_posts.each do |post|
          expect(response.body).to include(post.title)
        end

        expect(response.body).not_to include(unpublished_post.title)
        expect(response.body).not_to include(archived_post.title)
      end

      it "displays posts ordered by published date (most recent first)" do
        get root_path

        # Check that the more recent post appears before the older one in the HTML
        recent_pos = response.body.index(published_posts.first.title)
        older_pos = response.body.index(published_posts.last.title)

        expect(recent_pos).to be < older_pos
      end

      it "limits to 10 posts maximum" do
        create_list(:news_post, 15, :published, :general, user: user)

        get root_path

        # Count carousel slides in the response
        expect(response.body.scan("data-slide").count).to eq(10)
      end
    end

    context "RSS feed item filtering" do
      let!(:active_feeds) { create_list(:rss_feed, 3) }
      let!(:inactive_feeds) { create_list(:rss_feed, 2, :inactive) }
      let!(:active_items) do
        active_feeds.map { |feed| create(:rss_feed_item, rss_feed: feed, title: "Active #{feed.name}") }
      end
      let!(:inactive_items) do
        inactive_feeds.map { |feed| create(:rss_feed_item, rss_feed: feed, title: "Inactive #{feed.name}") }
      end

      it "only displays items from active RSS feeds" do
        get root_path

        active_items.each do |item|
          expect(response.body).to include(item.title)
        end

        inactive_items.each do |item|
          expect(response.body).not_to include(item.title)
        end
      end

      it "displays items ordered by published date" do
        feed = create(:rss_feed)
        older_item = create(:rss_feed_item, rss_feed: feed, title: "Older Item", published_at: 2.hours.ago)
        newer_item = create(:rss_feed_item, rss_feed: feed, title: "Newer Item", published_at: 1.hour.ago)

        get root_path

        # Check that newer item appears before older item in the HTML
        newer_pos = response.body.index(newer_item.title)
        older_pos = response.body.index(older_item.title)

        expect(newer_pos).to be < older_pos
      end
    end

    context "content rendering" do
      let!(:post) { create(:news_post, :published, :general, user: user, title: "Test Announcement") }
      let(:feed) { create(:rss_feed, name: "Test Feed") }
      let!(:rss_item) { create(:rss_feed_item, rss_feed: feed, title: "Test Item") }

      it "renders carousel components" do
        get root_path

        expect(response.body).to include("Ogłoszenia Ogólne")
        expect(response.body).to include("Ogłoszenia Oddziałowe")
        expect(response.body).to include("Test Announcement")
      end

      it "renders marquee component" do
        get root_path

        expect(response.body).to include("Test Item")
        expect(response.body).to include("RSS:")
      end

      it "includes Stimulus controller" do
        get root_path

        expect(response.body).to include("data-controller=\"notice-board display-mode\"")
      end

      it "sets up carousel and marquee targets" do
        get root_path

        expect(response.body).to include("data-notice-board-target=\"carousel\"")
        expect(response.body).to include("data-notice-board-target=\"marquee\"")
      end
    end

    context "with different post types" do
      let!(:plain_post) do
        create(:news_post, :published, :general, :plain_text,
               user: user,
               title: "Plain Text Post",
               content: "Simple text content")
      end

      let!(:rich_post) do
        create(:news_post, :published, :general, :rich_text,
               user: user,
               title: "Rich Text Post")
      end

      it "renders plain text posts" do
        get root_path

        expect(response.body).to include("Plain Text Post")
        expect(response.body).to include("Simple text content")
      end

      it "renders rich text posts with prose classes" do
        get root_path

        expect(response.body).to include("Rich Text Post")
        expect(response.body).to include("prose")
      end
    end
  end
end
