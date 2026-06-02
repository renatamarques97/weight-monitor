# frozen_string_literal: true

class MealFood < ApplicationRecord
  belongs_to :meal

  validates :food_name, presence: true
  validates :metric_serving_amount, numericality: { greater_than: 0 }, allow_nil: true
end
