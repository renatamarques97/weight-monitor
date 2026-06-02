# frozen_string_literal: true

FactoryBot.define do
  factory :meal_diary do
    diary_date { Date.current }
    notes { FFaker::Lorem.sentence }
    association :user
  end
end
