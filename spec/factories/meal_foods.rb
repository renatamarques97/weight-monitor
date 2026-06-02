# frozen_string_literal: true

FactoryBot.define do
  factory :meal_food do
    food_name { 'Banana' }
    metric_serving_amount { 100 }
    metric_serving_unit { 'g' }
    calories { 89 }
    protein { 1.1 }
    carbs { 22.8 }
    fat { 0.3 }
    association :meal
  end
end
