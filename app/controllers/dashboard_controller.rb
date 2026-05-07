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
    @workout_charts = ::WorkoutQuery.chart_data(current_user, @period_in_days)
  end
end
