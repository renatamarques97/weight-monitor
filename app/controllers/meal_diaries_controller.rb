# frozen_string_literal: true

class MealDiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meal_diary, only: %i[show edit update destroy]
  before_action :authorized!, only: %i[show edit update destroy]

  def index
    @meal_diaries = MealDiary.authorized_user(current_user).order(diary_date: :desc)
  end

  def show; end

  def new
    @meal_diary = MealDiary.new
    meal = @meal_diary.meals.build
    meal.meal_foods.build
  end

  def create
    @meal_diary = current_user.meal_diaries.build(meal_diary_params)

    if @meal_diary.save
      redirect_to meal_diaries_path, notice: t('meal_diary.created')
    else
      render :new
    end
  end

  def edit
    @meal_diary.meals.each { |meal| meal.meal_foods.build if meal.meal_foods.empty? }
  end

  def update
    if @meal_diary.update(meal_diary_params)
      redirect_to meal_diaries_path, notice: t('meal_diary.updated')
    else
      render :edit
    end
  end

  def destroy
    @meal_diary.destroy
    redirect_to meal_diaries_path, notice: t('meal_diary.destroyed')
  end

  private

  def set_meal_diary
    @meal_diary = MealDiary.find(params[:id])
  end

  def authorized!
    render file: 'public/404.html', status: :unauthorized unless @meal_diary.user_id == current_user.id
  end

  def meal_diary_params
    params.require(:meal_diary).permit(
      :diary_date,
      :notes,
      meals_attributes: [
        :id,
        :schedule,
        :description,
        :meal_type,
        :_destroy,
        {
          meal_foods_attributes: %i[
            id
            food_name
            fatsecret_food_id
            metric_serving_amount
            calories
            protein
            carbs
            fat
            metric_serving_unit
            _destroy
          ]
        }
      ]
    )
  end
end
