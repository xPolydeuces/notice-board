# frozen_string_literal: true

require "rails_helper"

RSpec.describe RssFeed, type: :model do
  it_behaves_like "a valid factory"
  
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }

    it "validates URL format" do
      expect(build(:rss_feed, url: "https://example.com/feed.rss")).to be_valid
      expect(build(:rss_feed, url: "http://example.com/feed.xml")).to be_valid
      expect(build(:rss_feed, url: "not-a-url")).not_to be_valid
      expect(build(:rss_feed, url: "ftp://example.com")).not_to be_valid
    end
  end

  describe "scopes" do
    describe ".active" do
      let!(:active_feed) { create(:rss_feed, active: true) }
      let!(:inactive_feed) { create(:rss_feed, :inactive) }

      it "returns only active feeds" do
        expect(RssFeed.active).to include(active_feed)
        expect(RssFeed.active).not_to include(inactive_feed)
      end
    end

    describe ".ordered" do
      let!(:feed_c) { create(:rss_feed, name: "Zebra Feed") }
      let!(:feed_a) { create(:rss_feed, name: "Apple Feed") }
      let!(:feed_b) { create(:rss_feed, name: "Middle Feed") }

      it "returns feeds ordered by name" do
        expect(RssFeed.ordered).to eq([feed_a, feed_b, feed_c])
      end
    end
  end

  describe "#mark_as_fetched!" do
    let(:feed) { create(:rss_feed, last_fetched_at: nil) }

    it "updates last_fetched_at to current time" do
      freeze_time do
        expect { feed.mark_as_fetched! }
          .to change(feed, :last_fetched_at).from(nil).to(Time.current)
      end
    end

    it "persists the change to the database" do
      feed.mark_as_fetched!
      expect(feed.reload.last_fetched_at).not_to be_nil
    end
  end

  describe "#needs_refresh?" do
    context "when never fetched" do
      let(:feed) { create(:rss_feed, last_fetched_at: nil) }

      it "returns true" do
        expect(feed.needs_refresh?).to be true
      end
    end

    context "when fetched recently (within 1 hour)" do
      let(:feed) { create(:rss_feed, :fetched) }

      it "returns false" do
        expect(feed.needs_refresh?).to be false
      end
    end

    context "when fetched more than 1 hour ago" do
      let(:feed) { create(:rss_feed, :stale) }

      it "returns true" do
        expect(feed.needs_refresh?).to be true
      end
    end

    context "when fetched exactly 1 hour ago" do
      let(:feed) { create(:rss_feed, last_fetched_at: 1.hour.ago) }

      it "returns false" do
        expect(feed.needs_refresh?).to be false
      end
    end
  end
end