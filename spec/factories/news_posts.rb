FactoryBot.define do
  factory :news_post do
    association :user
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

    trait :archived do
      archived { true }
      published { false }
    end

    trait :general do
      location { nil }
    end

    trait :rich_text do
      post_type { :rich_text }
    end

    trait :image_only do
      post_type { :image_only }
    end
  end
end