class GoalPresenter
  def initialize(user)
    @user = user
  end

  def achieved?
    weight = user.weights.last
    diet = user.diets.last
    return false if weight.nil? || diet.nil?
    return weight.value == diet.target_weight if weight.weight_unit == diet.weight_unit

    target_weight = UnitConverter.convert_weight_between(diet.target_weight, diet.weight_unit, weight.weight_unit)
    weight.value == target_weight
  end

  private

  attr_reader :user
end
