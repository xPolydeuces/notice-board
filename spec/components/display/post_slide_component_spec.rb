# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::PostSlideComponent, type: :component do
  let(:user) { create(:user) }

  describe "rendering" do
    context "with plain text post" do
      let(:post) do
        create(:news_post, :published, :plain_text, user: user, title: "Test Title", content: "Test Content")
      end

      it "renders the post title" do
        render_inline(described_class.new(post: post, index: 0))

        expect(page).to have_text("Test Title")
      end

      it "renders the post content" do
        render_inline(described_class.new(post: post, index: 0))

        expect(page).to have_text("Test Content")
      end

      it "renders the published date" do
        render_inline(described_class.new(post: post, index: 0))

        expect(page).to have_css(".text-gray-600")
        # Uses responsive clamp() sizing instead of fixed text-2xl
      end

      it "applies correct opacity for first slide" do
        render_inline(described_class.new(post: post, index: 0))

        expect(page).to have_css(".opacity-100")
        expect(page).to have_no_css(".opacity-0")
      end

      it "applies correct opacity for non-first slide" do
        render_inline(described_class.new(post: post, index: 1))

        expect(page).to have_css(".opacity-0")
        expect(page).to have_no_css(".opacity-100")
      end
    end

    context "with rich text post" do
      let(:post) { create(:news_post, :published, :rich_text, user: user, title: "Rich Post") }

      it "renders rich content" do
        render_inline(described_class.new(post: post, index: 0))

        expect(page).to have_css(".prose")
      end

      it "applies prose classes for rich text" do
        render_inline(described_class.new(post: post, index: 0))

        expect(page).to have_css(".prose-sm")
        # Uses responsive prose sizing: prose-sm sm:prose-base lg:prose-lg
      end
    end

    context "with image-only post" do
      let(:post) { create(:news_post, :published, :image_only, user: user) }

      it "renders the image when attached" do
        render_inline(described_class.new(post: post, index: 0))

        expect(page).to have_css("img")
      end

      it "applies image-only padding" do
        render_inline(described_class.new(post: post, index: 0))

        # Uses responsive padding: p-2 sm:p-3 md:p-5
        expect(page).to have_css(".md\\:p-5")
      end

      it "does not render title or content" do
        render_inline(described_class.new(post: post, index: 0))

        expect(page).to have_no_css(".text-6xl")
      end
    end
  end

  describe "#render?" do
    let(:post) { create(:news_post, :published, user: user) }

    it "returns true when post is present" do
      component = described_class.new(post: post, index: 0)
      expect(component.render?).to be true
    end

    it "returns false when post is nil" do
      component = described_class.new(post: nil, index: 0)
      expect(component.render?).to be false
    end
  end

  describe "#slide_classes" do
    let(:post) { create(:news_post, :published, :plain_text, user: user) }

    it "includes base slide classes" do
      component = described_class.new(post: post, index: 0)
      classes = component.slide_classes

      expect(classes).to include("post-slide")
      expect(classes).to include("absolute")
      expect(classes).to include("inset-0")
    end

    it "includes opacity-100 for index 0" do
      component = described_class.new(post: post, index: 0)
      expect(component.slide_classes).to include("opacity-100")
    end

    it "includes opacity-0 for non-zero index" do
      component = described_class.new(post: post, index: 1)
      expect(component.slide_classes).to include("opacity-0")
    end

    it "includes responsive padding for image-only posts" do
      image_post = create(:news_post, :published, :image_only, user: user)
      component = described_class.new(post: image_post, index: 0)
      # Uses responsive padding: p-2 sm:p-3 md:p-5
      expect(component.slide_classes).to include("p-2")
      expect(component.slide_classes).to include("md:p-5")
    end

    it "includes responsive padding for non-image posts" do
      component = described_class.new(post: post, index: 0)
      # Uses responsive padding: p-4 sm:p-6 md:p-8
      expect(component.slide_classes).to include("p-4")
      expect(component.slide_classes).to include("md:p-8")
    end
  end

  describe "data attributes" do
    let(:post) { create(:news_post, :published, user: user) }

    it "sets data-slide attribute" do
      render_inline(described_class.new(post: post, index: 0))

      expect(page).to have_css("[data-slide]")
    end

    it "sets data-index attribute" do
      render_inline(described_class.new(post: post, index: 2))

      expect(page).to have_css("[data-index='2']")
    end
  end
end
