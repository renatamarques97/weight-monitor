# frozen_string_literal: true

class Swimming < Workout
  attribute :details, Details::Swimming.to_type

  validates :distance, numericality: { greater_than: 0 }, allow_nil: true
  validates :details, store_model: true
end
