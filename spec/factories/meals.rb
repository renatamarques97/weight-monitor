FactoryBot.define do
  factory :meal do
    schedule { "2020-07-15 20:02:58" }
    description { "Description" }
    meal_type { rand(0..3) }
    association :diet
  end
end
