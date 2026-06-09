FactoryBot.define do
  factory :weight do
    value { rand(50..200) }
    weight_date { Date.current }
    association :user
  end
end
