FactoryGirl.define do
  factory :channel do
    name     { Faker::Name.name }
    slack_id { Faker::Number.number(10) }
  end
end
