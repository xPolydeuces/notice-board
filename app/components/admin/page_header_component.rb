module Admin
  # Page header component for admin pages
  class PageHeaderComponent < ApplicationViewComponent
    option :title, Types::String
    option :subtitle, Types::String.optional, default: proc {}
    option :icon, Types::String.optional, default: proc {}

    def render?
      title.present?
    end
  end
end
