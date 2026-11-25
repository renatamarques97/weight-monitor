# frozen_string_literal: true

class DietAdherencePresenter
  MEAL_TYPE_WEIGHT = 0.40
  FOOD_WEIGHT = 0.40
  SCHEDULE_WEIGHT = 0.20

  RECENT_DAYS = 7
  SCORE_MIN = 0
  SCORE_MAX = 100
  PERCENT_SCALE = 100
  UNKNOWN_SCHEDULE_SCORE = 0.5
  PERFECT_SCORE = 1.0
  SCHEDULE_TOLERANCE_MINUTES = 180
  MINUTES_PER_HOUR = 60
  NORMALIZED_NAME_PATTERN = /[^a-z0-9]+/

  def initialize(user)
    @user = user
  end

  def adherence_percent
    return nil unless diet
    return nil if diaries.empty?

    calculate_adherence_percent
  end

  def calculate_adherence_percent
    scores = RECENT_DAYS.times.map { |index| score_for_date(Date.current - index) }
    (scores.sum / scores.length).round.clamp(SCORE_MIN, SCORE_MAX)
  end

  def score_for_date(date)
    diary = diaries.find { |record| record.diary_date == date }
    diary ? diary_score(diary) : SCORE_MIN.to_f
  end

  def state
    return :not_set unless diet
    return :no_records if diaries.empty?

    :tracked
  end

  def diet
    @diet ||= user.diets.order(start_date: :desc, created_at: :desc).first
  end

  def diaries
    @diaries ||= user.meal_diaries
                     .where(diary_date: RECENT_DAYS.days.ago.to_date..Date.current)
                     .includes(meals: :meal_foods)
                     .order(diary_date: :desc)
  end

  private

  attr_reader :user

  def diary_score(diary)
    planned_meals = diet.meals.includes(:meal_foods)
    return 0 if planned_meals.empty?

    planned_meals.sum { |planned| meal_score(planned, diary.meals) } / planned_meals.length
  end

  def meal_score(planned, executed_meals)
    matches = executed_meals_for(planned, executed_meals)
    return 0 if matches.empty?

    calculate_meal_score(planned, matches)
  end

  def executed_meals_for(planned, executed_meals)
    executed_meals.select { |executed| executed.meal_type.to_s == planned.meal_type.to_s }
  end

  def calculate_meal_score(planned, matches)
    food_score = matches.map { |executed| food_similarity(planned, executed) }.max
    schedule_score = matches.map { |executed| schedule_similarity(planned, executed) }.max

    weighted_score = MEAL_TYPE_WEIGHT +
                     (food_score * FOOD_WEIGHT) +
                     (schedule_score * SCHEDULE_WEIGHT)

    weighted_score * PERCENT_SCALE
  end

  def food_similarity(planned, executed)
    planned_tokens = food_tokens(planned)
    executed_tokens = food_tokens(executed)
    return SCORE_MIN.to_f if planned_tokens.empty? || executed_tokens.empty?

    intersection = (planned_tokens & executed_tokens).length
    union = (planned_tokens | executed_tokens).length
    intersection.to_f / union
  end

  def food_tokens(meal)
    names = meal.meal_foods.filter_map { |food| normalize_name(food.food_name) }
    names << normalize_name(meal.food_name) if meal.food_name.present?
    names << normalize_name(meal.description)
    names.compact.uniq
  end

  def normalize_name(value)
    normalized = value.to_s.downcase.gsub(NORMALIZED_NAME_PATTERN, ' ').strip
    normalized.presence
  end

  def schedule_similarity(planned, executed)
    return UNKNOWN_SCHEDULE_SCORE unless planned.schedule && executed.schedule

    difference = (minutes(planned.schedule) - minutes(executed.schedule)).abs
    [PERFECT_SCORE - (difference.to_f / SCHEDULE_TOLERANCE_MINUTES), SCORE_MIN.to_f].max
  end

  def minutes(time)
    (time.hour * MINUTES_PER_HOUR) + time.min
  end
end
