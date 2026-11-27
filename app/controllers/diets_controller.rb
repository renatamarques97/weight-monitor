# frozen_string_literal: true

class DietsController < ApplicationController
  before_action :set_diet, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :authorized?, only: %i[show edit update destroy]

  # GET /diets
  def index
    diets = if current_user.account_type_admin?
              Diet.all
            elsif current_user.valid_nutritionist?
              Diet.where(user: User.where(id: current_user.nutritionist_assignments.select(:client_id)))
            else
              Diet.authorized_user(current_user)
            end
    @pagy, @diets = pagy(diets.order(start_date: :desc, created_at: :desc), limit: 20)
  end

  def show; end

  # GET /diets/new
  def new
    target = User.find_by(id: params[:user_id])
    unless target && ::UserDietPolicy.new(current_user, target.diets.build).create?(target)
      redirect_to diets_path, alert: 'Only assigned nutritionists can create diets.'
      return
    end

    @diet = target.diets.build(nutritionist: current_user, weight_unit: target.weight_unit)
    meal = @diet.meals.build
    meal.meal_foods.build
  end

  def edit; end

  # POST /diets
  def create
    target = User.find_by(id: params[:user_id])
    unless target && ::UserDietPolicy.new(current_user, target.diets.build).create?(target)
      redirect_to diets_path, alert: 'Only assigned nutritionists can create diets.'
      return
    end

    @diet = target.diets.build(diet_params)
    @diet.nutritionist = current_user

    if @diet.save
      flash[:notice] = t('diet.created')
      redirect_to(root_path)
    else
      render :new
    end
  end

  # PATCH/PUT /diets/1
  def update
    if @diet.update(diet_params)
      flash[:notice] = t('diet.updated')
      redirect_to(root_path)
    else
      render :edit
    end
  end

  # DELETE /diets/1
  def destroy
    @diet.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: t('diet.destroyed') }
      format.json { head :no_content }
    end
  end

  private

  def set_diet
    @diet = Diet.find(params.expect(:id))
  end

  def authorized?
    policy = ::UserDietPolicy.new(current_user, @diet)
    allowed = if action_name.in?(%w[show])
                policy.view?
              else
                policy.manage?
              end

    return false if allowed

    render file: 'public/404.html', status: :unauthorized
  end

  def diet_params
    params.expect(diet: [*diet_attributes, { meals_attributes: meal_attributes }])
  end

  def diet_attributes
    %i[start_date end_date initial_weight target_weight weight_unit]
  end

  def meal_attributes
    [
      :id, :schedule, :description, :meal_type, :food_name, :fatsecret_food_id,
      :calories, :protein, :carbs, :fat, :metric_serving_unit, :_destroy,
      { meal_foods_attributes: meal_food_attributes }
    ]
  end

  def meal_food_attributes
    %i[
      id food_name fatsecret_food_id metric_serving_amount calories protein carbs fat
      metric_serving_unit _destroy
    ]
  end
end
