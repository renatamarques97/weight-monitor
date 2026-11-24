# frozen_string_literal: true

if ENV['RESET_SEED'].present?
  Rails.logger.debug 'Cleaning database...'
  ChatMessage.delete_all
  MealFood.delete_all
  Meal.delete_all
  Diet.delete_all
  MealDiary.delete_all
  Weight.delete_all
  Workout.delete_all
  User.delete_all
end

Rails.logger.debug 'Seeding users...'

SEED_DAYS = 90
DIET_DURATION_DAYS = 30

UNITS = MeasurementUnits

USER_SEEDS = [
  { email: 'demo1@fittracker.dev', objective: 'weight_loss',
    weight_unit: UNITS::WEIGHTS::KG, distance_unit: UNITS::DISTANCES::KM, height_unit: UNITS::HEIGHTS::M },
  { email: 'demo2@fittracker.dev', objective: 'running_performance',
    weight_unit: UNITS::WEIGHTS::LBS, distance_unit: UNITS::DISTANCES::MI, height_unit: UNITS::HEIGHTS::FT },
  { email: 'demo3@fittracker.dev', objective: 'hypertrophy',
    weight_unit: UNITS::WEIGHTS::KG, distance_unit: UNITS::DISTANCES::KM, height_unit: UNITS::HEIGHTS::CM },
  { email: 'demo4@fittracker.dev', objective: 'general_health',
    weight_unit: UNITS::WEIGHTS::LBS, distance_unit: UNITS::DISTANCES::MI, height_unit: UNITS::HEIGHTS::CM },
  { email: 'demo5@fittracker.dev', objective: 'weight_loss',
    weight_unit: UNITS::WEIGHTS::KG, distance_unit: UNITS::DISTANCES::MI, height_unit: UNITS::HEIGHTS::FT }
].freeze

# Chance of a record being saved in the unit opposite to the user's preference.
ALTERNATE_UNIT_CHANCE = 0.10

CHAT_MESSAGES = [
  { user: 'How is my progress?', assistant: 'Your weight is trending down and your consistency is great!' },
  { user: 'What should I do to improve?', assistant: 'You should eat less and exercise more.' },
  { user: 'What is my BMI?', assistant: 'Your BMI is 23.4.' },
  { user: 'How much water should I drink?', assistant: 'You should aim for 2.5 to 3 liters of water per day.' },
  { user: 'Is it okay to eat carbs at night?',
    assistant: 'Yes, carbs at night are fine as long as you stay within your daily calorie goal.' },
  { user: 'How do I calculate my calorie deficit?',
    assistant: 'Find your TDEE and subtract 300-500 calories.' },
  { user: 'What are the best sources of protein?',
    assistant: 'Chicken breast, turkey, eggs, Greek yogurt, fish, and tofu.' },
  { user: 'How many days a week should I work out?',
    assistant: 'Aim for 3 to 5 days per week, combining cardio and strength training.' },
  { user: 'What is a good post-workout meal?',
    assistant: 'A mix of protein and carbohydrates, like a whey shake with a banana.' },
  { user: 'How do I reduce muscle soreness?',
    assistant: 'Hydrate, sleep, stretch, and consume enough protein.' },
  { user: 'Should I do cardio before or after weights?',
    assistant: 'It is best to do cardio after weights to keep your energy high.' },
  { user: 'How does sleep affect my weight loss?',
    assistant: 'Poor sleep increases hunger and decreases satiety.' },
  { user: 'How can I increase my running stamina?',
    assistant: 'Use interval training, tempo runs, and gradually increase mileage.' },
  { user: 'Can I build muscle while losing fat?',
    assistant: 'Yes. It requires a small calorie deficit and high protein intake.' },
  { user: 'What are healthy snacks for weight loss?',
    assistant: 'Apple slices with peanut butter or baby carrots with hummus.' },
  { user: 'How long does it take to see muscle growth?',
    assistant: 'With consistent training, changes typically appear in 6-8 weeks.' },
  { user: 'What is the benefit of weightlifting?',
    assistant: 'It increases bone density, boosts metabolism, builds strength, and improves posture.' },
  { user: 'How do I stay motivated to exercise?',
    assistant: 'Set realistic goals and choose activities you enjoy.' },
  { user: 'Is green tea good for fat burn?',
    assistant: 'Green tea may slightly boost metabolism, but it will not replace a calorie deficit.' },
  { user: 'What are signs of overtraining?',
    assistant: 'Persistent fatigue, reduced performance, irritability, and chronic soreness.' },
  { user: 'Why is my weight fluctuating day to day?',
    assistant: 'Water, sodium, digestion, glycogen, and stress can cause fluctuations.' }
].freeze

