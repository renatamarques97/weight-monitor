class Meal < ApplicationRecord
  belongs_to :diet

  validates :schedule, presence: true
  validates :description, presence: true
  validates :meal_type, presence: true

  extend Enumerize

  enumerize :meal_type, in: { breakfast: 0, lunch: 1, dinner: 2, supper: 3 }
end
