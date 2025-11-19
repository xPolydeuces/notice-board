# frozen_string_literal: true

module RssFeeds
  # Job to fetch a single RSS feed
  class FetchJob < ApplicationJob
    queue_as :default

    sidekiq_options retry: 3

    # Sidekiq exponential backoff retry
    sidekiq_retry_in do |count|
      10 * (2**count) # 10, 20, 40 seconds
    end

    def perform(rss_feed_id)
      feed = RssFeed.find(rss_feed_id)
      result = FetchService.new(rss_feed: feed).call

      if result.success?
        Rails.logger.info("Successfully fetched #{result.items_count} items for RSS feed: #{feed.name}")
      else
        Rails.logger.error("Failed to fetch RSS feed #{feed.name}: #{result.errors.join(', ')}")
      end
    end
  end
end