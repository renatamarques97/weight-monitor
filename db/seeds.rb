# frozen_string_literal: true

if ENV["RESET_SEED"].present?
  puts "Cleaning database..."
  ChatMessage.delete_all
  Meal.delete_all
  Diet.delete_all
  Weight.delete_all
  Workout.delete_all
  User.delete_all
end

puts "Seeding users..."

SEED_DAYS = 90
DIET_DURATION_DAYS = 30

user_seeds = [
  { email: "demo1@fittracker.dev", objective: "weight_loss" },
  { email: "demo2@fittracker.dev", objective: "running_performance" },
  { email: "demo3@fittracker.dev", objective: "hypertrophy" },
  { email: "demo4@fittracker.dev", objective: "general_health" },
  { email: "demo5@fittracker.dev", objective: "weight_loss" }
]

user_seeds.each do |user_attributes|
  user = User.find_or_initialize_by(email: user_attributes[:email])
  user.update!(
    name: FFaker::Name.name,
    password: "password123",
    password_confirmation: "password123",
    height: rand(1.60..1.90).round(2)
  )

  puts "  -> User: #{user.email}"

  # 1. Weights (Last 90 days)
  initial_weight = rand(70.0..95.0)
  
  # Calculate target weight based on objective
  target_delta = case user_attributes[:objective]
                 when "weight_loss" then rand(6.0..12.0)
                 when "hypertrophy" then -rand(2.0..5.0)
                 when "running_performance" then rand(0.5..2.0)
                 else rand(-1.0..1.5)
                 end
  target_weight = (initial_weight - target_delta).round(1)
  
  (0..SEED_DAYS).each do |i|
    # Simulate realistic gaps - people don't weigh themselves every day
    next unless rand < 0.80 # ~20% chance of missing that day
    
    # Progress from initial_weight (day 0) to target_weight (day 90)
    progress_ratio = 1.0 - (i.to_f / SEED_DAYS)
    base_weight = initial_weight + ((target_weight - initial_weight) * progress_ratio)

    # Add some randomness
    random_variation = rand(-1.0..0.3) # -1kg to +0.3kg fluctuation
    final_weight = (base_weight + random_variation).round(1)
    
    FactoryBot.create(:weight,
      user: user,
      weight_date: i.days.ago.to_date,
      kg: final_weight
    )
  end

  # 2. Diet & Meals
  diet = FactoryBot.create(:diet,
    user: user,
    start_date: DIET_DURATION_DAYS.days.ago.to_date,
    end_date: DIET_DURATION_DAYS.days.from_now.to_date,
    initial_weight: initial_weight.round(1),
    target_weight: target_weight
  )

  [
    { at: "07:30", type: 0, description: "Greek yogurt with berries and granola" },
    { at: "13:00", type: 2, description: "Grilled chicken, rice and mixed salad" },
    { at: "19:30", type: 4, description: "Salmon, sweet potato and broccoli" }
  ].each do |meal_attributes|
    FactoryBot.create(:meal,
      diet: diet,
      schedule: Time.zone.parse(meal_attributes[:at]),
      meal_type: meal_attributes[:type],
      description: meal_attributes[:description]
    )
  end

  # 3. Workouts (90 of each type, starting from today)
  WorkoutType::MAPPING.each_key do |sport|
    (0..SEED_DAYS).each do |i|
      frequency =
      case sport
      when :running then 0.6
      when :walking then 0.8
      when :weightlifting then 0.5
      when :swimming then 0.3
      else 0.4
      end

      next unless rand < frequency
      FactoryBot.create(sport, user: user, workout_date: i.days.ago.to_date)
    end
  end

  # 4. Chat Messages
  [
    { role: "user", content: "How is my progress?" },
    { role: "assistant", content: "Your weight is trending down and your consistency is great!" },
    { role: "user", content: "What should I do to improve?" },
    { role: "assistant", content: "You should eat less and exercise more." },
    { role: "user", content: "What is my BMI?" },
    { role: "assistant", content: "Your BMI is 23.4" }
  ].each do |chat_message_attributes|
    FactoryBot.create(:chat_message,
      user: user,
      role: chat_message_attributes[:role],
      content: chat_message_attributes[:content]
    )
  end
end

puts "\nSeed completed successfully!"
puts "Summary:"
puts " - Users: #{User.count}"
puts " - Workouts: #{Workout.count}"
puts " - Weights: #{Weight.count}"
puts " - Diets: #{Diet.count}"
puts " - Meals: #{Meal.count}"