module DemoSeeder
  module SeedUnits
    module_function

    def height_in(unit)
      UnitConverter.convert_height_between(rand(1.60..1.90), UNITS::HEIGHTS::M, unit)
    end

    # Mostly the preferred unit, sometimes the other one, so the demo data exercises conversions.
    def record_unit(preferred, units)
      rand < ALTERNATE_UNIT_CHANCE ? (units - [preferred]).sample : preferred
    end

    def from_kg(value, unit)
      UnitConverter.convert_weight_between(value, UNITS::WEIGHTS::KG, unit)
    end

    def weight_attributes(user, value_in_kg)
      unit = record_unit(user.weight_unit, UNITS::WEIGHTS::ALL)
      { value: from_kg(value_in_kg, unit), weight_unit: unit }
    end

    def workout_units(user)
      { distance_unit: record_unit(user.distance_unit, UNITS::DISTANCES::ALL),
        weight_unit: record_unit(user.weight_unit, UNITS::WEIGHTS::ALL) }
    end
  end

  module_function

  def seed_all
    USER_SEEDS.each { |attributes| seed_user(attributes) }
  end

  def seed_user(attributes)
    user = User.find_or_initialize_by(email: attributes[:email])
    update_user(user, attributes)
    Rails.logger.debug { "  -> User: #{user.email}" }

    initial_weight = rand(70.0..95.0)
    target_weight = target_weight(initial_weight, attributes[:objective])
    seed_weights(user, initial_weight, target_weight)
    seed_diet(user, initial_weight, target_weight)
    seed_workouts(user)
    seed_chat_messages(user)
    seed_meal_diaries(user)
  end

  def update_user(user, attributes)
    user.update!(
      name: FFaker::Name.name,
      password: 'password123',
      password_confirmation: 'password123',
      **attributes.slice(:weight_unit, :distance_unit, :height_unit),
      height: SeedUnits.height_in(attributes[:height_unit])
    )
  end

  def target_weight(initial_weight, objective)
    target_delta = {
      'weight_loss' => rand(6.0..12.0),
      'hypertrophy' => -rand(2.0..5.0),
      'running_performance' => rand(0.5..2.0)
    }.fetch(objective, rand(-1.0..1.5))

    (initial_weight - target_delta).round(1)
  end

  def seed_weights(user, initial_weight, target_weight)
    (0..SEED_DAYS).each do |index|
      next unless rand < 0.80

      seed_weight(user, index, initial_weight, target_weight)
    end
  end

  def seed_weight(user, index, initial_weight, target_weight)
    progress = 1.0 - (index.to_f / SEED_DAYS)
    base_weight = initial_weight + ((target_weight - initial_weight) * progress)
    final_weight = (base_weight + rand(-1.0..0.3)).round(1)

    FactoryBot.create(:weight, user: user, weight_date: index.days.ago.to_date,
                               **SeedUnits.weight_attributes(user, final_weight))
  end

  def seed_diet(user, initial_weight, target_weight)
    FactoryBot.create(
      :diet,
      :with_meals,
      user: user,
      start_date: (DIET_DURATION_DAYS / 2).days.ago.to_date,
      end_date: (DIET_DURATION_DAYS / 2).days.from_now.to_date,
      initial_weight: SeedUnits.from_kg(initial_weight, user.weight_unit),
      target_weight: SeedUnits.from_kg(target_weight, user.weight_unit),
      weight_unit: user.weight_unit
    )
  end

  def seed_workouts(user)
    WorkoutType::MAPPING.each_key do |sport|
      (0..SEED_DAYS).each { |index| seed_workout(user, sport, index) }
    end
  end

  def seed_workout(user, sport, index)
    frequencies = { running: 0.6, walking: 0.8, weightlifting: 0.5, swimming: 0.3 }
    return unless rand < frequencies.fetch(sport, 0.4)

    FactoryBot.create(sport, user: user, workout_date: index.days.ago.to_date, **SeedUnits.workout_units(user))
  end

  def seed_chat_messages(user)
    hours_ago = 100
    CHAT_MESSAGES.each do |pair|
      hours_ago -= rand(1.0..2.0)
      created_at = hours_ago.hours.ago
      seed_chat_pair(user, pair, created_at)
    end
  end

  def seed_chat_pair(user, pair, created_at)
    FactoryBot.create(:user_chat_message, user: user, content: pair[:user], created_at: created_at)
    FactoryBot.create(
      :assistant_chat_message,
      user: user,
      content: pair[:assistant],
      created_at: created_at + 5.seconds
    )
  end

  def seed_meal_diaries(user)
    (0..29).each { |index| seed_meal_diary(user, index) }
  end

  def seed_meal_diary(user, index)
    quality = ['great', 'decent', 'okay', 'not so good'].sample
    eating = ['clean', 'a bit too much', 'some junk food'].sample

    FactoryBot.create(
      :meal_diary,
      :with_meals,
      user: user,
      diary_date: index.days.ago.to_date,
      notes: "Today I had a #{quality} day with my diet. Ate #{eating}."
    )
  end
end

DemoSeeder.seed_all

Rails.logger.debug "\nSeed completed successfully!"
Rails.logger.debug 'Summary:'
Rails.logger.debug { " - Users: #{User.count}" }
Rails.logger.debug { " - Workouts: #{Workout.count}" }
Rails.logger.debug { " - Weights: #{Weight.count}" }
Rails.logger.debug { " - Diets: #{Diet.count}" }
Rails.logger.debug { " - Meals: #{Meal.count}" }
Rails.logger.debug { " - Meal Diaries: #{MealDiary.count}" }
