# frozen_string_literal: true

class WorkoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workout, only: %i[edit update destroy]

  def index
    @workouts = current_user.workouts
    @workouts = @workouts.where(workout_type: params[:type]) if params[:type].present?
    @workouts = @workouts.order(workout_date: :desc)
  end

  def new
    workout_type = params[:workout_type] || WorkoutType::OTHER

    @workout = Workout.new(workout_type: workout_type, workout_date: Date.current)
  end

  def edit
  end

  def create
    @workout = Workout.new(workout_params)
    @workout.user = current_user

    if @workout.save
      flash[:notice] = t('workout.created')
      redirect_to(root_path)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @workout.update(workout_params)
      flash[:notice] = t('workout.updated')
      redirect_to(workouts_path)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @workout.destroy
    flash[:notice] = t('workout.destroyed')
    redirect_to(workouts_path)
  end

  private

  def set_workout
    @workout = current_user.workouts.find(params[:id])
  end

  def workout_params
    params.require(:workout).permit(
      :duration, :distance, :calories, :workout_date, :workout_type,
      details: {}
    )
  end
end
