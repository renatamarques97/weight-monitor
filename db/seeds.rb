# frozen_string_literal: true

if ENV['RESET_SEED'].present?
  puts 'Cleaning database...'
  ChatMessage.delete_all
  MealFood.delete_all
  Meal.delete_all
  Diet.delete_all
  MealDiary.delete_all
  Weight.delete_all
  Workout.delete_all
  User.delete_all
end

puts 'Seeding users...'

SEED_DAYS = 90
DIET_DURATION_DAYS = 30

USER_SEEDS = [
  { email: 'demo1@fittracker.dev', objective: 'weight_loss' },
  { email: 'demo2@fittracker.dev', objective: 'running_performance' },
  { email: 'demo3@fittracker.dev', objective: 'hypertrophy' },
  { email: 'demo4@fittracker.dev', objective: 'general_health' },
  { email: 'demo5@fittracker.dev', objective: 'weight_loss' }
].freeze

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
  module_function

  def seed_all
    USER_SEEDS.each { |attributes| seed_user(attributes) }
  end

  def seed_user(attributes)
    user = User.find_or_initialize_by(email: attributes[:email])
    update_user(user)
    puts "  -> User: #{user.email}"

    initial_weight = rand(70.0..95.0)
    target_weight = target_weight(initial_weight, attributes[:objective])
    seed_weights(user, initial_weight, target_weight)
    seed_diet(user, initial_weight, target_weight)
    seed_workouts(user)
    seed_chat_messages(user)
    seed_meal_diaries(user)
  end

  def update_user(user)
    user.update!(
      name: FFaker::Name.name,
      password: 'password123',
      password_confirmation: 'password123',
      height: rand(1.60..1.90).round(2)
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

    FactoryBot.create(:weight, user: user, weight_date: index.days.ago.to_date, kg: final_weight)
  end

  def seed_diet(user, initial_weight, target_weight)
    FactoryBot.create(
      :diet,
      :with_meals,
      user: user,
      start_date: (DIET_DURATION_DAYS / 2).days.ago.to_date,
      end_date: (DIET_DURATION_DAYS / 2).days.from_now.to_date,
      initial_weight: initial_weight,
      target_weight: target_weight
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

    FactoryBot.create(sport, user: user, workout_date: index.days.ago.to_date)
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

puts "\nSeed completed successfully!"
puts 'Summary:'
puts " - Users: #{User.count}"
puts " - Workouts: #{Workout.count}"
puts " - Weights: #{Weight.count}"
puts " - Diets: #{Diet.count}"
puts " - Meals: #{Meal.count}"
puts " - Meal Diaries: #{MealDiary.count}"
