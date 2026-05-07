# frozen_string_literal: true

class Running < Workout
  attribute :details, Details::Running.to_type

  validates :distance, presence: true, numericality: { greater_than: 0 }

  before_save :calculate_average_pace

  def calculate_average_pace
    self.details.avg_pace = ((self.duration / 60) / self.distance).round(2)
  end
end
