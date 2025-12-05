module Display
  # RSS marquee component for notice board display
  class MarqueeComponent < ApplicationViewComponent
    option :rss_feed_items
    option :logo_url, default: proc {}

    def render?
      true
    end

    def logo?
      logo_url.present?
    end

    def marquee_text
      if rss_feed_items.any?
        "RSS: #{rss_feed_items.map(&:display_text).join(' • ')}"
      else
        "Bardzo ważne informacje z Warszawy, pobierane z RSS"
      end
    end
  end
end
