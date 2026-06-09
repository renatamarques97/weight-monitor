# frozen_string_literal: true

FactoryBot.define do
  factory :meal do
    schedule { DateTime.current }
    description { FFaker::Lorem.sentence }
    meal_type { rand(0..5) }
    association :diet
  end

  trait :with_meals do
    after(:create) do |record|
      meal_hours = {
        breakfast: 7,
        brunch: 10,
        lunch: 12,
        linner: 15,
        dinner: 19,
        supper: 22
      }

      Meal.meal_type.values.each do |meal_type|
        description = ""

        if record.is_a?(Diet)
          description = "This is a #{meal_type} for a diet starting on #{record.start_date} with target weight #{record.target_weight}#{record.weight_unit}."
        elsif record.is_a?(MealDiary)
          description = "This is a #{meal_type} entry for a meal diary on #{record.diary_date}."
        end

        attributes = {
          meal_type: meal_type,
          schedule: Time.current.change(hour: meal_hours[meal_type.to_sym], min: 0),
          description: description,
          :diet => record.is_a?(Diet) ? record : nil,
          :meal_diary => record.is_a?(MealDiary) ? record : nil
        }

        meal = create(:meal, **attributes)

        create_list(:meal_food, rand(1..3), meal: meal)
      end
    end
  end
end
