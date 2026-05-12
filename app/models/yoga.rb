# frozen_string_literal: true

class Yoga < Workout
  attribute :details, Details::Yoga.to_type

  validates :details, store_model: true
end
