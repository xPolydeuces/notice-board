# frozen_string_literal: true

module Admin
  # Page header component for admin pages
  class PageHeaderComponent < ApplicationViewComponent
    option :title, Types::String
    option :subtitle, Types::String.optional, default: -> { nil }
    option :icon, Types::String.optional, default: -> { nil }

    def render?
      title.present?
    end
  end
end
