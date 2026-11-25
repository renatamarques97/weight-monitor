# frozen_string_literal: true

class Running < Workout
  attribute :details, Details::Running.to_type

  validates :distance, presence: true, numericality: { greater_than: 0 }

  before_save :calculate_average_pace

  private

  def calculate_average_pace
    details.avg_pace = PaceFormatter.call(duration, distance)
  end
end
