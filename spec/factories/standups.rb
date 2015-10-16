FactoryGirl.define do
  factory :standup do
    user_id { create(:user).user_id }
  end
end
