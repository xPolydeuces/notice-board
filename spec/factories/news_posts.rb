FactoryBot.define do
  factory :news_post do
    association :user
    association :location, optional: true
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    post_type { :text }
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