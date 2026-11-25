# frozen_string_literal: true

class DietAdherencePresenter
  MEAL_TYPE_WEIGHT = 0.10
  FOOD_WEIGHT = 0.70
  SCHEDULE_WEIGHT = 0.20

  RECENT_DAYS = 7
  SCORE_MIN = 0
  SCORE_MAX = 100
  PERCENT_SCALE = 100
  PERFECT_SCORE = 1.0
  SCHEDULE_TOLERANCE_MINUTES = 180
  MINUTES_PER_HOUR = 60
  NORMALIZED_NAME_PATTERN = /[^a-z0-9]+/

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
    return 0 if executed_meals.empty?

    executed_meals.map do |executed|
      calculate_meal_score(planned, executed)
    end.max
  end

  def calculate_meal_score(planned, executed)
    food_score = food_similarity(planned, executed)
    return 0 if food_score.zero?

    meal_type_score = executed.meal_type.to_s == planned.meal_type.to_s ? PERFECT_SCORE : SCORE_MIN.to_f
    schedule_score = schedule_similarity(planned, executed)

    weighted_score = (meal_type_score * MEAL_TYPE_WEIGHT) +
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
    meal.meal_foods.flat_map { |food| normalize_name(food.food_name) }.uniq
  end

  def normalize_name(value)
    transliterated = I18n.transliterate(value.to_s)
    transliterated.downcase
                  .gsub(NORMALIZED_NAME_PATTERN, ' ')
                  .strip
                  .split
                  .uniq
  end

  def schedule_similarity(planned, executed)
    return SCORE_MIN.to_f unless planned.schedule && executed.schedule

    difference = (minutes(planned.schedule) - minutes(executed.schedule)).abs
    [PERFECT_SCORE - (difference.to_f / SCHEDULE_TOLERANCE_MINUTES), SCORE_MIN.to_f].max
  end

  def minutes(time)
    (time.hour * MINUTES_PER_HOUR) + time.min
  end
end
