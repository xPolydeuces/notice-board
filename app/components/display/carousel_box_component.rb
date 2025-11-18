# frozen_string_literal: true

module Display
  # Carousel box component for notice board display
  class CarouselBoxComponent < ViewComponent::Base
    attr_reader :title, :posts, :empty_message, :box_classes

    def initialize(title:, posts:, empty_message:, box_classes: '')
      @title = title
      @posts = posts
      @empty_message = empty_message
      @box_classes = box_classes
    end

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