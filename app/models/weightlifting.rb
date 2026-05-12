# frozen_string_literal: true

class Weightlifting < Workout
  attribute :details, Details::Weightlifting.to_type
end
