# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::MarqueeComponent, type: :component do
  describe "rendering" do
    context "with RSS feed items" do
      let(:feed1) { create(:rss_feed, name: "Tech News") }
      let(:feed2) { create(:rss_feed, name: "Sports") }
      let!(:item1) { create(:rss_feed_item, rss_feed: feed1, title: "Breaking Tech") }
      let!(:item2) { create(:rss_feed_item, rss_feed: feed2, title: "Game Results") }
      let!(:item3) { create(:rss_feed_item, rss_feed: feed1, title: "New Release") }
      let(:items) { [item1, item2, item3] }

      it "renders RSS feed item display text" do
        render_inline(described_class.new(rss_feed_items: items))

        expect(page).to have_text("Tech News: Breaking Tech")
        expect(page).to have_text("Sports: Game Results")
        expect(page).to have_text("Tech News: New Release")
      end

      it "separates items with bullets" do
        render_inline(described_class.new(rss_feed_items: items))

        expect(page).to have_text("•")
      end

      it "sets up marquee target for Stimulus" do
        render_inline(described_class.new(rss_feed_items: items))

        expect(page).to have_css("[data-notice-board-target='marquee']")
      end

      it "sets up marquee content target for Stimulus" do
        render_inline(described_class.new(rss_feed_items: items))

        expect(page).to have_css("[data-notice-board-target='marqueeContent']")
      end
    end

    context "with logo URL" do
      let(:items) { create_list(:rss_feed_item, 2) }
      let(:logo_url) { "https://example.com/logo.png" }

      it "renders the logo image" do
        render_inline(described_class.new(rss_feed_items: items, logo_url: logo_url))

        expect(page).to have_css("img[alt='Logo']")
        expect(page).to have_css("img[src='#{logo_url}']")
      end

      it "applies logo container styles" do
        render_inline(described_class.new(rss_feed_items: items, logo_url: logo_url))

        expect(page).to have_css(".flex-shrink-0")
      end
    end

    context "without logo URL" do
      let(:items) { create_list(:rss_feed_item, 2) }

      it "does not render logo section" do
        render_inline(described_class.new(rss_feed_items: items))

        expect(page).not_to have_css("img[alt='Logo']")
      end
    end

    context "with no RSS feed items" do
      it "renders fallback message" do
        render_inline(described_class.new(rss_feed_items: []))

        expect(page).to have_text("Bardzo ważne informacje z Warszawy, pobierane z RSS")
      end

      it "does not show RSS prefix" do
        render_inline(described_class.new(rss_feed_items: []))

        expect(page).not_to have_text("RSS:")
      end
    end
  end

  describe "#render?" do
    it "always returns true" do
      component = described_class.new(rss_feed_items: [])
      expect(component.render?).to be true
    end
  end

  describe "#has_logo?" do
    it "returns true when logo_url is present" do
      component = described_class.new(rss_feed_items: [], logo_url: "https://example.com/logo.png")
      expect(component.has_logo?).to be true
    end

    it "returns false when logo_url is nil" do
      component = described_class.new(rss_feed_items: [], logo_url: nil)
      expect(component.has_logo?).to be false
    end

    it "returns false when logo_url is blank" do
      component = described_class.new(rss_feed_items: [], logo_url: "")
      expect(component.has_logo?).to be false
    end
  end

  describe "#marquee_text" do
    context "with RSS feed items" do
      let(:feed1) { create(:rss_feed, name: "News Feed") }
      let(:feed2) { create(:rss_feed, name: "Blog Feed") }
      let!(:item1) { create(:rss_feed_item, rss_feed: feed1, title: "Article One") }
      let!(:item2) { create(:rss_feed_item, rss_feed: feed2, title: "Post Two") }
      let!(:item3) { create(:rss_feed_item, rss_feed: feed1, title: "Article Three") }
      let(:items) { [item1, item2, item3] }

      it "returns RSS prefix with item display text joined by bullets" do
        component = described_class.new(rss_feed_items: items)
        expect(component.marquee_text).to eq("RSS: News Feed: Article One • Blog Feed: Post Two • News Feed: Article Three")
      end

      it "handles single item" do
        component = described_class.new(rss_feed_items: [item1])
        expect(component.marquee_text).to eq("RSS: News Feed: Article One")
      end
    end

    context "without RSS feed items" do
      it "returns fallback message" do
        component = described_class.new(rss_feed_items: [])
        expect(component.marquee_text).to eq("Bardzo ważne informacje z Warszawy, pobierane z RSS")
      end
    end
  end

  describe "CSS classes" do
    let(:items) { create_list(:rss_feed_item, 2) }

    it "applies background color" do
      render_inline(described_class.new(rss_feed_items: items))

      expect(page).to have_css(".bg-\\[\\#FEF3E2\\]")
    end

    it "applies flex layout" do
      render_inline(described_class.new(rss_feed_items: items))

      expect(page).to have_css(".flex")
      expect(page).to have_css(".flex-1")
    end

    it "applies text styling to marquee content" do
      render_inline(described_class.new(rss_feed_items: items))

      expect(page).to have_css(".text-8xl")
      expect(page).to have_css(".font-bold")
    end
  end
end