# frozen_string_literal: true

module RssFeeds
  # Job to fetch all active RSS feeds that need refresh
  class FetchAllJob < ApplicationJob
    queue_as :default

    def perform
      RssFeed.active.find_each do |feed|
        next unless feed.needs_refresh?

        FetchJob.perform_later(feed.id)
      end
    end
  end
end