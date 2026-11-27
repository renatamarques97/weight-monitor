# frozen_string_literal: true

FactoryBot.define do
  factory :workout_plan_session do
    association :workout_plan
    session_date { Date.current }
    workout_type { :running }
    duration { 45 }
    distance { 5 }
    distance_unit { Units::DISTANCES::KM }
    weight_unit { Units::WEIGHTS::KG }
  end
end
