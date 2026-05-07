# frozen_string_literal: true

puts "Seeding database..."

srand(20260505)

module SeedName
	def self.full_name
		if defined?(Faker)
			Faker::Name.name
		else
			FFaker::Name.name
		end
	end
end

meal_slots = [
	{ at: "07:30", type: 0 },
	{ at: "10:30", type: 1 },
	{ at: "13:00", type: 2 },
	{ at: "16:30", type: 3 },
	{ at: "19:30", type: 4 },
	{ at: "22:00", type: 5 }
]

meal_descriptions = [
	"Greek yogurt with berries and granola",
	"Egg omelette with whole grain toast",
	"Grilled chicken, rice and mixed salad",
	"Banana + peanut butter pre-workout",
	"Salmon, sweet potato and broccoli",
	"Cottage cheese with nuts"
]

user_seeds = [
	{ email: "demo1@fittracker.dev", objective: "weight_loss" },
	{ email: "demo2@fittracker.dev", objective: "running_performance" },
	{ email: "demo3@fittracker.dev", objective: "hypertrophy" },
	{ email: "demo4@fittracker.dev", objective: "general_health" },
	{ email: "demo5@fittracker.dev", objective: "weight_loss" }
]

if ENV["RESET_SEED"] == "true"
	ChatMessage.where(user_id: User.where(email: user_seeds.map { |u| u[:email] }).select(:id)).delete_all
	Meal.where(diet_id: Diet.where(user_id: User.where(email: user_seeds.map { |u| u[:email] }).select(:id)).select(:id)).delete_all
	Diet.where(user_id: User.where(email: user_seeds.map { |u| u[:email] }).select(:id)).delete_all
	Weight.where(user_id: User.where(email: user_seeds.map { |u| u[:email] }).select(:id)).delete_all
	Running.where(user_id: User.where(email: user_seeds.map { |u| u[:email] }).select(:id)).delete_all
end

created_users = []

user_seeds.each_with_index do |attrs, idx|
	user = User.find_or_initialize_by(email: attrs[:email])
	user.name = SeedName.full_name
	user.password = "password123"
	user.password_confirmation = "password123"
	user.height = rand(1.55..1.90).round(2)
	user.target_pace = rand(4.8..7.2).round(2)
	user.save!

	# Keep seed deterministic and re-runnable without infinite growth.
	user.chat_messages.delete_all
	user.weights.delete_all
	user.runnings.delete_all
	user.diets.includes(:meals).find_each do |diet|
		Meal.where(diet_id: diet.id).delete_all
		diet.delete
	end

	initial_weight = rand(62.0..96.0).round(1)
	target_delta = case attrs[:objective]
								 when "weight_loss" then rand(6.0..12.0)
								 when "hypertrophy" then -rand(2.0..5.0)
								 else rand(1.0..4.0)
								 end
	target_weight = (initial_weight - target_delta).round(1)

	diet = user.diets.create!(
		start_date: 75.days.ago.to_date,
		end_date: 15.days.from_now.to_date,
		initial_weight: initial_weight,
		target_weight: target_weight
	)
	raise "Diet was not persisted for user #{user.email}" unless diet.persisted?

	meal_slots.each_with_index do |slot, meal_idx|
		Meal.create!(
			diet_id: diet.id,
			schedule: Time.zone.parse(slot[:at]),
			meal_type: slot[:type],
			description: meal_descriptions[(idx + meal_idx) % meal_descriptions.length]
		)
	end

	current_weight = initial_weight
	(0..60).step(2) do |offset|
		days_ago = 60 - offset
		trend = case attrs[:objective]
						when "weight_loss" then -rand(0.03..0.12)
						when "hypertrophy" then rand(0.01..0.07)
						else -rand(-0.04..0.04)
						end
		noise = rand(-0.15..0.15)
		current_weight = (current_weight + trend + noise).round(1)

		user.weights.create!(
			weight_date: days_ago.days.ago.to_date,
			kg: [current_weight, 45.0].max
		)
	end

	(0..45).step(3) do |offset|
		days_ago = 45 - offset
		distance = rand(3.0..12.0).round(2)
		pace = rand(5.0..7.5)
		duration = (distance * pace).round(2)

		user.runnings.create!(
			running_date: days_ago.days.ago.to_date,
			distance: distance,
			duration: duration
		)
	end

	prompts = [
		"How can I improve my routine this week?",
		"Based on my latest progress, what should I adjust in meals?",
		"Can you suggest training focus for the next 7 days?"
	]

	responses = [
		"Great consistency. Keep protein intake stable and sleep 7-8 hours.",
		"Your trend is improving. Maintain hydration and plan one lighter recovery day.",
		"Use progressive overload and monitor pace variation to avoid overtraining."
	]

	prompts.each_with_index do |content, i|
		user.chat_messages.create!(role: "user", content: content)
		user.chat_messages.create!(role: "assistant", content: responses[i])
	end

	created_users << user
end

puts "Seed done."
puts "Users: #{User.count}"
puts "Diets: #{Diet.count}"
puts "Meals: #{Meal.count}"
puts "Weights: #{Weight.count}"
puts "Runnings: #{Running.count}"
puts "ChatMessages: #{ChatMessage.count}"
puts "Demo password for seeded users: password123"

