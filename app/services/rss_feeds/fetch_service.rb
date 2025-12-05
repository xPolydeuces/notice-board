require "rss"
require "open-uri"

module RssFeeds
  # Service to fetch and parse RSS feeds
  class FetchService < ApplicationService
    attr_reader :rss_feed

    def initialize(rss_feed:)
      super()
      @rss_feed = rss_feed
    end

    def call
      return failure(:feed_inactive) unless rss_feed.active?

      fetch_and_parse_feed
    rescue StandardError => e
      error_message = "#{e.class}: #{e.message}"
      Rails.logger.error("RSS Feed fetch failed for #{rss_feed.name}: #{error_message}")
      rss_feed.mark_as_failed!(error_message)
      failure(:fetch_error, error_message)
    end

    def items_count
      @items_count || 0
    end

    private

    def fetch_and_parse_feed
      content = URI.open(rss_feed.url, "User-Agent" => "NoticeBoard RSS Reader").read
      parsed_rss = RSS::Parser.parse(content, false)

      return handle_failure(:parse_error, "Failed to parse RSS feed") unless parsed_rss

      items_created = process_feed_items(parsed_rss)
      rss_feed.mark_as_fetched!

      success(items_created)
    rescue OpenURI::HTTPError => e
      handle_failure(:http_error, "HTTP Error: #{e.message}")
    rescue RSS::Error => e
      handle_failure(:rss_parse_error, "RSS Parse Error: #{e.message}")
    end

    def process_feed_items(parsed_rss)
      items_count = 0

      # Preload existing items to avoid N+1 queries
      existing_guids = rss_feed.rss_feed_items.pluck(:guid).to_set

      parsed_rss.items.each do |item|
        guid = item.guid&.content || item.link

        # Skip if item already exists
        next if existing_guids.include?(guid)

        feed_item = rss_feed.rss_feed_items.build(
          guid: guid,
          title: item.title,
          description: item.description,
          link: item.link,
          published_at: item.pubDate || item.dc_date || Time.current
        )

        if feed_item.save
          items_count += 1
          existing_guids.add(guid)
        else
          Rails.logger.warn("Failed to save RSS item: #{feed_item.errors.full_messages.join(', ')}")
        end
      end

      items_count
    end

    def success(items_count = 0)
      @items_count = items_count
      super()
    end

    def handle_failure(reason, message)
      rss_feed.mark_as_failed!(message)
      failure(reason, message)
    end
  end
end
