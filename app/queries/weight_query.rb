# frozen_string_literal: true

class WeightQuery
  def self.weights(user, period_in_days = nil)
    weights = user.weights

    if period_in_days.present?
      weights = weights.where(weight_date: period_in_days.days.ago.to_date..)
    end

    weights.order(weight_date: :asc, created_at: :asc)
           .group_by(&:weight_date)
           .transform_values { |weight_records| weight_records.last }
  end

  # Return chart-ready hash: { date => value_in_preferred_unit }
  # Converts each record from its stored unit to the user's preferred display unit.
  def self.weights_for_chart(user, period_in_days = nil)
    target_unit = user.weight_unit
    self.weights(user, period_in_days).transform_values do |weight|
      UnitConverter.convert_weight_between(weight.value, weight.weight_unit, target_unit)
    end
  end
end
