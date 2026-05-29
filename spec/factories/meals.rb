# frozen_string_literal: true

FactoryBot.define do
  factory :meal do
    schedule { DateTime.current }
    description { FFaker::Lorem.sentence }
    meal_type { rand(0..5) }
    association :diet
  end
end
