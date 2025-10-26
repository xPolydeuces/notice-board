FactoryBot.define do
  factory :user_role do
    user
    role

    trait :admin do
      role { Role.find_by(name: "Admin") || create(:role, name: "Admin") }
    end

    trait :teacher do
      role { Role.find_by(name: "Teacher") || create(:role, name: "Teacher") }
    end
  end
end
