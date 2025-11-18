# frozen_string_literal: true

module Display
  # RSS marquee component for notice board display
  class MarqueeComponent < ViewComponent::Base
    attr_reader :rss_feeds, :logo_url

    def initialize(rss_feeds:, logo_url: nil)
      @rss_feeds = rss_feeds
      @logo_url = logo_url
    end

    def render?
      true
    end

    def has_logo?
      logo_url.present?
    end

    def marquee_text
      if rss_feeds.any?
        "RSS: #{rss_feeds.map(&:name).join(' • ')}"
      else
        'Bardzo ważne informacje z Warszawy, pobierane z RSS'
      end
    end
  end
end