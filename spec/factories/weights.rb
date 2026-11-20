# frozen_string_literal: true

FactoryBot.define do
  factory :weight do
    kg { rand(50..200) }
    weight_date { Date.current }
    association :user
  end
end
