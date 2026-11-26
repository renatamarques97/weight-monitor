# frozen_string_literal: true

class DietMealAdherenceCalculator
  MEAL_TYPE_WEIGHT = 0.10
  FOOD_WEIGHT = 0.70
  SCHEDULE_WEIGHT = 0.20

  SCORE_MIN = 0
  PERCENT_SCALE = 100
  PERFECT_SCORE = 1.0
  SCHEDULE_TOLERANCE_MINUTES = 180
  MINUTES_PER_HOUR = 60
  NORMALIZED_NAME_PATTERN = /[^a-z0-9]+/

  def score(planned, executed_meals)
    return SCORE_MIN if executed_meals.empty?

    executed_meals.map { |executed| score_for_meal(planned, executed) }.max
  end

  private

  def score_for_meal(planned, executed)
    return SCORE_MIN unless executed.meal_type.to_s == planned.meal_type.to_s

    food_score = food_similarity(planned, executed)
    return SCORE_MIN if food_score.zero?

    meal_type_score = meal_type_similarity(planned, executed)
    schedule_score = schedule_similarity(planned, executed)

    weighted_score = (meal_type_score * MEAL_TYPE_WEIGHT) +
                     (food_score * FOOD_WEIGHT) +
                     (schedule_score * SCHEDULE_WEIGHT)

    weighted_score * PERCENT_SCALE
  end

  def meal_type_similarity(planned, executed)
    executed.meal_type.to_s == planned.meal_type.to_s ? PERFECT_SCORE : SCORE_MIN.to_f
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
    meal.meal_foods.filter_map { |food| normalize_name(food.food_name) }.uniq
  end

  def normalize_name(value)
    I18n.transliterate(value.to_s)
        .downcase
        .gsub(NORMALIZED_NAME_PATTERN, ' ')
        .strip
        .presence
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
