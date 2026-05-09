# frozen_string_literal: true

class Tennis < Workout
  attribute :details, Details::Tennis.to_type
end
