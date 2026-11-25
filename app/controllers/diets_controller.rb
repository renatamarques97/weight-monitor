# frozen_string_literal: true

class DietsController < ApplicationController
  before_action :set_diet, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :authorized?, only: %i[show edit update destroy]

  # GET /diets
  def index
    diets = Diet.authorized_user(current_user).order(start_date: :desc, created_at: :desc)
    @pagy, @diets = pagy(diets, limit: 25)
  end

  def show; end

  # GET /diets/new
  def new
    @diet = Diet.new(weight_unit: current_user.weight_unit)
    meal = @diet.meals.build
    meal.meal_foods.build
  end

  def edit; end

  # POST /diets
  def create
    @diet = current_user.diets.build(diet_params)

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
    return false if ::UserDietPolicy.new(current_user, @diet).diet_belongs_to_user?

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
