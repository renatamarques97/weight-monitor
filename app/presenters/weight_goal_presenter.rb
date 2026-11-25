# frozen_string_literal: true

# Progress from the diet's initial weight to its target, using the latest weight converted
# to the diet's unit. A diet that keeps the weight is achieved within a small tolerance.
class WeightGoalPresenter
  MAINTENANCE_TOLERANCE_KG = 0.5

  def initialize(user)
    @user = user
  end

  def achieved?
    progress_percent >= 100
  end

  def progress_percent
    current_weight = last_weight
    initial = initial_weight
    target = target_weight

    return 0 unless goal_values_present?(current_weight, initial, target)

    calculate_progress(current_weight, initial, target)
  end

  def initial_weight
    current_diet&.initial_weight
  end

  def target_weight
    current_diet&.target_weight
  end

  private

  attr_reader :user

  def goal_values_present?(current_weight, initial_weight, target_weight)
    [current_weight, initial_weight, target_weight].all?
  end

  def calculate_progress(current_weight, initial_weight, target_weight)
    distance = target_weight - initial_weight
    return maintenance_progress(current_weight, target_weight) if distance.zero?

    progress = (current_weight - initial_weight).to_f / distance * 100
    progress.clamp(0, 100).round
  end

  def maintenance_progress(current_weight, target_weight)
    (current_weight - target_weight).abs <= maintenance_tolerance ? 100 : 0
  end

  def maintenance_tolerance
    UnitConverter.convert_weight_between(MAINTENANCE_TOLERANCE_KG, MeasurementUnits::WEIGHTS::KG,
                                         current_diet.weight_unit)
  end

  def last_weight
    weight = RecentWeightPresenter.new(user).call
    return if weight.nil? || current_diet.nil?

    UnitConverter.convert_weight_between(weight.value, weight.weight_unit, current_diet.weight_unit)
  end

  def current_diet
    user.current_diet
  end
end
