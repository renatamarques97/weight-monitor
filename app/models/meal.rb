# frozen_string_literal: true

class Meal < ApplicationRecord
  belongs_to :diet

  validates :schedule, presence: true
  validates :description, presence: true
  validates :meal_type, presence: true

  extend Enumerize

  enumerize :meal_type, in: {
    breakfast: 0,
    brunch: 1,
    lunch: 2,
    linner: 3,
    dinner: 4,
    supper: 5
  }
end
