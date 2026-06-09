# frozen_string_literal: true

class Running < Workout
  attribute :details, Details::Running.to_type

  validates :distance, presence: true, numericality: { greater_than: 0 }

  before_save :calculate_average_pace

  private

  def calculate_average_pace
    return unless duration.present? && distance.present?

    duration_in_seconds = UnitConverter.convert_time_between(duration, TIMES::MINUTES, TIMES::SECONDS)
    pace_in_seconds = (duration_in_seconds / distance).round
    pace_minutes, pace_seconds = pace_in_seconds.divmod(60)
    self.details.avg_pace = format("%d'%02d\"", pace_minutes, pace_seconds)
  end
end
