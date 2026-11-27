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
    assign_weight_goal_data
    assign_recent_weight_data

    @nutrition_adherence = ::DietAdherencePresenter.new(current_user)
    @bmi = ::ImcPresenter.new(current_user).call
  end

  def assign_weight_goal_data
    presenter = ::WeightGoalPresenter.new(current_user)
    @weight_goal = presenter.achieved?
    @weight_goal_progress = presenter.progress_percent
    @weight_goal_initial = presenter.initial_weight
    @weight_goal_target = presenter.target_weight
  end

  def assign_recent_weight_data
    presenter = ::RecentWeightPresenter.new(current_user)
    @recent_weight = presenter.call
    @weight_trend_30_days = presenter.trend_30_days
  end

  def assign_weight_data
    @recent_weights = current_user.weights.order(weight_date: :desc, created_at: :desc).limit(3)
    @weights = ::WeightQuery.weights_for_chart(current_user, @period_in_days)
    @weight_chart_bounds = build_weight_chart_bounds(@weights)
  end

  def assign_workout_data
    assign_workout_charts
    assign_monthly_training_minutes
    assign_workout_plans
  end

  def assign_workout_charts
    @workout_charts = ::WorkoutQuery.chart_data(current_user, @period_in_days)
  end

  def assign_monthly_training_minutes
    @monthly_training_minutes = current_user.workouts
                                            .where(workout_date: Date.current.all_month)
                                            .sum(:duration)
                                            .round
  end

  def assign_workout_plans
    @workout_plans = visible_workout_plans
    @current_workout_plan = current_workout_plan || @workout_plans.first
    @workout_plan_sessions = workout_plan_sessions
  end

  def current_workout_plan
    @workout_plans
      .where('start_date <= ? AND end_date >= ?', Date.current, Date.current)
      .order(start_date: :desc)
      .first
  end

  def workout_plan_sessions
    return WorkoutPlanSession.none unless @current_workout_plan

    @current_workout_plan.sessions
                         .includes(:workout)
                         .where(session_date: Date.current..@current_workout_plan.end_date)
                         .order(:session_date)
                         .limit(7)
  end

  def visible_workout_plans
    if current_user.account_type_admin?
      WorkoutPlan.all
    elsif current_user.valid_physical_educator?
      WorkoutPlan.where(physical_educator: current_user)
    else
      current_user.workout_plans
    end.order(end_date: :desc, start_date: :desc)
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
