# frozen_string_literal: true

class ChatResponseContext
  WORKOUT_ASSOCIATIONS = {
    running: :runnings,
    walking: :walkings,
    cycling: :cyclings,
    swimming: :swimmings,
    weightlifting: :weightliftings,
    yoga: :yogas,
    soccer: :soccers,
    basketball: :basketballs,
    tennis: :tennis,
    martial_arts: :martial_arts,
    other: :others
  }.freeze

  def initialize(user)
    @user = user
  end

  def call
    lines = identity_lines
    lines.concat(diet_and_meal_lines)
    lines.concat(weight_history_lines)
    lines.concat(workout_history_lines)
    lines.join("\n")
  end

  private

  attr_reader :user

  def identity_lines
    ["Name: #{user.name}", "Email: #{user.email}"]
  end

  def diet_and_meal_lines
    latest_diet = user.diets.order(end_date: :desc, id: :desc).first
    meals = latest_diet ? latest_diet.meals.order(:schedule).limit(20) : []
    diet_lines(latest_diet) + meal_lines(meals)
  end

  def diet_lines(diet)
    return ['Current diet: not provided'] unless diet

    height = user.height || 'not provided'
    ["Current diet: start=#{diet.start_date}, end=#{diet.end_date}, " \
     "initial_weight=#{diet.initial_weight}, target_weight=#{diet.target_weight}, height=#{height}"]
  end

  def meal_lines(meals)
    return ['Meals: not provided'] unless meals.any?

    ['Meals in current diet:', *meals.map { |meal| meal_line(meal) }]
  end

  def meal_line(meal)
    "- schedule=#{meal.schedule}, type=#{meal.meal_type}, description=#{meal.description}"
  end

  def weight_history_lines
    weights = user.weights.order(weight_date: :desc, id: :desc).limit(30)
    return ['Weight history: empty'] unless weights.any?

    ['Weight history (most recent):', *weights.map { |weight| "- date=#{weight.weight_date}, kg=#{weight.kg}" }]
  end

  def workout_history_lines
    workout_types.flat_map do |type, association|
      records = user.public_send(association).order(workout_date: :desc, id: :desc).limit(10)
      workout_type_lines(type, records)
    end
  end

  def workout_types
    WorkoutType::MAPPING.keys.index_with { |type| type_association(type) }
  end

  def type_association(type)
    WORKOUT_ASSOCIATIONS.fetch(type)
  end

  def workout_type_lines(type, records)
    name = WorkoutType.t(type)
    return ["#{name} history: empty"] unless records.any?

    ["#{name} history (most recent):", *records.map { |workout| workout_line(workout) }]
  end

  def workout_line(workout)
    distance = workout.respond_to?(:distance) ? "distance=#{workout.distance}, " : ''
    "- date=#{workout.workout_date}, #{distance}duration=#{workout.duration}, " \
      "calories=#{workout.calories}, details=#{workout.details}"
  end
end
