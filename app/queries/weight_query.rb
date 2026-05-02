# frozen_string_literal: true

class WeightQuery
  def self.weights(user)
    user.weights
      .order(weight_date: :asc, id: :desc)
      .to_a
      .group_by(&:weight_date)
      .transform_values(&:first)
      .each_with_object({}) { |(date, w), acc| acc[date] = w.kg }
  end
end
