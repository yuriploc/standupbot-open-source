FactoryGirl.define do
  factory :user do
    slack_id   { Faker::Number.number(10) }
    full_name { Faker::Name.name }

    trait :admin do
      admin true
    end
  end
end
