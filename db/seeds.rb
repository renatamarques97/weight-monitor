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
  { email: "demo1@fittracker.dev", name: FFaker::Name.name },
  { email: "demo2@fittracker.dev", name: FFaker::Name.name },
  { email: "demo3@fittracker.dev", name: FFaker::Name.name },
]

user_seeds.each do |user_attributes|
  user = User.find_or_initialize_by(email: user_attributes[:email])
  user.update!(
    name: user_attributes[:name],
    password: "password123",
    password_confirmation: "password123",
    height: rand(1.60..1.90).round(2)
  )

  puts "  -> User: #{user.email}"

  # 1. Weights (Last 90 days)
  initial_weight = rand(70.0..95.0)
  (0..SEED_DAYS).each do |i|
    FactoryBot.create(:weight,
      user: user,
      weight_date: i.days.ago.to_date,
      kg: (initial_weight - (i * rand(0.05..0.15)) + rand(-0.2..0.2)).round(1)
    )
  end

  # 2. Diet & Meals
  diet = FactoryBot.create(:diet,
    user: user,
    start_date: DIET_DURATION_DAYS.days.ago.to_date,
    end_date: DIET_DURATION_DAYS.days.from_now.to_date,
    initial_weight: initial_weight.round(1),
    target_weight: (initial_weight - 5).round(1)
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
