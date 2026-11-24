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
    ["Name: #{user.name}", "Email: #{user.email}", *unit_preference_lines]
  end

  def unit_preference_lines
    preferred_units = [user.weight_unit, user.distance_unit, user.height_unit].join(', ')

    ["Weight Unit Preference: #{user.weight_unit}",
     "Distance Unit Preference: #{user.distance_unit}",
     "Height Unit Preference: #{user.height_unit}",
     'Instruction to Assistant: The weight, diet and workout history below is provided with the exact unit ' \
     'each record was saved in. You MUST convert where necessary and ALWAYS write recommendations, goals, ' \
     "stats and text using the user's preferred units (#{preferred_units})."]
  end

  def diet_and_meal_lines
    latest_diet = user.diets.order(end_date: :desc, id: :desc).first
    meals = latest_diet ? latest_diet.meals.order(:schedule).limit(20) : []
    diet_lines(latest_diet) + meal_lines(meals)
  end

  def diet_lines(diet)
    return ['Current diet: not provided'] unless diet

    height = user.height ? "#{user.height} #{user.height_unit}" : 'not provided'
    ["Current diet: start=#{diet.start_date}, end=#{diet.end_date}, " \
     "initial_weight=#{diet.initial_weight} #{diet.weight_unit}, " \
     "target_weight=#{diet.target_weight} #{diet.weight_unit}, height=#{height}"]
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

    ['Weight history (most recent):', *weights.map { |weight| weight_line(weight) }]
  end

  def weight_line(weight)
    "- date=#{weight.weight_date}, value=#{weight.value} #{weight.weight_unit}"
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
    "- date=#{workout.workout_date}, #{distance_field(workout)}duration=#{workout.duration}, " \
      "calories=#{workout.calories}, details=#{workout.details}#{weight_unit_field(workout)}"
  end

  def distance_field(workout)
    return '' if workout.distance.blank?

    "distance=#{workout.distance} #{workout.distance_unit}, "
  end

  def weight_unit_field(workout)
    workout.weightlifting? ? ", weight_unit=#{workout.weight_unit}" : ''
  end
end
