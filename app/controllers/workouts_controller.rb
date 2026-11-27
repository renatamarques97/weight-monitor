# frozen_string_literal: true

class WorkoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workout, only: %i[edit update destroy]

  def index
    workouts = current_user.workouts
    workouts = workouts.where(workout_type: params[:type]) if params[:type].present?
    @pagy, @workouts = pagy(workouts.order(workout_date: :desc, created_at: :desc), limit: 20)
  end

  def new
    workout_type = params[:workout_type] || WorkoutType::OTHER
    session = planned_session_from_params

    @workout = Workout.new(workout_attributes(workout_type, session))
  end

  def edit; end

  def create
    @workout = Workout.new(workout_params)
    @workout.user = current_user

    if @workout.save
      flash[:notice] = t('workout.created')
      redirect_to(root_path)
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @workout.update(workout_params)
      flash[:notice] = t('workout.updated')
      redirect_to(workouts_path)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @workout.destroy
    flash[:notice] = t('workout.destroyed')
    redirect_to(workouts_path)
  end

  private

  def set_workout
    @workout = current_user.workouts.find(params.expect(:id))
  end

  def workout_params
    params.expect(
      workout: [:duration, :distance, :distance_unit, :weight_unit, :calories, :workout_date, :workout_type,
                :workout_plan_session_id, { details: {} }]
    )
  end

  def planned_session_from_params
    return unless params[:workout_plan_session_id]

    session = WorkoutPlanSession.find_by(id: params[:workout_plan_session_id])
    session if session&.workout_plan&.user_id == current_user.id
  end

  def workout_attributes(workout_type, session)
    {
      workout_type: session&.workout_type || workout_type,
      workout_plan_session: session,
      workout_date: session&.session_date || Date.current,
      duration: session&.duration,
      distance: session&.distance,
      distance_unit: session&.distance_unit || current_user.distance_unit,
      weight_unit: session&.weight_unit || current_user.weight_unit,
      details: session&.details || {}
    }
  end
end
