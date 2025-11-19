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
      end.to change(RssFeeds::FetchJob.jobs, :size).by(1)

      expect(RssFeeds::FetchJob.jobs.last["args"]).to eq([feed_needing_refresh.id])
    end

    it "does not enqueue jobs for recently fetched feeds" do
      expect do
        described_class.new.perform
      end.to change(RssFeeds::FetchJob.jobs, :size).by(1) # Only the needing refresh feed

      # Should not include the recently fetched feed
      expect(RssFeeds::FetchJob.jobs.map { |job| job["args"].first }).not_to include(feed_recently_fetched.id)
    end

    it "does not enqueue jobs for inactive feeds" do
      expect do
        described_class.new.perform
      end.to change(RssFeeds::FetchJob.jobs, :size).by(1) # Only the needing refresh feed

      # Should not include the inactive feed
      expect(RssFeeds::FetchJob.jobs.map { |job| job["args"].first }).not_to include(inactive_feed.id)
    end
  end
end