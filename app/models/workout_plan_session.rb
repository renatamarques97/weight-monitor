# frozen_string_literal: true

class WorkoutPlanSession < ApplicationRecord
  belongs_to :workout_plan
  has_one :workout, dependent: :nullify

  enum :workout_type, WorkoutType::MAPPING

  enum :distance_unit, { km: DISTANCES::KM, mi: DISTANCES::MI }, prefix: true, validate: true
  enum :weight_unit, { kg: WEIGHTS::KG, lbs: WEIGHTS::LBS }, prefix: true, validate: true

  validates :session_date, :workout_type, presence: true
  validates :session_date, uniqueness: { scope: :workout_plan_id }
  validates :duration, numericality: { greater_than: 0 }, allow_nil: true
  validates :distance, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :session_date_within_plan

  private

  def session_date_within_plan
    return unless workout_plan && session_date

    return if session_date.between?(workout_plan.start_date, workout_plan.end_date)

    errors.add(:session_date, 'must be within the workout plan period')
  end
end
