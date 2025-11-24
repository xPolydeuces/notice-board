# frozen_string_literal: true

module Admin
  # Navigation component for admin sidebar
  class NavigationComponent < ApplicationViewComponent
    option :current_user, Types.Instance(User)

    def navigation_items
      # Memoize to avoid rebuilding array on multiple calls during render
      @navigation_items ||= begin
        items = []

        # Dashboard - everyone
        items << { name: t(".dashboard"), path: admin_root_path, icon: "layout-dashboard" }

        # Users - admin only
        items << { name: t(".users"), path: admin_users_path, icon: "users" } if current_user.admin_or_superadmin?

        # Locations - admin only
        if current_user.admin_or_superadmin?
          items << { name: t(".locations"), path: admin_locations_path,
                     icon: "map-pin" }
        end

        # News Posts - admin and general
        if current_user.admin_or_superadmin? || current_user.general?
          items << { name: t(".news_posts"), path: admin_news_posts_path,
                     icon: "newspaper" }
        end

        # RSS Feeds - admin and general
        if current_user.admin_or_superadmin? || current_user.general?
          items << { name: t(".rss_feeds"), path: admin_rss_feeds_path,
                     icon: "rss" }
        end

        items
      end
    end

    def current_page?(path)
      request.path == path || request.path.start_with?("#{path}/")
    end
  end
end
