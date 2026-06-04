# frozen_string_literal: true

class MealDiary < ApplicationRecord
  belongs_to :user
  has_many :meals, dependent: :destroy

  validates :diary_date, presence: true

  accepts_nested_attributes_for :meals, reject_if: :all_blank, allow_destroy: true

  scope :authorized_user, ->(user) { where(user_id: user.id) }
end
