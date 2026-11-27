# frozen_string_literal: true

class WorkoutPlansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plan, only: %i[show edit update destroy]

  def index
    plans = if current_user.account_type_admin?
              WorkoutPlan.all
            elsif current_user.valid_physical_educator?
              WorkoutPlan.where(physical_educator: current_user)
            else
              current_user.workout_plans
            end
    @pagy, @workout_plans = pagy(plans.order(start_date: :desc, created_at: :desc), limit: 20)
  end

  def show
    return if WorkoutPlanPolicy.new(current_user, @plan).view?

    render file: 'public/404.html', status: :unauthorized
  end

  def new
    target = client_from_params
    return unauthorized_new unless can_create_for?(target)

    @workout_plan = target.workout_plans.build(
      physical_educator: current_user,
      start_date: Date.current,
      end_date: Date.current + 4.weeks
    )
  end

  def edit
    return if WorkoutPlanPolicy.new(current_user, @plan).manage?

    render file: 'public/404.html', status: :unauthorized
  end

  def create
    target = client_from_params_for_create
    return unauthorized_new unless can_create_for?(target)

    @workout_plan = target.workout_plans.build(plan_params)
    @workout_plan.physical_educator = current_user

    save_workout_plan
  end

  def update
    unless WorkoutPlanPolicy.new(current_user, @plan).manage?
      render file: 'public/404.html', status: :unauthorized
      return
    end

    if @plan.update(plan_params)
      redirect_to workout_plan_path(@plan), notice: t('workout_plan.updated')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    unless WorkoutPlanPolicy.new(current_user, @plan).manage?
      render file: 'public/404.html', status: :unauthorized
      return
    end

    @plan.destroy
    redirect_to workout_plans_path, notice: t('workout_plan.destroyed')
  end

  private

  def set_plan
    @plan = WorkoutPlan.find(params.expect(:id))
  end

  def client_from_params
    User.find_by(id: params[:user_id])
  end

  def client_from_params_for_create
    User.find_by(id: params[:user_id]) || params.dig(:workout_plan, :user_id)&.then { |id| User.find_by(id: id) }
  end

  def plan_params
    params.expect(workout_plan: [:start_date, :end_date, { sessions_attributes: session_attributes }])
  end

  def session_attributes
    %i[id session_date workout_type duration distance distance_unit weight_unit title notes details _destroy]
  end

  def unauthorized_new
    redirect_to workout_plans_path, alert: t('workout_plan.unauthorized_create')
  end

  def can_create_for?(target)
    target && WorkoutPlanPolicy.new(current_user, WorkoutPlan.new(user: target)).create?(target)
  end

  def save_workout_plan
    if @workout_plan.save
      redirect_to workout_plan_path(@workout_plan), notice: t('workout_plan.created')
    else
      render :new, status: :unprocessable_content
    end
  end
end
