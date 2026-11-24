# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @period_in_days = params[:period_in_days]&.to_i || 30
    @active_tab = params[:active_tab] || 'weight'
    assign_dashboard_data
  end

  def assign_dashboard_data
    assign_presenter_data
    assign_weight_data
    assign_workout_data
  end

  def assign_presenter_data
    @goal = ::GoalPresenter.new(current_user).achieved?
    @recent_weight = ::RecentWeightPresenter.new(current_user).call
    @diets = ::Diet.authorized_user(current_user)
    @imc = ::ImcPresenter.new(current_user).call
  end

  def assign_weight_data
    @recent_weights = current_user.weights.order(weight_date: :desc, created_at: :desc).limit(3)
    @weights = ::WeightQuery.weights_for_chart(current_user, @period_in_days)
    @weight_chart_bounds = build_weight_chart_bounds(@weights)
  end

  def assign_workout_data
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
