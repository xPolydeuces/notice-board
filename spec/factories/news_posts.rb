FactoryBot.define do
  factory :news_post do
    user
    location { create(:location) } # Default: create with a location
    sequence(:title) { |n| "News Post Title #{n}" }
    content { "This is the content of the news post." }
    post_type { :plain_text }
    published { false }
    archived { false }

    trait :published do
      published { true }
      published_at { Time.current }
    end

    trait :unpublished do
      published { false }
      published_at { nil }
    end

    trait :archived do
      archived { true }
      published { false }
    end

    trait :general do
      location { nil }
    end

    trait :plain_text do
      post_type { :plain_text }
      content { "This is plain text content." }
    end

    trait :rich_text do
      post_type { :rich_text }
      content { nil }
      after(:build) do |post|
        post.rich_content = ActionText::RichText.new(body: "<p>Rich text content</p>")
      end
    end

    trait :image_only do
      post_type { :image_only }
      content { nil }
      title { "Image Post" }
      after(:build) do |post|
        post.image.attach(
          io: Rails.root.join("spec/fixtures/files/test_image.png").open,
          filename: "test_image.png",
          content_type: "image/png"
        )
      end
    end

    trait :pdf_only do
      post_type { :pdf_only }
      content { nil }
      title { "PDF Post" }
      after(:build) do |post|
        post.pdf.attach(
          io: StringIO.new("%PDF-1.4 fake pdf content"),
          filename: "test_document.pdf",
          content_type: "application/pdf"
        )
      end
    end
  end
end
