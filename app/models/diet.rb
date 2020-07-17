class Diet < ApplicationRecord
  belongs_to :user
  has_many :meals

  validates :initial_weight, presence: true
  validates :target_weight, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates_numericality_of :initial_weight, greater_than: 0
  validates_numericality_of :target_weight, greater_than: 0

  accepts_nested_attributes_for :meals, reject_if: :all_blank, allow_destroy: true
end
