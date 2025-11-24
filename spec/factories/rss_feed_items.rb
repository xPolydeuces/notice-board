# frozen_string_literal: true

FactoryBot.define do
  factory :rss_feed_item do
    rss_feed
    sequence(:title) { |n| "RSS Item #{n}" }
    sequence(:description) { |n| "Description for RSS item #{n}" }
    sequence(:link) { |n| "https://example.com/item-#{n}" }
    sequence(:guid) { |n| "guid-#{n}" }
    published_at { 1.hour.ago }

    trait :recent do
      published_at { 10.minutes.ago }
    end

    trait :old do
      published_at { 1.week.ago }
    end

    trait :without_description do
      description { nil }
    end
  end
end
