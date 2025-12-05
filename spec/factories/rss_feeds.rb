FactoryBot.define do
  factory :rss_feed do
    sequence(:name) { |n| "RSS Feed #{n}" }
    sequence(:url) { |n| "https://example.com/feed#{n}.rss" }
    active { true }
    last_fetched_at { nil }

    trait :inactive do
      active { false }
    end

    trait :fetched do
      last_fetched_at { 30.minutes.ago }
    end

    trait :stale do
      last_fetched_at { 2.hours.ago }
    end
  end
end
