# frozen_string_literal: true

class Basketball < Workout
  attribute :details, Details::Basketball.to_type
end
