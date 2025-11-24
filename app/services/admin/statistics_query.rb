# frozen_string_literal: true

module Admin
  class StatisticsQuery
    CACHE_KEY = "admin_dashboard_stats"
    CACHE_EXPIRY = 10.minutes

    def self.call
      new.call
    end

    def call
      Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) do
        fetch_statistics
      end
    end

    private

    def fetch_statistics
      # Optimized: Single query with subqueries instead of 4 separate COUNT queries
      result = ActiveRecord::Base.connection.select_one(<<~SQL.squish)
        SELECT
          (SELECT COUNT(*) FROM users) as users_count,
          (SELECT COUNT(*) FROM locations) as locations_count,
          (SELECT COUNT(*) FROM news_posts) as news_posts_count,
          (SELECT COUNT(*) FROM rss_feeds) as rss_feeds_count
      SQL

      result.transform_keys(&:to_sym).transform_values(&:to_i)
    end
  end
end
