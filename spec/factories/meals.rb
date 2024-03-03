# frozen_string_literal: true

FactoryBot.define do
  factory :meal do
    schedule { "2023-01-01 20:02:58" }
    description { "Description" }
    meal_type { rand(0..5) }
    association :diet
  end
end
