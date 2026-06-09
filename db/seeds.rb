# frozen_string_literal: true

if ENV["RESET_SEED"].present?
  puts "Cleaning database..."
  ChatMessage.delete_all
  MealFood.delete_all
  Meal.delete_all
  Diet.delete_all
  MealDiary.delete_all
  Weight.delete_all
  Workout.delete_all
  User.delete_all
end

puts "Seeding users..."

SEED_DAYS = 90
DIET_DURATION_DAYS = 30

user_seeds = [
  { email: "demo1@fittracker.dev", objective: "weight_loss", weight_unit: MeasurementUnits::WEIGHTS::KG, distance_unit: MeasurementUnits::DISTANCES::KM, height_unit: MeasurementUnits::HEIGHTS::M },
  { email: "demo2@fittracker.dev", objective: "running_performance", weight_unit: MeasurementUnits::WEIGHTS::LBS, distance_unit: MeasurementUnits::DISTANCES::MI, height_unit: MeasurementUnits::HEIGHTS::FT },
  { email: "demo3@fittracker.dev", objective: "hypertrophy", weight_unit: MeasurementUnits::WEIGHTS::KG, distance_unit: MeasurementUnits::DISTANCES::KM, height_unit: MeasurementUnits::HEIGHTS::CM },
  { email: "demo4@fittracker.dev", objective: "general_health", weight_unit: MeasurementUnits::WEIGHTS::LBS, distance_unit: MeasurementUnits::DISTANCES::MI, height_unit: MeasurementUnits::HEIGHTS::CM },
  { email: "demo5@fittracker.dev", objective: "weight_loss", weight_unit: MeasurementUnits::WEIGHTS::KG, distance_unit: MeasurementUnits::DISTANCES::MI, height_unit: MeasurementUnits::HEIGHTS::FT }
]

user_seeds.each do |user_attributes|
  user = User.find_or_initialize_by(email: user_attributes[:email])
  
  height_val = case user_attributes[:height_unit]
               when MeasurementUnits::HEIGHTS::FT then rand(5.0..6.5).round(2)
               when MeasurementUnits::HEIGHTS::CM then rand(150..195)
               else rand(1.50..1.95).round(2)
               end

  user.update!(
    name: FFaker::Name.name,
    password: "password123",
    password_confirmation: "password123",
    weight_unit: user_attributes[:weight_unit],
    distance_unit: user_attributes[:distance_unit],
    height_unit: user_attributes[:height_unit],
    height: height_val
  )

  puts "-> User: #{user.email} (Height: #{height_val} #{user.height_unit}, Prefs: #{user.weight_unit}, #{user.distance_unit})"

  # 1. Weights (Last 90 days)
  initial_weight_kg = rand(70.0..95.0)
  
  # Calculate target weight based on objective
  target_delta = case user_attributes[:objective]
                 when "weight_loss" then rand(6.0..12.0)
                 when "hypertrophy" then -rand(2.0..5.0)
                 when "running_performance" then rand(0.5..2.0)
                 else rand(-1.0..1.5)
                 end
  target_weight_kg = (initial_weight_kg - target_delta).round(1)
  
  (0..SEED_DAYS).each do |i|
    # Simulate realistic gaps - people don't weigh themselves every day
    next unless rand < 0.80 # ~20% chance of missing that day
    
    # Progress from initial_weight (day 0) to target_weight (day 90)
    progress_ratio = 1.0 - (i.to_f / SEED_DAYS)
    base_weight_kg = initial_weight_kg + ((target_weight_kg - initial_weight_kg) * progress_ratio)

    # Add some randomness
    random_variation = rand(-1.0..0.3) # -1kg to +0.3kg fluctuation
    final_weight_kg = (base_weight_kg + random_variation).round(1)

    # 10% chance of recording weight in alternative unit
    record_unit = if rand < 0.10
                    (user.weight_unit == MeasurementUnits::WEIGHTS::KG ? MeasurementUnits::WEIGHTS::LBS : MeasurementUnits::WEIGHTS::KG)
                  else
                    user.weight_unit
                  end
    
    final_weight = UnitConverter.convert_weight_between(final_weight_kg, MeasurementUnits::WEIGHTS::KG, record_unit)
    
    FactoryBot.create(:weight,
      user: user,
      weight_date: i.days.ago.to_date,
      value: final_weight,
      weight_unit: record_unit
    )
  end

  # 2. Diet & Meals
  diet_initial = UnitConverter.convert_weight_between(initial_weight_kg, MeasurementUnits::WEIGHTS::KG, user.weight_unit)
  diet_target = UnitConverter.convert_weight_between(target_weight_kg, MeasurementUnits::WEIGHTS::KG, user.weight_unit)

  diet = FactoryBot.create(:diet,
    :with_meals,
    user: user,
    start_date: (DIET_DURATION_DAYS / 2).days.ago.to_date,
    end_date: (DIET_DURATION_DAYS / 2).days.from_now.to_date,
    initial_weight: diet_initial,
    target_weight: diet_target,
    weight_unit: user.weight_unit
  )

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

      record_dist_unit = if rand < 0.10
                           (user.distance_unit == MeasurementUnits::DISTANCES::KM ? MeasurementUnits::DISTANCES::MI : MeasurementUnits::DISTANCES::KM)
                         else
                           user.distance_unit
                         end

      record_weight_unit = if rand < 0.10
                             (user.weight_unit == MeasurementUnits::WEIGHTS::KG ? MeasurementUnits::WEIGHTS::LBS : MeasurementUnits::WEIGHTS::KG)
                           else
                             user.weight_unit
                           end

      FactoryBot.create(sport,
        user: user,
        workout_date: i.days.ago.to_date,
        distance_unit: record_dist_unit,
        weight_unit: record_weight_unit
      )
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

  # 6. Meal Diaries (30 entries, one per day starting from 30 days ago)
  (0..29).each do |index|
    FactoryBot.create(:meal_diary,
      :with_meals,
      user: user,
      diary_date: index.days.ago.to_date,
      notes: "Today I had a #{['great', 'decent', 'okay', 'not so good'].sample} day with my diet. Ate #{['clean', 'a bit too much', 'some junk food'].sample}."
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
puts " - Meal Diaries: #{MealDiary.count}"