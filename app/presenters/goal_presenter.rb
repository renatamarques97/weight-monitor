# frozen_string_literal: true

# The goal follows the direction of the current diet: losing weight is achieved at or
# below the target, gaining at or above it, and keeping it within a small tolerance.
class GoalPresenter
  MAINTENANCE_TOLERANCE_KG = 0.5

  def initialize(user)
    @user = user
  end

  def achieved?
    return false if diet.nil? || current_weight.nil?

    case direction
    when :lose then current_weight <= target_weight
    when :gain then current_weight >= target_weight
    else (current_weight - target_weight).abs <= maintenance_tolerance
    end
  end

  private

  attr_reader :user

  def direction
    return :lose if target_weight < diet.initial_weight
    return :gain if target_weight > diet.initial_weight

    :keep
  end

  def target_weight
    diet.target_weight
  end

  def diet
    @diet ||= user.diets.order(end_date: :desc, id: :desc).first
  end

  # Latest weight by date, converted to the diet's unit.
  def current_weight
    return @current_weight if defined?(@current_weight)

    weight = RecentWeightPresenter.new(user).call
    @current_weight = weight && UnitConverter.convert_weight_between(weight.value, weight.weight_unit, diet.weight_unit)
  end

  def maintenance_tolerance
    UnitConverter.convert_weight_between(MAINTENANCE_TOLERANCE_KG, MeasurementUnits::WEIGHTS::KG, diet.weight_unit)
  end
end
