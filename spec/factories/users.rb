FactoryGirl.define do
  factory :user do
    user_id   { Faker::Number.number(10) }
    full_name { Faker::Name.name }

    trait :admin do
      admin_user true
    end
  end
end
