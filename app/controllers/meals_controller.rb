# frozen_string_literal: true

class MealsController < ApplicationController
  before_action :set_meal, only: %i[show edit update destroy]

  # GET /meals
  def index
    meals = if current_user
              diet_meals = Meal.where(diet_id: current_user.diets.select(:id))
              diary_meals = Meal.where(meal_diary_id: current_user.meal_diaries.select(:id))
              diet_meals.or(diary_meals).order(schedule: :desc)
            else
              Meal.none
            end

    @pagy, @meals = pagy(meals, limit: 20)
  end

  # GET /meals/1
  def show; end

  # GET /meals/new
  def new
    @meal = Meal.new
  end

  # GET /meals/1/edit
  def edit; end

  # POST /meals
  def create
    @meal = Meal.new(meal_params)

    respond_to do |format|
      if @meal.save
        format.html { redirect_to @meal, notice: t('meal.created') }
        format.json { render json: @meal, status: :created, location: @meal }
      else
        format.html { render :new }
        format.json { render json: @meal.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /meals/1
  def update
    respond_to do |format|
      if @meal.update(meal_params)
        format.html { redirect_to @meal, notice: t('meal.updated') }
        format.json { render json: @meal, status: :ok, location: @meal }
      else
        format.html { render :edit }
        format.json { render json: @meal.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /meals/1
  def destroy
    @meal.destroy
    respond_to do |format|
      format.html { redirect_to meals_url, notice: t('meal.destroyed') }
      format.json { head :no_content }
    end
  end

  private

  def set_meal
    @meal = Meal.find(params.expect(:id))
  end

  def meal_params
    params.expect(meal: %i[schedule description diet_id meal_type])
  end
end
