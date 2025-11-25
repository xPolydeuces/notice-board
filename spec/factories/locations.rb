FactoryBot.define do
  factory :location do
    sequence(:code) { |n| "LOC-#{n}" }
    name { Faker::Address.city }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :with_users do
      transient do
        users_count { 3 }
      end

      after(:create) do |location, evaluator|
        create_list(:user, evaluator.users_count, location: location)
      end
    end

    trait :with_news_posts do
      transient do
        news_posts_count { 5 }
      end

      after(:create) do |location, evaluator|
        create_list(:news_post, evaluator.news_posts_count, location: location)
      end
    end
  end
end
