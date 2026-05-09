# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @period_in_days = params[:period_in_days]&.to_i || 30
    @active_tab = params[:active_tab] || 'weight'
    @goal = ::GoalPresenter.new(current_user).achieved?
    @diets = ::Diet.authorized_user(current_user)
    @imc = ::ImcPresenter.new(current_user).call
    @weights = ::WeightQuery.weights(current_user, @period_in_days)
    @weight_chart_bounds = build_weight_chart_bounds(@weights)
    @workout_charts = ::WorkoutQuery.chart_data(current_user, @period_in_days)
  end

  private

  def build_weight_chart_bounds(weights)
    values = weights.values.map(&:to_f)
    return {} if values.empty?

    min_weight = values.min
    max_weight = values.max

    step = 2


    {
      min: (min_weight / step).floor * step,
      max: (max_weight / step).ceil * step
    }
  end
end
