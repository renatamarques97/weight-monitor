# frozen_string_literal: true

class Workout < ApplicationRecord
  belongs_to :user
  belongs_to :workout_plan_session, optional: true

  self.inheritance_column = :workout_type

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Workout')
  end

  enum :workout_type, WorkoutType::MAPPING

  def self.find_sti_class(type_name)
    type_label = if type_name.to_s.match?(/\A\d+\z/)
                   workout_types.key(type_name.to_i)
                 else
                   type_name
                 end

    type_label.to_s.camelize.constantize
  end

  def self.sti_name
    key = name.underscore.to_sym
    WorkoutType::MAPPING[key] || super
  end

  validates :workout_type, presence: true
  validates :workout_date, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :strava_activity_id,
            uniqueness: { scope: :user_id },
            allow_nil: true
  validate :planned_session_matches_execution
  validates :workout_plan_session_id, uniqueness: true, allow_nil: true

  enum :distance_unit, { km: DISTANCES::KM, mi: DISTANCES::MI }, prefix: true, validate: true
  enum :weight_unit, { kg: WEIGHTS::KG, lbs: WEIGHTS::LBS }, prefix: true, validate: true

  private

  def planned_session_matches_execution
    return unless workout_plan_session

    if workout_plan_session.workout_plan.user_id != user_id
      errors.add(:workout_plan_session, 'must belong to the workout user')
    elsif workout_plan_session.session_date != workout_date
      errors.add(:workout_plan_session, 'must match the workout date')
    end
  end
end
