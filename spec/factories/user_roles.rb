FactoryBot.define do
  factory :user_role do
    user
    role

    trait :admin do
      role { Role.admin }
    end

    trait :teacher do
      role { Role.teacher }
    end
  end
end
