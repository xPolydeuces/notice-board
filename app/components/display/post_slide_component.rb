# frozen_string_literal: true

module Display
  # Individual post slide component for carousel
  class PostSlideComponent < ViewComponent::Base
    attr_reader :post, :index

    def initialize(post:, index:)
      @post = post
      @index = index
    end

    def render?
      post.present?
    end

    def slide_classes
      classes = ['post-slide', 'absolute', 'inset-0', 'flex', 'flex-col', 'items-center', 'justify-center', 'text-center']
      classes << (index.zero? ? 'opacity-100' : 'opacity-0')
      classes << (post.image_only? ? 'p-5' : 'p-10')
      classes.join(' ')
    end

    def content_classes
      'text-4xl leading-relaxed text-gray-800 max-h-[60vh] overflow-y-auto notice-board-scroll'
    end

    def prose_classes
      'prose prose-2xl max-w-none'
    end
  end
end