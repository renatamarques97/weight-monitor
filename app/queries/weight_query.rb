# frozen_string_literal: true

class WeightQuery
  WEIGHT_DATE = "weights.weight_date"
  WEIGHT_KG = "weights.kg"

  def self.weights(user)
    user.weights.group(WEIGHT_DATE).sum(WEIGHT_KG)
  end
end
