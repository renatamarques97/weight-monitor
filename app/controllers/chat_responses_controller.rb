# frozen_string_literal: true

class ChatResponsesController < ApplicationController
  include ActionController::Live

  before_action :authenticate_user!

  def show
    user_prompt = params[:prompt].to_s.strip
    return head :unprocessable_entity if user_prompt.blank?

    response.headers['Content-type']  = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
    sse                               = SSE.new(response.stream, event: "message")
    client                            = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    current_user.chat_messages.create!(role: "user", content: user_prompt)

    history_messages = current_user.chat_messages.ordered.last(20).map do |msg|
      { role: msg.role, content: msg.content }
    end

    system_message = {
      role: "system",
      content: <<~PROMPT
        #{objective_instructions}
        Use the user data below to respond in an objective, personalized and safe manner.
        If any important data is missing, ask short questions to gather it.

        USER DATA
        #{user_context_for_ai}
      PROMPT
    }

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
            sse.write({ message: content })
          end
        }
      )
    ensure
      if assistant_response.present?
        current_user.chat_messages.create!(role: "assistant", content: assistant_response)
      end
      sse.close
    end
  end

  private

  def objective_instructions
    case params[:objective]
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
    latest_diet = current_user.diets.order(end_date: :desc, id: :desc).first
    meals = latest_diet ? latest_diet.meals.order(:schedule).limit(20) : []
    weights = current_user.weights.order(weight_date: :desc, id: :desc).limit(30)
    runnings = current_user.runnings.order(running_date: :desc, id: :desc).limit(30)

    lines = []
    lines << "Name: #{current_user.name}"
    lines << "Email: #{current_user.email}"

    if latest_diet.present?
      lines << "Current diet: start=#{latest_diet.start_date}, end=#{latest_diet.end_date}, initial_weight=#{latest_diet.initial_weight}, target_weight=#{latest_diet.target_weight}, height=#{latest_diet.height || 'not provided'}"
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

    if runnings.any?
      lines << "Running history (most recent):"
      runnings.each do |running|
        lines << "- date=#{running.running_date}, distance=#{running.distance}, duration=#{running.duration}, avg_pace=#{running.avg_pace}"
      end
    else
      lines << "Running history: empty"
    end

    lines.join("\n")
  end
end
