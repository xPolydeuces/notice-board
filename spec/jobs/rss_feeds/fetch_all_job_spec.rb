# frozen_string_literal: true

require "rails_helper"

RSpec.describe RssFeeds::FetchAllJob, type: :job do
  describe "#perform" do
    let!(:feed_needing_refresh) { create(:rss_feed, last_fetched_at: 2.hours.ago) }
    let!(:feed_recently_fetched) { create(:rss_feed, :fetched) }
    let!(:inactive_feed) { create(:rss_feed, :inactive, last_fetched_at: 2.hours.ago) }

    it "enqueues fetch jobs for feeds needing refresh" do
      expect do
        described_class.new.perform
      end.to have_enqueued_job(RssFeeds::FetchJob).with(feed_needing_refresh.id)
    end

    it "does not enqueue jobs for recently fetched feeds" do
      expect do
        described_class.new.perform
      end.not_to have_enqueued_job(RssFeeds::FetchJob).with(feed_recently_fetched.id)
    end

    it "does not enqueue jobs for inactive feeds" do
      expect do
        described_class.new.perform
      end.not_to have_enqueued_job(RssFeeds::FetchJob).with(inactive_feed.id)
    end
  end
end