# frozen_string_literal: true

require "rails_helper"

RSpec.describe RssFeedItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:rss_feed) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:rss_feed) }
  end

  describe "scopes" do
    let(:feed) { create(:rss_feed) }
    let!(:recent_item) { create(:rss_feed_item, rss_feed: feed, published_at: 1.hour.ago) }
    let!(:old_item) { create(:rss_feed_item, rss_feed: feed, published_at: 1.week.ago) }
    let!(:newest_item) { create(:rss_feed_item, rss_feed: feed, published_at: 10.minutes.ago) }

    describe ".ordered" do
      it "returns items ordered by published_at descending" do
        expect(RssFeedItem.ordered).to eq([newest_item, recent_item, old_item])
      end
    end

    describe ".recent" do
      it "limits results to specified number" do
        expect(RssFeedItem.recent(2)).to eq([newest_item, recent_item])
      end

      it "defaults to 50 items" do
        expect(RssFeedItem.recent.limit_value).to eq(50)
      end
    end
  end

  describe "#display_text" do
    it "returns feed item title" do
      feed = create(:rss_feed, name: "Tech News")
      item = create(:rss_feed_item, rss_feed: feed, title: "Breaking News")

      expect(item.display_text).to eq("Breaking News")
    end
  end
end