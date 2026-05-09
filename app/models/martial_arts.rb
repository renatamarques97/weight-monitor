# frozen_string_literal: true

class MartialArts < Workout
  attribute :details, Details::MartialArts.to_type

  validates :details, store_model: true
end
