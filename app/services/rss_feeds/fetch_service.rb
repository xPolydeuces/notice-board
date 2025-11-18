# frozen_string_literal: true

require 'rss'
require 'open-uri'

module RssFeeds
  # Service to fetch and parse RSS feeds
  class FetchService
    attr_reader :rss_feed, :errors

    def initialize(rss_feed:)
      @rss_feed = rss_feed
      @errors = []
    end

    def call
      return failure(:feed_inactive) unless rss_feed.active?

      fetch_and_parse_feed
    rescue StandardError => e
      Rails.logger.error("RSS Feed fetch failed for #{rss_feed.name}: #{e.message}")
      failure(:fetch_error, e.message)
    end

    def success?
      @success == true
    end

    def items_count
      @items_count || 0
    end

    private

    def fetch_and_parse_feed
      content = URI.open(rss_feed.url, 'User-Agent' => 'NoticeBoard RSS Reader').read
      parsed_rss = RSS::Parser.parse(content, false)

      return failure(:parse_error) unless parsed_rss

      items_created = process_feed_items(parsed_rss)
      rss_feed.mark_as_fetched!

      success(items_created)
    rescue OpenURI::HTTPError => e
      failure(:http_error, e.message)
    rescue RSS::Error => e
      failure(:rss_parse_error, e.message)
    end

    def process_feed_items(parsed_rss)
      items_count = 0

      parsed_rss.items.each do |item|
        feed_item = rss_feed.rss_feed_items.find_or_initialize_by(
          guid: item.guid&.content || item.link
        )

        next unless feed_item.new_record?

        feed_item.assign_attributes(
          title: item.title,
          description: item.description,
          link: item.link,
          published_at: item.pubDate || item.dc_date || Time.current
        )

        if feed_item.save
          items_count += 1
        else
          Rails.logger.warn("Failed to save RSS item: #{feed_item.errors.full_messages.join(', ')}")
        end
      end

      items_count
    end

    def success(items_count)
      @success = true
      @items_count = items_count
      self
    end

    def failure(reason, message = nil)
      @success = false
      @errors << reason
      @errors << message if message
      self
    end
  end
end