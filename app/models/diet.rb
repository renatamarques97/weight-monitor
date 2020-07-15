class Diet < ApplicationRecord
  belongs_to :user

  validates :initial_weight, presence: true, numericality: { only_integer: true }
  validates :target_weight, presence: true, numericality: { only_integer: true }
  validates :start_date, presence: true
  validates :end_date, presence: true
end
