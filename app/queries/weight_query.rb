# frozen_string_literal: true

class WeightQuery
  def self.weights(user)
    most_recent_weight = user.weights
    .order(weight_date: :desc, created_at: :desc)
    .take

    return {} if most_recent_weight.blank?

    { most_recent_weight.weight_date => most_recent_weight.kg }
  end
end
