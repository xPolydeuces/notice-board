# frozen_string_literal: true

module Display
  # Carousel box component for notice board display
  class CarouselBoxComponent < ApplicationViewComponent
    option :title, Types::String
    option :posts
    option :empty_message, Types::String
    option :box_classes, Types::String.optional, default: -> { '' }

    def render?
      title.present?
    end

    def has_posts?
      posts.any?
    end

    def show_dots?
      posts.count > 1
    end
  end
end