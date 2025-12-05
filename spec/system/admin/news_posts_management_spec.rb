require "rails_helper"

RSpec.describe "News Posts Management", type: :system do
  let(:admin) { create(:user, :admin) }
  let(:location_user) { create(:user, :location) }
  let(:location) { create(:location) }

  before do
    driven_by(:rack_test)
  end

  describe "News posts index" do
    before do
      sign_in admin
      create_list(:news_post, 3, :published)
      create(:news_post, published: false)
    end

    it "displays all news posts" do
      visit admin_news_posts_path

      expect(page).to have_content("News Post Title")
      expect(page).to have_css("tbody tr", count: 4)
    end

    it "shows published status" do
      visit admin_news_posts_path

      # Check within tbody to avoid counting filter dropdown options
      within("tbody") do
        expect(page).to have_content("Published", count: 3)
        expect(page).to have_content("Draft", count: 1)
      end
    end
  end

  describe "Creating a news post" do
    before { sign_in admin }

    context "with plain text content" do
      it "creates a new news post successfully" do
        visit new_admin_news_post_path

        fill_in "Title", with: "My New Post"
        select "Plain text", from: "Post type"
        fill_in "Content", with: "This is the content of my post"

        click_button "Create News post"

        expect(page).to have_content("News post was successfully created")
        expect(NewsPost.last.title).to eq("My New Post")
        expect(NewsPost.last.content).to eq("This is the content of my post")
      end
    end

    context "with invalid data" do
      it "shows validation errors" do
        visit new_admin_news_post_path

        fill_in "Title", with: ""
        click_button "Create News post"

        expect(page).to have_content("can't be blank").or have_content("error")
      end
    end
  end

  describe "Editing a news post" do
    let(:news_post) { create(:news_post, title: "Original Title") }

    before { sign_in admin }

    it "updates the news post successfully" do
      visit edit_admin_news_post_path(news_post)

      fill_in "Title", with: "Updated Title"
      click_button "Update News post"

      expect(page).to have_content("News post was successfully updated")
      expect(news_post.reload.title).to eq("Updated Title")
    end
  end

  describe "Deleting a news post" do
    let!(:news_post) { create(:news_post, title: "Post to Delete") }

    before { sign_in admin }

    it "deletes the news post" do
      visit admin_news_posts_path

      expect(page).to have_content("Post to Delete")

      # Find and click the delete button (rack_test doesn't support accept_confirm)
      within("tr", text: "Post to Delete") do
        find("button[title='Delete']").click
      end

      expect(page).to have_no_content("Post to Delete")
      expect(NewsPost.exists?(news_post.id)).to be false
    end
  end

  describe "Publishing a news post" do
    let!(:news_post) { create(:news_post, published: false) }

    before { sign_in admin }

    it "publishes the news post" do
      visit admin_news_posts_path

      within("tr", text: news_post.title) do
        find("button[title='Publish']").click
      end

      expect(page).to have_content("News post was successfully published")
      expect(news_post.reload.published).to be true
    end
  end

  describe "Archiving a news post" do
    let!(:news_post) { create(:news_post, :published) }

    before { sign_in admin }

    it "archives the news post" do
      visit admin_news_posts_path

      within("tr", text: news_post.title) do
        find("button[title='Archive']").click
      end

      expect(page).to have_content("News post was successfully archived")
      expect(news_post.reload.archived).to be true
    end
  end

  describe "Location-specific posts" do
    let(:location_user_with_location) { create(:user, role: :location, location: location) }

    before { sign_in location_user_with_location }

    it "location user can only create posts for their location" do
      visit new_admin_news_post_path

      expect(page).to have_field("Location", disabled: true)
      expect(page).to have_content(location.full_name)
    end
  end

  describe "General user restrictions" do
    let(:general_user) { create(:user, :general) }

    before { sign_in general_user }

    it "general user can create general posts" do
      visit new_admin_news_post_path

      fill_in "Title", with: "General Post"
      select "Plain text", from: "Post type"
      fill_in "Content", with: "General content"

      click_button "Create News post"

      expect(page).to have_content("News post was successfully created")
      expect(NewsPost.last.location).to be_nil
    end
  end
end
