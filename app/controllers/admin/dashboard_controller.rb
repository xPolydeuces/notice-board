# frozen_string_literal: true

module Admin
  # Dashboard controller for admin panel home page
  class DashboardController < BaseController
    def index
      @stats = {
        users_count: User.count,
        locations_count: Location.count,
        news_posts_count: NewsPost.count,
        rss_feeds_count: RssFeed.count
      }
    end
  end
end
