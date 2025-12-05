module Admin
  # Navigation component for admin sidebar
  class NavigationComponent < ApplicationViewComponent
    option :current_user, Types.Instance(User)

    def navigation_items
      # Memoize to avoid rebuilding array on multiple calls during render
      @navigation_items ||= build_navigation_items
    end

    private

    def build_navigation_items
      items = [dashboard_item]
      items.concat(admin_only_items) if current_user.admin_or_superadmin?
      items.concat(content_management_items) if can_manage_content?
      items
    end

    def dashboard_item
      { name: t(".dashboard"), path: admin_root_path, icon: "layout-dashboard" }
    end

    def admin_only_items
      [
        { name: t(".users"), path: admin_users_path, icon: "users" },
        { name: t(".locations"), path: admin_locations_path, icon: "map-pin" }
      ]
    end

    def content_management_items
      [
        { name: t(".news_posts"), path: admin_news_posts_path, icon: "newspaper" },
        { name: t(".rss_feeds"), path: admin_rss_feeds_path, icon: "rss" }
      ]
    end

    def can_manage_content?
      current_user.admin_or_superadmin? || current_user.general?
    end

    public

    def current_page?(path)
      request.path == path || request.path.start_with?("#{path}/")
    end
  end
end
