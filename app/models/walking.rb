# frozen_string_literal: true

class Walking < Workout
  attribute :details, Details::Walking.to_type

  validates :distance, presence: true, numericality: { greater_than: 0 }
end
