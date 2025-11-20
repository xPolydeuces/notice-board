# frozen_string_literal: true

module RssFeeds
  # Job to fetch all active RSS feeds that need refresh
  # Skips critically unhealthy feeds (3+ consecutive errors)
  class FetchAllJob < ApplicationJob
    queue_as :default

    def perform
      feeds_to_fetch = RssFeed.active.healthy.where("
        last_fetched_at IS NULL OR
        last_fetched_at < ?
      ", 1.hour.ago)

      Rails.logger.info("RSS FetchAllJob: Found #{feeds_to_fetch.count} feeds to fetch")

      feeds_to_fetch.find_each do |feed|
        FetchJob.perform_async(feed.id)
      end
    end
  end
end