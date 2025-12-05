module Display
  # Carousel box component for notice board display
  class CarouselBoxComponent < ApplicationViewComponent
    option :title
    option :posts
    option :empty_message
    option :box_classes, default: -> { "" }

    def render?
      title.present?
    end

    def any_posts?
      posts.any?
    end

    def show_dots?
      posts.many?
    end
  end
end
