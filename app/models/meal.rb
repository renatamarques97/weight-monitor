# frozen_string_literal: true

class Meal < ApplicationRecord
  belongs_to :diet, optional: true
  belongs_to :meal_diary, optional: true
  has_many :meal_foods, dependent: :destroy

  validates :schedule, presence: true
  validates :description, presence: true
  validates :meal_type, presence: true
  validate :diet_or_meal_diary_presence

  accepts_nested_attributes_for :meal_foods, reject_if: :all_blank, allow_destroy: true

  extend Enumerize

  enumerize :meal_type, in: {
    breakfast: 0,
    brunch: 1,
    lunch: 2,
    linner: 3,
    dinner: 4,
    supper: 5
  }

  private

  def diet_or_meal_diary_presence
    return if diet.present? || meal_diary.present?

    errors.add(:base, 'Meal must belong to a diet or meal diary')
  end
end
