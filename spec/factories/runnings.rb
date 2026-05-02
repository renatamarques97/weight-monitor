FactoryBot.define do
  factory :running do
    duration { rand(20.0..60.0).round(1) }
    distance { rand(3.0..12.0).round(1) }
    running_date { Date.current }
    association :user
  end
end
