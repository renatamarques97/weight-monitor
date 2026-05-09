# frozen_string_literal: true

class WeightQuery
  def self.weights(user, period_in_days = nil)
    weights = user.weights

    if period_in_days.present?
      weights = weights.where(weight_date: period_in_days.days.ago.to_date..)
    end

    weights.order(weight_date: :asc, created_at: :asc)
           .group_by(&:weight_date)
           .transform_values { |weight| weight.last.kg }
  end
end
