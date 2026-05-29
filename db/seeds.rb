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

  # 4. Chat Messages (50 messages per user)
  messages = [
    { user: "How is my progress?", assistant: "Your weight is trending down and your consistency is great!" },
    { user: "What should I do to improve?", assistant: "You should eat less and exercise more." },
    { user: "What is my BMI?", assistant: "Your BMI is 23.4." },
    { user: "How much water should I drink?", assistant: "You should aim for 2.5 to 3 liters of water per day." },
    { user: "Is it okay to eat carbs at night?", assistant: "Yes, carbs at night are fine as long as you stay within your daily calorie goal." },
    { user: "How do I calculate my calorie deficit?", assistant: "Find your TDEE (Total Daily Energy Expenditure) and subtract 300-500 calories." },
    { user: "What are the best sources of protein?", assistant: "Chicken breast, turkey, eggs, Greek yogurt, fish, and tofu." },
    { user: "How many days a week should I work out?", assistant: "Aim for 3 to 5 days per week, combining cardio and strength training." },
    { user: "What is a good post-workout meal?", assistant: "A mix of fast-digesting protein and carbohydrates, like a whey shake with a banana." },
    { user: "How do I reduce muscle soreness?", assistant: "Ensure proper hydration, get adequate sleep, stretch, and consume enough protein." },
    { user: "Should I do cardio before or after weights?", assistant: "It's best to do cardio after weights to keep your energy high for strength training." },
    { user: "How does sleep affect my weight loss?", assistant: "Lack of sleep increases hunger hormones (ghrelin) and decreases satiety (leptin)." },
    { user: "What is the difference between active and passive recovery?", assistant: "Active recovery involves low-intensity movement like walking or yoga; passive is complete rest." },
    { user: "How can I increase my running stamina?", assistant: "Incorporate interval training, tempo runs, and gradually increase your weekly mileage by 10%." },
    { user: "Can I build muscle while losing fat?", assistant: "Yes, this is called body recomposition. It requires a small calorie deficit and high protein intake." },
    { user: "What are healthy snacks for weight loss?", assistant: "Apple slices with peanut butter, a handful of almonds, or baby carrots with hummus." },
    { user: "How long does it take to see muscle growth?", assistant: "With consistent training and nutrition, noticeable changes typically appear in 6-8 weeks." },
    { user: "What is the benefit of weightlifting?", assistant: "It increases bone density, boosts metabolism, builds strength, and improves posture." },
    { user: "How do I stay motivated to exercise?", assistant: "Set realistic goals, track your progress, find a workout partner, and choose activities you enjoy." },
    { user: "Is green tea good for fat burn?", assistant: "Green tea contains antioxidants that can slightly boost metabolism, but it won't replace a calorie deficit." },
    { user: "How do I track my food intake accurately?", assistant: "Use a food scale to weigh portions and log everything in a calorie-tracking app." },
    { user: "What are signs of overtraining?", assistant: "Persistent fatigue, decreased performance, irritability, disturbed sleep, and chronic muscle soreness." },
    { user: "Why is my weight fluctuating day to day?", assistant: "Water retention, sodium intake, digestion, glycogen storage, and stress can cause daily fluctuations." },
    { user: "How do I prevent injuries during lifting?", assistant: "Warm up properly, focus on correct form rather than heavy weight, and listen to your body." },
    { user: "What is the role of fiber in a diet?", assistant: "Fiber aids digestion, helps control blood sugar, and keeps you feeling full longer." }
  ]

  hours_ago = 100
  messages.each_with_index do |pair, index|
    hours_ago -= rand(1.0..2.0)
    created_at = hours_ago.hours.ago

    # Create the user question
    FactoryBot.create(:user_chat_message,
      user: user,
      content: pair[:user],
      created_at: created_at
    )

    # Create the assistant response
    FactoryBot.create(:assistant_chat_message,
      user: user,
      content: pair[:assistant],
      created_at: created_at + 5.seconds
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
