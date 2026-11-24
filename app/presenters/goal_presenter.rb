# frozen_string_literal: true

class GoalPresenter
  def initialize(user)
    @user = user
  end

  def achieved?
    return false if last_weight.nil? || last_diet.nil?

    last_weight.value == target_weight_in(last_weight.weight_unit)
  end

  private

  attr_reader :user

  def last_weight
    @last_weight ||= user.weights.last
  end

  def last_diet
    @last_diet ||= user.diets.last
  end

  # Diet and weight can be recorded in different units, so compare in the weight's unit.
  def target_weight_in(unit)
    return last_diet.target_weight if last_diet.weight_unit == unit

    UnitConverter.convert_weight_between(last_diet.target_weight, last_diet.weight_unit, unit)
  end
end
