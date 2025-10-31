# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_news_posts: NewsPost.active.count,
        published_posts: NewsPost.published.active.count,
        draft_posts: NewsPost.unpublished.active.count,
        total_users: User.count,
        total_locations: Location.active.count
      }
    end
  end
end
