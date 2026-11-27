# frozen_string_literal: true

class WorkoutPlanSessionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @session = WorkoutPlanSession.find(params.expect(:id))
    plan = @session.workout_plan

    unless WorkoutPlanPolicy.new(current_user, plan).view?
      render file: 'public/404.html', status: :unauthorized
    end
  end
end
