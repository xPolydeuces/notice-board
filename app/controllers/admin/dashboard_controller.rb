# frozen_string_literal: true

module Admin
  # Dashboard controller for admin panel home page
  class DashboardController < BaseController
    def index
      # Optimized: Single query with subqueries instead of 4 separate COUNT queries
      # Cached for 10 minutes since stats don't change frequently
      @stats = Rails.cache.fetch('admin_dashboard_stats', expires_in: 10.minutes) do
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
end
