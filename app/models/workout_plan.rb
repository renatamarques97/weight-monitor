# frozen_string_literal: true

class WorkoutPlan < ApplicationRecord
  belongs_to :user
  belongs_to :physical_educator, class_name: 'User'
  has_many :sessions, class_name: 'WorkoutPlanSession', dependent: :destroy

  validates :start_date, :end_date, presence: true
  validate :end_date_not_before_start_date

  accepts_nested_attributes_for :sessions, allow_destroy: true, reject_if: :all_blank

  private

  def end_date_not_before_start_date
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, 'must be on or after start date') if end_date < start_date
  end
end
