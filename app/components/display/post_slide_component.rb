module Display
  # Individual post slide component for carousel
  class PostSlideComponent < ApplicationViewComponent
    option :post
    option :index

    def render?
      post.present?
    end

    def slide_classes
      classes = %w[post-slide absolute inset-0 flex flex-col items-center justify-center
                   text-center]
      classes << (index.zero? ? "opacity-100" : "opacity-0")
      classes << (post.image_only? || post.pdf_only? ? "p-2 sm:p-3 md:p-5" : "p-4 sm:p-6 md:p-8")
      classes.join(" ")
    end

    def content_classes
      "leading-relaxed text-gray-800 max-h-[60vh] overflow-y-auto " \
        "notice-board-scroll text-[clamp(1.125rem,2.5vw,10rem)]"
    end

    def prose_classes
      "prose prose-sm sm:prose-base lg:prose-lg max-w-none"
    end
  end
end
