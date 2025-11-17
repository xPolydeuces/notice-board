# frozen_string_literal: true

module Display
  # RSS marquee component for notice board display
  class MarqueeComponent < ApplicationViewComponent
    option :rss_feeds
    option :logo_url, Types::String.optional, default: -> { nil }

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