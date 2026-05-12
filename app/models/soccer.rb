# frozen_string_literal: true

class Soccer < Workout
  attribute :details, Details::Soccer.to_type
end
