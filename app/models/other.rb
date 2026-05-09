# frozen_string_literal: true

class Other < Workout
  attribute :details, Details::Base.to_type
end
