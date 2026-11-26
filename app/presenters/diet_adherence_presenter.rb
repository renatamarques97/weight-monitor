# frozen_string_literal: true

class DietAdherencePresenter
  RECENT_DAYS = 7
  SCORE_MIN = 0
  SCORE_MAX = 100

  def initialize(user)
    @user = user
  end

  def adherence_percent
    return nil unless diet
    return nil if state == :no_plan
    return nil if diaries.empty?

    calculate_adherence_percent
  end

  def state
    return :not_set unless diet
    return :no_plan if planned_meals.empty?
    return :no_records if diaries.empty?

    :tracked
  end

  def diet
    @diet ||= user.current_diet
  end

  def diaries
    @diaries ||= user.meal_diaries
                     .where(diary_date: adherence_dates)
                     .includes(meals: :meal_foods)
                     .order(diary_date: :desc)
  end

  private

  attr_reader :user

  def adherence_dates
    return [] unless diet

    start_date = [diet.start_date, RECENT_DAYS.days.ago.to_date].max
    end_date = [diet.end_date || Date.current, Date.current].min
    return [] if end_date < start_date

    (start_date..end_date).to_a.last(RECENT_DAYS)
  end

  def calculate_adherence_percent
    dates = adherence_dates
    return nil if dates.empty?

    scores = dates.map { |date| score_for_date(date) }
    (scores.sum / scores.length).round.clamp(SCORE_MIN, SCORE_MAX)
  end

  def score_for_date(date)
    diary = diaries.find { |record| record.diary_date == date }
    diary ? diary_score(diary) : SCORE_MIN.to_f
  end

  def diary_score(diary)
    planned_meals.sum { |planned| meal_score(planned, diary.meals) } / planned_meals.length
  end

  def planned_meals
    @planned_meals ||= diet.meals.includes(:meal_foods).to_a
  end

  def meal_score(planned, executed_meals)
    meal_calculator.score(planned, executed_meals)
  end

  def meal_calculator
    @meal_calculator ||= DietMealAdherenceCalculator.new
  end
end
