# frozen_string_literal: true

class Cycling < Workout
  attribute :details, Details::Cycling.to_type

  validates :distance, presence: true, numericality: { greater_than: 0 }
end
