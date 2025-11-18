# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::CarouselBoxComponent, type: :component do
  let(:user) { create(:user) }
  let(:posts) { create_list(:news_post, 3, :published, user: user) }

  describe "rendering" do
    context "with posts" do
      it "renders the component with title" do
        render_inline(described_class.new(
          title: "Test Announcements",
          posts: posts,
          empty_message: "No posts",
          box_classes: "flex-[65]"
        ))

        expect(page).to have_text("Test Announcements")
      end

      it "renders all post slides" do
        render_inline(described_class.new(
          title: "Test Announcements",
          posts: posts,
          empty_message: "No posts"
        ))

        posts.each do |post|
          expect(page).to have_css("[data-slide]", count: posts.length)
        end
      end

      it "renders navigation dots when there are multiple posts" do
        render_inline(described_class.new(
          title: "Test Announcements",
          posts: posts,
          empty_message: "No posts"
        ))

        expect(page).to have_css("[data-dots]")
        expect(page).to have_css("[data-dot]", count: posts.length)
      end

      it "applies custom box classes" do
        render_inline(described_class.new(
          title: "Test Announcements",
          posts: posts,
          empty_message: "No posts",
          box_classes: "custom-class"
        ))

        expect(page).to have_css(".custom-class")
      end

      it "sets up carousel target for Stimulus" do
        render_inline(described_class.new(
          title: "Test Announcements",
          posts: posts,
          empty_message: "No posts"
        ))

        expect(page).to have_css("[data-notice-board-target='carousel']")
      end
    end

    context "with single post" do
      let(:single_post) { [create(:news_post, :published, user: user)] }

      it "does not render navigation dots for single post" do
        render_inline(described_class.new(
          title: "Test Announcements",
          posts: single_post,
          empty_message: "No posts"
        ))

        expect(page).not_to have_css("[data-dots]")
      end
    end

    context "with no posts" do
      it "renders empty message" do
        render_inline(described_class.new(
          title: "Test Announcements",
          posts: [],
          empty_message: "No announcements available"
        ))

        expect(page).to have_text("No announcements available")
      end

      it "does not render slides or dots" do
        render_inline(described_class.new(
          title: "Test Announcements",
          posts: [],
          empty_message: "No posts"
        ))

        expect(page).not_to have_css("[data-slide]")
        expect(page).not_to have_css("[data-dots]")
      end
    end
  end

  describe "#render?" do
    it "returns true when title is present" do
      component = described_class.new(
        title: "Test",
        posts: [],
        empty_message: "No posts"
      )
      expect(component.render?).to be true
    end

    it "returns false when title is blank" do
      component = described_class.new(
        title: "",
        posts: [],
        empty_message: "No posts"
      )
      expect(component.render?).to be false
    end
  end

  describe "#has_posts?" do
    it "returns true when posts are present" do
      component = described_class.new(
        title: "Test",
        posts: posts,
        empty_message: "No posts"
      )
      expect(component.has_posts?).to be true
    end

    it "returns false when posts are empty" do
      component = described_class.new(
        title: "Test",
        posts: [],
        empty_message: "No posts"
      )
      expect(component.has_posts?).to be false
    end
  end

  describe "#show_dots?" do
    it "returns true when there are multiple posts" do
      component = described_class.new(
        title: "Test",
        posts: posts,
        empty_message: "No posts"
      )
      expect(component.show_dots?).to be true
    end

    it "returns false when there is only one post" do
      single_post = [create(:news_post, :published, user: user)]
      component = described_class.new(
        title: "Test",
        posts: single_post,
        empty_message: "No posts"
      )
      expect(component.show_dots?).to be false
    end

    it "returns false when there are no posts" do
      component = described_class.new(
        title: "Test",
        posts: [],
        empty_message: "No posts"
      )
      expect(component.show_dots?).to be false
    end
  end
end