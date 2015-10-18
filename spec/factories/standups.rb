FactoryGirl.define do
  factory :standup do
    user
    channel

    trait :idle do
      state Standup::IDLE
    end

    trait :active do
      state Standup::ACTIVE
    end

    trait :answering do
      state Standup::ANSWERING
    end

    trait :completed do
      state Standup::COMPLETED
    end
  end
end
