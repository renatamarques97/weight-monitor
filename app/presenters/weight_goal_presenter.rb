# frozen_string_literal: true

class WeightGoalPresenter
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
    return 100 if distance.zero?

    progress = (current_weight - initial_weight).to_f / distance * 100
    progress.clamp(0, 100).round
  end

  def last_weight
    user.weights.order(weight_date: :desc, created_at: :desc).first&.kg
  end

  def current_diet
    user.diets.order(start_date: :desc, created_at: :desc).first
  end
end
