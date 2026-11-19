# frozen_string_literal: true

class ChatResponseService
  def initialize(user:, prompt:, objective: nil, client: nil)
    @user = user
    @prompt = prompt
    @objective = objective
    @client = client || OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'] || ENV.fetch('OPEN_API_KEY', nil))
  end

  def call(&stream_block)
    create_user_message
    assistant_response = +''

    begin
      client.chat(parameters: chat_parameters(assistant_response, &stream_block))
    ensure
      create_assistant_message(assistant_response)
    end

    assistant_response
  end

  private

  attr_reader :user, :prompt, :objective, :client

  def create_user_message
    user.chat_messages.create!(role: 'user', content: prompt)
  end

  def chat_parameters(assistant_response, &stream_block)
    {
      model: 'gpt-3.5-turbo',
      messages: [system_message, *history_messages],
      stream: stream_handler(assistant_response, &stream_block)
    }
  end

  def stream_handler(assistant_response, &stream_block)
    proc do |chunk|
      content = chunk.dig('choices', 0, 'delta', 'content')
      next if content.nil?

      assistant_response << content
      stream_block&.call(content)
    end
  end

  def create_assistant_message(assistant_response)
    user.chat_messages.create!(role: 'assistant', content: assistant_response) if assistant_response.present?
  end

  def history_messages
    user.chat_messages.ordered.last(20).map do |msg|
      { role: msg.role, content: msg.content }
    end
  end

  def system_message
    {
      role: 'system',
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
    when 'weight_loss'
      'You are an assistant specialized in healthy weight loss. Prioritize caloric deficit, meal quality, hydration and exercise. Be encouraging and practical.'
    when 'hypertrophy'
      'You are an assistant specialized in muscle hypertrophy. Prioritize controlled caloric surplus, protein intake, progressive overload and recovery. Be technical and motivating.'
    when 'running_performance'
      "You are an assistant specialized in running performance. Prioritize pace, progressive distance, recovery, hydration and pre/post workout nutrition. Analyze the user's running history."
    else
      "You are a health and performance assistant. Analyze the user's data holistically and provide balanced guidance on nutrition, exercise and well-being."
    end
  end

  def user_context_for_ai
    ChatResponseContext.new(user).call
  end
end
