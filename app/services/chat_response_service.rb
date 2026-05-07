# frozen_string_literal: true

class ChatResponseService
  def initialize(user:, prompt:, objective: nil, client: nil)
    @user = user
    @prompt = prompt
    @objective = objective
    @client = client || OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"] || ENV["OPEN_API_KEY"])
  end

  def call
    user.chat_messages.create!(role: "user", content: prompt)
    assistant_response = +""

    begin
      client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [system_message, *history_messages],
          stream: proc do |chunk|
            content = chunk.dig("choices", 0, "delta", "content")
            next if content.nil?

            assistant_response << content
            yield content if block_given?
          end
        }
      )
    ensure
      if assistant_response.present?
        user.chat_messages.create!(role: "assistant", content: assistant_response)
      end
    end

    assistant_response
  end

  private

  attr_reader :user, :prompt, :objective, :client

  def history_messages
    user.chat_messages.ordered.last(20).map do |msg|
      { role: msg.role, content: msg.content }
    end
  end

  def system_message
    {
      role: "system",
      content: <<~PROMPT
        #{objective_instructions}
        Use the user data below to respond in an objective, personalized and safe manner.
        If any important data is missing, ask short questions to gather it.

        USER DATA
        #{user_context_for_ai}
      PROMPT
    }
  end

  def objective_instructions
    case objective
    when "weight_loss"
      "You are an assistant specialized in healthy weight loss. Prioritize caloric deficit, meal quality, hydration and exercise. Be encouraging and practical."
    when "hypertrophy"
      "You are an assistant specialized in muscle hypertrophy. Prioritize controlled caloric surplus, protein intake, progressive overload and recovery. Be technical and motivating."
    when "running_performance"
      "You are an assistant specialized in running performance. Prioritize pace, progressive distance, recovery, hydration and pre/post workout nutrition. Analyze the user's running history."
    else
      "You are a health and performance assistant. Analyze the user's data holistically and provide balanced guidance on nutrition, exercise and well-being."
    end
  end

  def user_context_for_ai
    latest_diet = user.diets.order(end_date: :desc, id: :desc).first
    meals = latest_diet ? latest_diet.meals.order(:schedule).limit(20) : []
    weights = user.weights.order(weight_date: :desc, id: :desc).limit(30)

    runnings = user.runnings.order(workout_date: :desc, id: :desc).limit(10)
    walkings = user.walkings.order(workout_date: :desc, id: :desc).limit(10)
    cyclings = user.cyclings.order(workout_date: :desc, id: :desc).limit(10)
    swimmings = user.swimmings.order(workout_date: :desc, id: :desc).limit(10)
    weightliftings = user.weightliftings.order(workout_date: :desc, id: :desc).limit(10)
    yogas = user.yogas.order(workout_date: :desc, id: :desc).limit(10)
    soccers = user.soccers.order(workout_date: :desc, id: :desc).limit(10)
    basketballs = user.basketballs.order(workout_date: :desc, id: :desc).limit(10)
    tennis = user.tennis.order(workout_date: :desc, id: :desc).limit(10)
    martial_arts = user.martial_arts.order(workout_date: :desc, id: :desc).limit(10)
    others = user.others.order(workout_date: :desc, id: :desc).limit(10)

    lines = []
    lines << "Name: #{user.name}"
    lines << "Email: #{user.email}"

    if latest_diet.present?
      lines << "Current diet: start=#{latest_diet.start_date}, end=#{latest_diet.end_date}, initial_weight=#{latest_diet.initial_weight}, target_weight=#{latest_diet.target_weight}, height=#{user.height || 'not provided'}"
    else
      lines << "Current diet: not provided"
    end

    if meals.any?
      lines << "Meals in current diet:"
      meals.each do |meal|
        lines << "- schedule=#{meal.schedule}, type=#{meal.meal_type}, description=#{meal.description}"
      end
    else
      lines << "Meals: not provided"
    end

    if weights.any?
      lines << "Weight history (most recent):"
      weights.each do |weight|
        lines << "- date=#{weight.weight_date}, kg=#{weight.kg}"
      end
    else
      lines << "Weight history: empty"
    end

    [
      { name: WorkoutType.t(:running), records: runnings, fields: ->(w) { "distance=#{w.distance}, duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:walking), records: walkings, fields: ->(w) { "distance=#{w.distance}, duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:cycling), records: cyclings, fields: ->(w) { "distance=#{w.distance}, duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:swimming), records: swimmings, fields: ->(w) { "distance=#{w.distance}, duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:weightlifting), records: weightliftings, fields: ->(w) { "duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:yoga), records: yogas, fields: ->(w) { "duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:soccer), records: soccers, fields: ->(w) { "duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:basketball), records: basketballs, fields: ->(w) { "duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:tennis), records: tennis, fields: ->(w) { "duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:martial_arts), records: martial_arts, fields: ->(w) { "duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } },
      { name: WorkoutType.t(:other), records: others, fields: ->(w) { "duration=#{w.duration}, calories=#{w.calories}, details=#{w.details}" } }
    ].each do |type|
      if type[:records].any?
        lines << "#{type[:name]} history (most recent):"
        type[:records].each do |workout|
          lines << "- date=#{workout.workout_date}, #{type[:fields].call(workout)}"
        end
      else
        lines << "#{type[:name]} history: empty"
      end
    end

    lines.join("\n")
  end
end
