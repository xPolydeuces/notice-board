FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :general }
    location { nil }

    trait :general do
      role { :general }
      location { nil }
    end

    trait :location do
      role { :location }
      location
    end

    trait :admin do
      role { :admin }
      location { nil }
    end

    trait :superadmin do
      role { :superadmin }
      location { nil }
    end

    trait :with_location do
      location
    end
  end
end
