# frozen_string_literal: true

require "rss"
require "net/http"
require "resolv"

module RssFeeds
  # Service to fetch and parse RSS feeds
  class FetchService
    OPEN_TIMEOUT = 10
    READ_TIMEOUT = 15
    MAX_REDIRECTS = 3
    MAX_RESPONSE_SIZE = 5.megabytes

    # Private IP ranges to block (SSRF protection)
    PRIVATE_IP_RANGES = [
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
      IPAddr.new("127.0.0.0/8"),
      IPAddr.new("0.0.0.0/8"),
      IPAddr.new("169.254.0.0/16"),
      IPAddr.new("::1/128"),
      IPAddr.new("fc00::/7"),
      IPAddr.new("fe80::/10")
    ].freeze

    attr_reader :rss_feed, :errors

    def initialize(rss_feed:)
      @rss_feed = rss_feed
      @errors = []
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

    def success?
      @success == true
    end

    def items_count
      @items_count || 0
    end

    private

    def fetch_and_parse_feed
      uri = URI.parse(rss_feed.url)

      return handle_failure(:invalid_url, "Invalid URL scheme") unless uri.is_a?(URI::HTTP)
      return handle_failure(:private_ip, "URL resolves to private IP") if private_ip?(uri.host)

      content = fetch_with_redirects(uri)
      return handle_failure(:empty_response, "Empty response from feed") if content.blank?

      parsed_rss = RSS::Parser.parse(content, false)
      return handle_failure(:parse_error, "Failed to parse RSS feed") unless parsed_rss

      items_created = process_feed_items(parsed_rss)
      rss_feed.mark_as_fetched!

      success(items_created)
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      handle_failure(:timeout, "Request timed out: #{e.message}")
    rescue RSS::Error => e
      handle_failure(:rss_parse_error, "RSS Parse Error: #{e.message}")
    rescue SocketError, Errno::ECONNREFUSED => e
      handle_failure(:connection_error, "Connection failed: #{e.message}")
    end

    def fetch_with_redirects(uri, redirect_count = 0)
      return handle_failure(:too_many_redirects, "Too many redirects") if redirect_count >= MAX_REDIRECTS

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER if http.use_ssl?

      request = Net::HTTP::Get.new(uri.request_uri)
      request["User-Agent"] = "NoticeBoard RSS Reader"

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        validate_response_size(response.body)
      when Net::HTTPRedirection
        redirect_uri = URI.parse(response["location"])
        redirect_uri = URI.join(uri.to_s, redirect_uri) unless redirect_uri.host
        return handle_failure(:private_ip, "Redirect to private IP") if private_ip?(redirect_uri.host)

        fetch_with_redirects(redirect_uri, redirect_count + 1)
      else
        handle_failure(:http_error, "HTTP Error: #{response.code} #{response.message}")
        nil
      end
    end

    def private_ip?(hostname)
      return true if hostname.nil?
      return true if %w[localhost].include?(hostname.downcase)

      ips = Resolv.getaddresses(hostname)
      ips.any? { |ip| PRIVATE_IP_RANGES.any? { |range| range.include?(IPAddr.new(ip)) } }
    rescue Resolv::ResolvError
      true # If we can't resolve, assume private
    end

    def validate_response_size(body)
      if body.bytesize > MAX_RESPONSE_SIZE
        handle_failure(:response_too_large, "Response exceeds maximum size")
        nil
      else
        body
      end
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

    def handle_failure(reason, message)
      rss_feed.mark_as_failed!(message)
      failure(reason, message)
    end
  end
end