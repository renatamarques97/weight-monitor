# frozen_string_literal: true

FactoryBot.define do
  factory :meal_food do
    food_name { FFaker::Food.meat }
    metric_serving_amount { rand(50..300) }
    metric_serving_unit { "g" }
    calories { rand(8..100) }
    protein { rand(1.0..10.0).round(1) }
    carbs { rand(20.0..50.0).round(1) }
    fat { rand(0.0..5.0).round(1) }
    association :meal
  end
end
